tool
class_name TextureOutlineableSprite, \
"res://addons/scaffolder/assets/images/editor_icons/outlineable_sprite.png"
extends OutlineableSprite
## -   This supports toggling an outline around the sprite, and changing the[br]
##     color of the outline.[br]
## -   This implementation of OutlineableSprite requires that you provide[br]
##     two versions of the texture, one with the outline and one without.[br]
## -   TextureOutlineableSprite is more efficient than[br]
##     ShaderOutlineableSprite.[br]
##     -   By a factor of around x7, for a one-pixel border.[br]
## -   But using a separate outline texture is more work for the sprite[br]
##     author.[br]
## -   So shader-based outlines might be better for prototyping, or when you[br]
##     know you won't be rendering too many outlined sprites simultaneously.[br]


export var outline_suffix := "_outline" setget _set_outline_suffix
export var normal_texture: Texture setget _set_normal_texture
export var outlined_texture: Texture setget _set_outlined_texture

## -   NOTE: Animate on this field instead of frame!
## -   This is an unfortunate hack.
## -   But Godot's AnimationPlayer apparently bypasses the getter/setter for
##     frame, so we cannot use set_frame to sync the outline sprite with the
##     normal sprite.
export var my_frame: int setget _set_my_frame,_get_my_frame
func _set_my_frame(value) -> void:
    set_frame(value)
func _get_my_frame() -> int:
    return get_frame()

var saturation := 1.0 setget _set_saturation
func _set_saturation(value: float) -> void:
    saturation = value
    _set_outline_color(outline_color)


var _configuration_warning := ""


func _ready() -> void:
    _update_textures()
    _update_inner_sprite()


func _update_textures() -> void:
    var normal_path: String
    var outlined_path: String
    if is_instance_valid(normal_texture):
        normal_path = normal_texture.resource_path
        var dot_index := normal_path.find_last(".")
        var extension := normal_path.substr(dot_index + 1)
        outlined_path = "%s%s.%s" % [
                normal_path.substr(0, dot_index),
                outline_suffix,
                extension,
            ]
    elif is_instance_valid(outlined_texture):
        outlined_path = outlined_texture.resource_path
        var dot_index := outlined_path.find_last(".")
        var extension := outlined_path.substr(dot_index + 1)
        normal_path = "%s.%s" % [
                outlined_path.substr(
                    0,
                    outlined_path.length() - outline_suffix.length() - 4),
                extension,
            ]
    else:
        _set_configuration_warning(
            "normal_texture or outlined_texture must be assigned.")
        return
    
    var dot_index := outlined_path.find_last(".")
    if !outlined_path.substr(0, dot_index).ends_with(outline_suffix):
        _set_configuration_warning(
                "outlined_texture does not match outline_suffix.")
        return
    
    if !File.new().file_exists(normal_path):
        _set_configuration_warning(
                "There is no normal_texture file at: %s." % normal_path)
        return
    normal_texture = load(normal_path)

    if !File.new().file_exists(outlined_path):
        _set_configuration_warning(
                "There is no outlined_texture file at: %s." % outlined_path)
        return
    outlined_texture = load(outlined_path)
    
    _update_outline()


func _update_outline() -> void:
    if is_outlined:
        $Outline.texture = outlined_texture
    else:
        $Outline.texture = null
    self.texture = normal_texture
    _set_outline_color(outline_color)
    property_list_changed_notify()


func _update_inner_sprite() -> void:
    $Outline.centered = self.centered
    $Outline.flip_h = self.flip_h
    $Outline.flip_v = self.flip_v
    $Outline.frame = self.frame
    $Outline.frame_coords = self.frame_coords
    $Outline.hframes = self.hframes
    $Outline.vframes = self.vframes
    $Outline.offset = self.offset
    $Outline.region_enabled = self.region_enabled
    $Outline.region_filter_clip = self.region_filter_clip
    $Outline.region_rect = self.region_rect


func _set_configuration_warning(value: String) -> void:
    _configuration_warning = value
    update_configuration_warning()


func _get_configuration_warning() -> String:
    return _configuration_warning


func _set_is_outlined(value: bool) -> void:
    is_outlined = value
    if !is_instance_valid(normal_texture):
        _set_configuration_warning("normal_texture must be assigned.")
        return
    if !is_instance_valid(outlined_texture):
        _set_configuration_warning("outlined_texture must be assigned.")
        return
    _update_outline()


func _set_outline_color(value: Color) -> void:
    outline_color = value
    $Outline.modulate = outline_color
    $Outline.modulate.s *= saturation


func _set_outline_suffix(value: String) -> void:
    outline_suffix = value
    _update_textures()


func _set_outlined_texture(value: Texture) -> void:
    outlined_texture = value
    _update_textures()


func _set_normal_texture(value: Texture) -> void:
    normal_texture = value
    _update_textures()
    property_list_changed_notify()


func set_centered(value: bool) -> void:
    .set_centered(value)
    _update_inner_sprite()


func set_flip_h(value: bool) -> void:
    .set_flip_h(value)
    _update_inner_sprite()


func set_flip_v(value: bool) -> void:
    .set_flip_v(value)
    _update_inner_sprite()


func set_frame(value: int) -> void:
    .set_frame(value)
    _update_inner_sprite()


func set_frame_coords(value: Vector2) -> void:
    .set_frame_coords(value)
    _update_inner_sprite()


func set_hframes(value: int) -> void:
    .set_hframes(value)
    _update_inner_sprite()


func set_vframes(value: int) -> void:
    .set_vframes(value)
    _update_inner_sprite()


func set_offset(value: Vector2) -> void:
    .set_offset(value)
    _update_inner_sprite()


func set_region(value: bool) -> void:
    .set_region(value)
    _update_inner_sprite()


func set_region_filter_clip(value: bool) -> void:
    .set_region_filter_clip(value)
    _update_inner_sprite()


func set_region_rect(value: Rect2) -> void:
    .set_region_rect(value)
    _update_inner_sprite()


func _set_is_desaturatable(value: bool) -> void:
    is_desaturatable = value
    if value:
        self.add_to_group(Sc.slow_motion.GROUP_NAME_DESATURATABLES)
        self.add_to_group(Sc.slow_motion \
            .GROUP_NAME_NON_SHADER_BASED_DESATURATABLES)
    else:
        if self.is_in_group(Sc.slow_motion.GROUP_NAME_DESATURATABLES):
            self.remove_from_group(Sc.slow_motion.GROUP_NAME_DESATURATABLES)
        if self.is_in_group(Sc.slow_motion \
            .GROUP_NAME_NON_SHADER_BASED_DESATURATABLES):
            self.remove_from_group(Sc.slow_motion \
                .GROUP_NAME_NON_SHADER_BASED_DESATURATABLES)

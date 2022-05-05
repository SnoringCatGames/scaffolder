tool
class_name TextureOutlineableAnimatedSprite, \
"res://addons/scaffolder/assets/images/editor_icons/outlineable_animated_sprite.png"
extends OutlineableAnimatedSprite
## -   This supports toggling an outline around the sprite, and changing the[br]
##     color of the outline.[br]
## -   This implementation of OutlineableAnimatedSprite requires that you[br]
##     provide two versions of the texture, one with the outline and one[br]
##     without.[br]
## -   TextureOutlineableSprite is more efficient than[br]
##     ShaderOutlineableSprite.[br]
##     -   By a factor of around x7, for a one-pixel border.[br]
## -   But using a separate outline texture is more work for the sprite[br]
##     author.[br]
## -   So shader-based outlines might be better for prototyping, or when you[br]
##     know you won't be rendering too many outlined sprites simultaneously.[br]


export var normal_frames: SpriteFrames setget _set_normal_frames
export var outlined_frames: SpriteFrames setget _set_outlined_frames

# FIXME: --------------------------------------
# - I copied `my_frame` from TextureOutlineableSprite.
# - I'm not sure if the same problem happens with AnimatedSprite.
# - If so, then we'll need to find another fix, probably by syncing the frame
#   in _process().

## -   NOTE: Animate on this field instead of frame!
## -   This is an unfortunate hack.
## -   But Godot's AnimationPlayer apparently bypasses the getter/setter for
##     frame, so we cannot use set_frame to sync the outline sprite with the
##     normal sprite.
# export var my_frame: int setget _set_my_frame,_get_my_frame
# func _set_my_frame(value) -> void:
#     set_frame(value)
# func _get_my_frame() -> int:
#     return get_frame()

var saturation := 1.0 setget _set_saturation
func _set_saturation(value: float) -> void:
    saturation = value
    _set_outline_color(outline_color)

var _configuration_warning := ""


func _ready() -> void:
    _update_inner_sprite()


func _update_outline() -> void:
    if is_outlined:
        $Outline.frames = outlined_frames
    else:
        $Outline.frames = null
    _set_outline_color(outline_color)
    property_list_changed_notify()


func _update_inner_sprite() -> void:
    $Outline.centered = self.centered
    $Outline.flip_h = self.flip_h
    $Outline.flip_v = self.flip_v
    $Outline.frame = self.frame
    $Outline.offset = self.offset
    $Outline.playing = self.playing
    $Outline.animation = self.animation
    $Outline.speed_scale = self.speed_scale


func _set_configuration_warning(value: String) -> void:
    _configuration_warning = value
    update_configuration_warning()


func _get_configuration_warning() -> String:
    return _configuration_warning


func _set_is_outlined(value: bool) -> void:
    is_outlined = value
    if !is_instance_valid(normal_frames):
        _set_configuration_warning("normal_frames must be assigned.")
        return
    if !is_instance_valid(outlined_frames):
        _set_configuration_warning("outlined_frames must be assigned.")
        return
    _update_outline()


func _set_outline_color(value: Color) -> void:
    outline_color = value
    $Outline.modulate = outline_color
    $Outline.modulate.s *= saturation


func _set_outlined_frames(value: SpriteFrames) -> void:
    outlined_frames = value
    _update_outline()


func _set_normal_frames(value: SpriteFrames) -> void:
    set_frames(value)


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


func set_frames(value: SpriteFrames) -> void:
    .set_frames(value)
    _update_inner_sprite()
    property_list_changed_notify()


func set_offset(value: Vector2) -> void:
    .set_offset(value)
    _update_inner_sprite()


func set_playing(value: bool) -> void:
    .set_playing(value)
    _update_inner_sprite()


func set_speed_scale(value: float) -> void:
    .set_speed_scale(value)
    _update_inner_sprite()


func set_animation(value: String) -> void:
    .set_animation(value)
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

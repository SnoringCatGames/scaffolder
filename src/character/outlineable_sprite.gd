tool
class_name OutlineableSprite, \
"res://addons/scaffolder/assets/images/editor_icons/outlineable_sprite.png"
extends Sprite


export var is_outlined := false setget _set_is_outlined
export var outline_color := Color.black setget _set_outline_color
export var outline_suffix := "_outline" setget _set_outline_suffix
export var normal_texture: Texture setget _set_normal_texture
export var outlined_texture: Texture setget _set_outlined_texture

var _configuration_warning := ""


func _ready() -> void:
    _update_textures()


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
    outlined_texture.modulate = outline_color


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

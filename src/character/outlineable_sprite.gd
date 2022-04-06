tool
class_name OutlineableSprite, \
"res://addons/scaffolder/assets/images/editor_icons/outlineable_sprite.png"
extends Sprite


export var is_outlined := false setget _set_is_outlined
export var outline_suffix := "_outline" setget _set_outline_suffix
export var outlined_texture: Texture setget _set_outlined_texture

var _configuration_warning := ""


func _set_is_outlined(value: bool) -> void:
    is_outlined = value
    if !is_instance_valid(texture):
        _set_configuration_warning("texture must be assigned.")
        return
    _update_outline()


func _set_outline_suffix(value: String) -> void:
    outline_suffix = value
    if !is_instance_valid(texture):
        _set_configuration_warning("texture must be assigned.")
        return
    if outline_suffix != "":
        _set_configuration_warning("outline_suffix must not be empty.")
        return
    var texture_path := texture.resource_path
    var dot_index := texture_path.find_last(".")
    var extension := texture_path.substr(dot_index + 1)
    var outlined_path := \
            texture_path.substr(0, dot_index) + outline_suffix + extension
    if !File.new().file_exists(outlined_path):
        _set_configuration_warning(
                "No corresponding file exists that matches the " +
                "outline_suffix: %s." % outlined_path)
        return
    outlined_texture = load(outlined_path)
    _on_texture_changed()
    property_list_changed_notify()


func _set_outlined_texture(value: Texture) -> void:
    outlined_texture = value
    if !is_instance_valid(texture):
        _set_configuration_warning("texture must be assigned.")
        return
    var outlined_path := outlined_texture.resource_path
    if !outlined_path.ends_with("%s.png" % outline_suffix):
        _set_configuration_warning(
                "outlined_texture does not match outline_suffix.")
        return
    var normal_path := outlined_path.
    _on_texture_changed()
    property_list_changed_notify()


func set_texture(value: Texture) -> void:
    .set_texture(value)
    if !is_instance_valid(texture):
        _set_configuration_warning("texture must be assigned.")
        return
    _on_texture_changed()
    property_list_changed_notify()


func _set_configuration_warning(value: String) -> void:
    _configuration_warning = value
    update_configuration_warning()


func _get_configuration_warning() -> String:
    return _configuration_warning


func _update_outline() -> void:
    if is_outlined:
        pass
    else:
        pass


func _on_texture_changed() -> void:
    pass

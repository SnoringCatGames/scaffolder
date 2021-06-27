tool
class_name ScaffolderTextureLink, "res://addons/scaffolder/assets/images/editor_icons/scaffolder_texture_link.png"
extends LinkButton


export var texture: Texture setget \
        _set_texture,_get_texture
export var texture_scale := Vector2.ONE setget \
        _set_texture_scale,_get_texture_scale
export var url: String

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    _update_size()


func update_gui_scale() -> bool:
    $ScaffolderTextureRect.update_gui_scale()
    _update_size()
    return true


func _update_size() -> void:
    if !_is_ready:
        return
    var size: Vector2 = $ScaffolderTextureRect.get_custom_size()
    rect_min_size = size
    rect_size = size


func _set_texture(value: Texture) -> void:
    $ScaffolderTextureRect.texture = value
    _update_size()


func _get_texture() -> Texture:
    return $ScaffolderTextureRect.texture


func _set_texture_scale(value: Vector2) -> void:
    $ScaffolderTextureRect.texture_scale = value
    _update_size()


func _get_texture_scale() -> Vector2:
    return $ScaffolderTextureRect.texture_scale


func _on_ScaffolderTextureLink_pressed() -> void:
    assert(!url.empty())
    Gs.utils.give_button_press_feedback()
    OS.shell_open(url)

tool
class_name ScaffolderTextureLink, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_texture_link.png"
extends LinkButton


export var texture: Texture setget _set_texture
export var texture_key: String setget _set_texture_key
export var texture_scale := Vector2.ONE setget _set_texture_scale
export var url: String

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    _update_size()


func _on_gui_scale_changed() -> bool:
    $ScaffolderTextureRect._on_gui_scale_changed()
    _update_size()
    return true


func _update_size() -> void:
    if !_is_ready:
        return
    var size: Vector2 = $ScaffolderTextureRect.get_custom_size()
    rect_min_size = size
    rect_size = size


func _set_texture(value: Texture) -> void:
    texture = value
    $ScaffolderTextureRect.texture = value
    _update_size()


func _set_texture_key(value: String) -> void:
    texture_key = value
    $ScaffolderTextureRect.texture_key = value
    _update_size()


func _set_texture_scale(value: Vector2) -> void:
    texture_scale = value
    $ScaffolderTextureRect.texture_scale = value
    _update_size()


func _on_ScaffolderTextureLink_pressed() -> void:
    assert(!url.empty())
    Sc.utils.give_button_press_feedback()
    OS.shell_open(url)

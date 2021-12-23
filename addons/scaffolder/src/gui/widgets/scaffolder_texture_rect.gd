tool
class_name ScaffolderTextureRect, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_texture_rect.png"
extends Control


export var texture: Texture setget _set_texture
export var texture_key: String setget _set_texture_key
export var texture_scale := Vector2.ONE setget _set_texture_scale

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    _set_texture(texture)
    _set_texture_scale(texture_scale)


func _on_gui_scale_changed() -> bool:
    _update_size()
    return true


func get_custom_size() -> Vector2:
    return $TextureRect.texture.get_size() * texture_scale * Sc.gui.scale if \
            is_instance_valid($TextureRect.texture) else \
            Vector2.ZERO


func _update_size() -> void:
    if $TextureRect.texture != null:
        $TextureRect.rect_pivot_offset = $TextureRect.texture.get_size() / 2.0
    $TextureRect.rect_scale = texture_scale * Sc.gui.scale
    var size: Vector2 = get_custom_size()
    rect_min_size = size
    rect_size = size


func _update_texture() -> void:
    if is_instance_valid(texture):
        $TextureRect.texture = texture
    elif texture_key != "":
        $TextureRect.texture = Sc.images.get(texture_key)


func _set_texture(value: Texture) -> void:
    texture = value
    if _is_ready:
        _update_texture()
        _update_size()


func _set_texture_key(value: String) -> void:
    texture_key = value
    assert(texture_key == "" or \
            Sc.images.get(texture_key) is Texture)
    if _is_ready:
        _update_texture()
        _update_size()


func _set_texture_scale(value: Vector2) -> void:
    texture_scale = value
    if _is_ready:
        _update_size()

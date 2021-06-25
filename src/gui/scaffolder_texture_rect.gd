tool
class_name ScaffolderTextureRect, "res://addons/scaffolder/assets/images/editor_icons/scaffolder_texture_rect.png"
extends Control


export var texture: Texture setget \
        _set_texture,_get_texture

export var texture_scale := Vector2.ONE setget \
        _set_texture_scale,_get_texture_scale

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    _set_texture(texture)
    _set_texture_scale(texture_scale)


func update_gui_scale() -> bool:
    _update_size()
    return true


func _update_size() -> void:
    if texture != null:
        $TextureRect.rect_pivot_offset = texture.get_size() / 2.0
    $TextureRect.rect_scale = texture_scale * Gs.gui.scale
    
    if texture == null:
        return
    var size: Vector2 = texture.get_size() * $TextureRect.rect_scale
    rect_min_size = size
    rect_size = size


func _set_texture(value: Texture) -> void:
    texture = value
    if _is_ready:
        $TextureRect.texture = value
        _update_size()


func _get_texture() -> Texture:
    return texture


func _set_texture_scale(value: Vector2) -> void:
    texture_scale = value
    if _is_ready:
        _update_size()


func _get_texture_scale() -> Vector2:
    return texture_scale

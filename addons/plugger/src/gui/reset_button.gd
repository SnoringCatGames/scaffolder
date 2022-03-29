tool
class_name ResetButton
extends Button


export var button_size := Vector2.ZERO setget _set_button_size
export var texture_size := Vector2.ZERO setget _set_texture_size

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    $CenterContainer/TextureRect.texture = Pl.get_editor_icon("Reload")
    _update_size()


func _update_size() -> void:
    if !_is_ready:
        return
    
    self.rect_min_size = button_size
    $CenterContainer.rect_min_size = button_size
    
    var texture_original_size: Vector2 = \
            $CenterContainer/TextureRect.texture.get_size()
    var texture_size_ratio_x := texture_size.x / texture_original_size.x
    var texture_size_ratio_y := texture_size.y / texture_original_size.y
    
    $CenterContainer/TextureRect.rect_min_size = \
            texture_original_size * \
            max(texture_size_ratio_x, texture_size_ratio_y)


func _set_button_size(value: Vector2) -> void:
    button_size = value
    _update_size()


func _set_texture_size(value: Vector2) -> void:
    texture_size = value
    _update_size()

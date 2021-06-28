tool
class_name ScaffolderTextureButton, "res://addons/scaffolder/assets/images/editor_icons/scaffolder_texture_button.png"
extends Control


signal pressed

export var texture_normal: Texture setget _set_texture_normal
export var texture_pressed: Texture setget _set_texture_pressed
export var texture_hover: Texture setget _set_texture_hover
export var texture_disabled: Texture setget _set_texture_disabled
export var texture_focused: Texture setget _set_texture_focused
export var texture_click_mask: Texture setget _set_texture_click_mask
export var expands_texture := true setget _set_expands_texture

export var texture_scale := Vector2.ONE setget _set_texture_scale
export var size_override := Vector2.ZERO setget _set_size_override

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    _update()


func update_gui_scale() -> bool:
    _update()
    return true


func _update() -> void:
    if !_is_ready:
        return
    
    $TextureButton.texture_normal = texture_normal
    $TextureButton.texture_pressed = texture_pressed
    $TextureButton.texture_hover = texture_hover
    $TextureButton.texture_disabled = texture_disabled
    $TextureButton.texture_focused = texture_focused
    $TextureButton.texture_click_mask = texture_click_mask
    $TextureButton.expand = expands_texture
    
    rect_min_size = size_override * Gs.gui.scale
    rect_size = size_override * Gs.gui.scale
    $TextureButton.rect_scale = texture_scale * Gs.gui.scale
    $TextureButton.rect_size = size_override / texture_scale


func _set_texture_normal(value: Texture) -> void:
    texture_normal = value
    _update()


func _set_texture_pressed(value: Texture) -> void:
    texture_pressed = value
    _update()


func _set_texture_hover(value: Texture) -> void:
    texture_hover = value
    _update()


func _set_texture_disabled(value: Texture) -> void:
    texture_disabled = value
    _update()


func _set_texture_focused(value: Texture) -> void:
    texture_focused = value
    _update()


func _set_texture_click_mask(value: Texture) -> void:
    texture_click_mask = value
    _update()


func _set_texture_scale(value: Vector2) -> void:
    texture_scale = value
    _update()


func _set_expands_texture(value: bool) -> void:
    expands_texture = value
    _update()


func _set_size_override(value: Vector2) -> void:
    size_override = value
    _update()


func _on_TextureButton_pressed() -> void:
    Gs.utils.give_button_press_feedback()
    emit_signal("pressed")

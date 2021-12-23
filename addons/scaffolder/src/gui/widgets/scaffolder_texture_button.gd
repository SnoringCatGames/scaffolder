tool
class_name ScaffolderTextureButton, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_texture_button.png"
extends Control


signal pressed

export var texture_normal: Texture setget _set_texture_normal
export var texture_pressed: Texture setget _set_texture_pressed
export var texture_hover: Texture setget _set_texture_hover
export var texture_disabled: Texture setget _set_texture_disabled
export var texture_focused: Texture setget _set_texture_focused

export var texture_click_mask: Texture setget _set_texture_click_mask

export var texture_key: String setget _set_texture_key

export var expands_texture := true setget _set_expands_texture

export var texture_scale := Vector2.ONE setget _set_texture_scale
export var size_override := Vector2.ZERO setget _set_size_override

export var disabled := false setget _set_disabled

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    _update()


func _on_gui_scale_changed() -> bool:
    _update()
    return true


func _update() -> void:
    if !_is_ready:
        return
    
    if texture_key != "":
        var texture_normal: Texture = Sc.images.get(texture_key + "_normal")
        var texture_pressed: Texture
        var texture_hover: Texture
        
        if is_instance_valid(Sc.images.get(texture_key + "_pressed")):
            texture_pressed = Sc.images.get(texture_key + "_pressed")
        else:
            texture_pressed = texture_normal
        
        if is_instance_valid(Sc.images.get(texture_key + "_hover")):
            texture_hover = Sc.images.get(texture_key + "_hover")
        else:
            texture_hover = texture_pressed
        
        $TextureButton.texture_normal = texture_normal
        $TextureButton.texture_pressed = texture_pressed
        $TextureButton.texture_hover = texture_hover
        $TextureButton.texture_disabled = texture_pressed
        $TextureButton.texture_focused = texture_hover
    else:
        $TextureButton.texture_normal = texture_normal
        $TextureButton.texture_pressed = texture_pressed
        $TextureButton.texture_hover = texture_hover
        $TextureButton.texture_disabled = texture_disabled
        $TextureButton.texture_focused = texture_focused
    
    $TextureButton.texture_click_mask = texture_click_mask
    $TextureButton.expand = expands_texture
    
    rect_min_size = size_override * Sc.gui.scale
    rect_size = size_override * Sc.gui.scale
    $TextureButton.rect_scale = texture_scale * Sc.gui.scale
    $TextureButton.rect_size = size_override / texture_scale
    
    $TextureButton.disabled = disabled


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


func _set_texture_key(value: String) -> void:
    texture_key = value
    assert(texture_key == "" or \
            Sc.images.get(texture_key + "_normal") is Texture)
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


func _set_disabled(value: bool) -> void:
    disabled = value
    _update()


func _on_TextureButton_pressed() -> void:
    Sc.utils.give_button_press_feedback()
    emit_signal("pressed")

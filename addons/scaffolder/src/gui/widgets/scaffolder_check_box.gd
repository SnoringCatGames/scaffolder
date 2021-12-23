tool
class_name ScaffolderCheckBox, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_check_box.png"
extends Control


signal pressed
signal toggled(pressed)

export var text: String setget _set_text
export var pressed := false setget _set_pressed
export var disabled := false setget _set_disabled
export var scale := 1.0 setget _set_scale
export var size_override := Vector2.ZERO setget _set_size_override
export var group: ButtonGroup setget _set_group

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    
    _set_text(text)
    _set_pressed(pressed)
    _set_disabled(disabled)
    
    _on_gui_scale_changed()


func _on_gui_scale_changed() -> bool:
    call_deferred("_deferred_on_gui_scale_changed")
    return true


func _deferred_on_gui_scale_changed() -> void:
    $CheckBox.rect_size = Vector2(
            Sc.images.current_checkbox_size,
            Sc.images.current_checkbox_size)
    
    var check_box_scale := _get_icon_scale()
    $CheckBox.rect_scale = Vector2(check_box_scale, check_box_scale)
    
    rect_min_size.x = \
            (size_override.x if \
            size_override.x != 0.0 else \
            Sc.gui.button_width) * Sc.gui.scale * scale
    rect_min_size.y = \
            (size_override.y if \
            size_override.y != 0.0 else \
            Sc.gui.button_height) * Sc.gui.scale * scale
    rect_size = rect_min_size
    
    $CheckBox.rect_position = \
            (rect_size - $CheckBox.rect_size * _get_icon_scale()) / 2.0


func _get_icon_scale() -> float:
    var target_icon_size: float = \
            Sc.images.default_checkbox_size * Sc.gui.scale * scale
    return target_icon_size / Sc.images.current_checkbox_size


func _set_text(value: String) -> void:
    text = value
    if _is_ready:
        $CheckBox.text = value


func _set_pressed(value: bool) -> void:
    pressed = value
    if _is_ready:
        $CheckBox.pressed = value


func _set_disabled(value: bool) -> void:
    disabled = value
    if _is_ready:
        $CheckBox.disabled = value


func _set_scale(value: float) -> void:
    scale = value
    if _is_ready:
        _on_gui_scale_changed()


func _set_size_override(value: Vector2) -> void:
    size_override = value
    if _is_ready:
        _on_gui_scale_changed()


func _set_group(value: ButtonGroup) -> void:
    group = value
    $CheckBox.group = group


func _on_CheckBox_pressed() -> void:
    Sc.utils.give_button_press_feedback()
    emit_signal("pressed")


func _on_CheckBox_toggled(pressed: bool) -> void:
    emit_signal("toggled", pressed)

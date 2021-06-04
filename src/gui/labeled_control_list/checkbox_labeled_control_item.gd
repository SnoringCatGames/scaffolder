class_name CheckboxLabeledControlItem
extends LabeledControlItem


const SCAFFOLDER_CHECK_BOX_SCENE_PATH := \
        "res://addons/scaffolder/src/gui/scaffolder_check_box.tscn"

var TYPE := LabeledControlItem.CHECKBOX

var pressed := false


func _init(
        label: String,
        description: String,
        is_control_on_right_side := true
        ).(
        TYPE,
        label,
        description,
        is_control_on_right_side
        ) -> void:
    pass


func on_pressed(pressed: bool) -> void:
    Gs.logger.error(
            "Abstract CheckboxLabeledControlItem.on_pressed " +
            "is not implemented")


func get_is_pressed() -> bool:
    Gs.logger.error(
            "Abstract CheckboxLabeledControlItem.get_is_pressed " +
            "is not implemented")
    return false


func _update_control() -> void:
    pressed = get_is_pressed()
    if is_instance_valid(control):
        control.pressed = pressed


func create_control() -> Control:
    var checkbox: ScaffolderCheckBox = Gs.utils.add_scene(
            null,
            SCAFFOLDER_CHECK_BOX_SCENE_PATH,
            false,
            true)
    checkbox.pressed = pressed
    checkbox.disabled = !enabled
    checkbox.modulate.a = _get_alpha()
    checkbox.size_flags_horizontal = 0
    checkbox.size_flags_vertical = 0
    checkbox.rect_min_size.x = Gs.default_checkbox_icon_size
    checkbox.connect(
            "pressed",
            self,
            "_on_control_pressed")
    checkbox.connect(
            "pressed",
            self,
            "_on_checkbox_pressed")
    return checkbox


func set_check_box_scale(check_box_scale: float) -> void:
    var control_rect_size := Gs.current_checkbox_icon_size
    var control_rect_scale := _get_icon_scale(check_box_scale)
    control.rect_min_size.x = control_rect_size
    control.rect_size.x = control_rect_size
    control.scale = control_rect_scale


func _get_icon_scale(check_box_scale: float) -> float:
    var target_icon_size := \
            Gs.default_checkbox_icon_size * Gs.gui_scale * check_box_scale
    return target_icon_size / Gs.current_checkbox_icon_size


func _on_checkbox_pressed() -> void:
    pressed = !pressed
    on_pressed(pressed)
    emit_signal("changed")

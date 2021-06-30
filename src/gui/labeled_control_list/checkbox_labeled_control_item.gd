class_name CheckboxLabeledControlItem
extends LabeledControlItem


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
            Gs.gui.SCAFFOLDER_CHECK_BOX_SCENE,
            false,
            true)
    checkbox.pressed = pressed
    checkbox.disabled = !enabled
    checkbox.modulate.a = _get_alpha()
    checkbox.size_flags_horizontal = 0
    checkbox.size_flags_vertical = 0
    checkbox.size_override = Vector2.ONE * Gs.gui.default_checkbox_icon_size
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
    control.scale = check_box_scale


func _on_checkbox_pressed() -> void:
    pressed = !pressed
    on_pressed(pressed)
    emit_signal("changed")

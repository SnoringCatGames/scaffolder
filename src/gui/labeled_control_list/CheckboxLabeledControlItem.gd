class_name CheckboxLabeledControlItem
extends LabeledControlItem

const SCAFFOLDER_CHECK_BOX_SCENE_PATH := \
        "res://addons/scaffolder/src/gui/ScaffolderCheckBox.tscn"

var TYPE := LabeledControlItem.CHECKBOX

var pressed := false

func _init(
        label: String,
        description: String \
        ).(
        TYPE,
        label,
        description \
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
    checkbox.rect_min_size.x = \
            Gs.default_checkbox_icon_size * Gs.gui_scale
    checkbox.connect(
            "pressed",
            self,
            "_on_control_pressed")
    checkbox.connect(
            "pressed",
            self,
            "_on_checkbox_pressed")
    return checkbox

func _on_checkbox_pressed() -> void:
    pressed = !pressed
    on_pressed(pressed)
    emit_signal("changed")

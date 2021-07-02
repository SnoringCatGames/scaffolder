class_name TextLabeledControlItem
extends LabeledControlItem


var TYPE := LabeledControlItem.TEXT

var text: String


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


func get_is_enabled() -> bool:
    return true


func get_text() -> String:
    Gs.logger.error(
            "Abstract TextLabeledControlItem.get_text is not implemented")
    return ""


func _update_control() -> void:
    text = get_text()
    if is_instance_valid(control):
        control.text = text


func create_control() -> Control:
    var label: ScaffolderLabel = Gs.utils.add_scene(
            null, Gs.gui.SCAFFOLDER_LABEL_SCENE, false, true)
    label.text = text
    label.modulate.a = _get_alpha()
    label.align = Label.ALIGN_RIGHT
    return label

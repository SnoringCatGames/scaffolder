class_name TextControlRow
extends ControlRow


var TYPE := ControlRow.TEXT

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
    Sc.logger.error(
            "Abstract TextControlRow.get_text is not implemented")
    return ""


func _update_control() -> void:
    text = get_text()
    if is_instance_valid(control):
        control.text = text


func create_control() -> Control:
    var label: ScaffolderLabel = Sc.utils.add_scene(
            null, Sc.gui.SCAFFOLDER_LABEL_SCENE, false, true)
    label.text = text
    label.modulate.a = _get_alpha()
    label.align = Label.ALIGN_RIGHT
    return label

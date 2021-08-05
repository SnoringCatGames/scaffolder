class_name StaticTextControlRow
extends TextControlRow


func _init(
        label: String,
        text: String,
        description := "" \
        ).(
        label,
        description \
        ) -> void:
    self.text = text


func get_is_enabled() -> bool:
    return true


func get_text() -> String:
    return text

class_name HeaderControlRow
extends ControlRow


var TYPE := ControlRow.HEADER


func _init(label: String).(
        TYPE,
        label,
        "",
        true
        ) -> void:
    pass


func get_is_enabled() -> bool:
    return true


func _update_control() -> void:
    pass


func create_control() -> Control:
    return null

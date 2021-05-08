class_name HeaderLabeledControlItem
extends LabeledControlItem

var TYPE := LabeledControlItem.HEADER

func _init(label: String).(
        TYPE,
        label,
        ""
        ) -> void:
    pass

func get_is_enabled() -> bool:
    return true

func _update_control() -> void:
    pass

func create_control() -> Control:
    return null

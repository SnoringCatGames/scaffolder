tool
class_name Vector3Editor
extends MultiNumberEditor


signal value_changed(new_value)


func _init() -> void:
    keys = ["x", "y", "z"]


func _on_property_changed(value: float) -> void:
    ._on_property_changed(value)
    var values := _get_values()
    var vector := Vector3(values.x, values.y, values.z)
    emit_signal("value_changed", vector)

tool
class_name Vector3Editor
extends MultiNumberEditor


signal value_changed(new_value)


var value: Vector3 setget _set_value


func _set_value(new_value: Vector3) -> void:
    value = new_value
    _set_values({
        x = new_value.x,
        y = new_value.y,
        z = new_value.z,
    })


func _init() -> void:
    keys = ["x", "y", "z"]


func _on_property_changed(value: float) -> void:
    ._on_property_changed(value)
    var values := _get_values()
    var vector := Vector3(values.x, values.y, values.z)
    emit_signal("value_changed", vector)

tool
class_name Vector2Editor
extends MultiNumberEditor


signal value_changed(new_value)


var value: Vector2 setget _set_value


func _init() -> void:
    keys = ["x", "y"]


func _on_property_changed(value: float) -> void:
    ._on_property_changed(value)
    var values := _get_values()
    var vector := Vector2(values.x, values.y)
    emit_signal("value_changed", vector)


func _set_value(new_value: Vector2) -> void:
    value = new_value
    _set_values({
        x = new_value.x,
        y = new_value.y,
    })

tool
class_name Vector2Editor
extends MultiNumberEditor


signal value_changed(new_value)


func _init() -> void:
    keys = ["x", "y"]


func _on_property_changed(value: float) -> void:
    ._on_property_changed(value)
    var values := _get_values()
    var vector := Vector2(values.x, values.y)
    emit_signal("value_changed", vector)

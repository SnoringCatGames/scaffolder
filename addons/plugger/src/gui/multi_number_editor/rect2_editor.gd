tool
class_name Rect2Editor
extends MultiNumberEditor


signal value_changed(new_value)


func _init() -> void:
    keys = ["x", "y", "width", "height"]


func _on_property_changed(value: float) -> void:
    ._on_property_changed(value)
    var values := _get_values()
    var vector := Rect2(values.x, values.y, values.width, values.height)
    emit_signal("value_changed", vector)

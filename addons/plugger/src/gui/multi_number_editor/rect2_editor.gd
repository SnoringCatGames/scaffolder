tool
class_name Rect2Editor
extends MultiNumberEditor


signal value_changed(new_value)


var value: Rect2 setget _set_value


func _init() -> void:
    keys = ["x", "y", "width", "height"]


func _on_property_changed(value: float) -> void:
    ._on_property_changed(value)
    var values := _get_values()
    var vector := Rect2(values.x, values.y, values.width, values.height)
    emit_signal("value_changed", vector)


func _set_value(new_value: Rect2) -> void:
    value = new_value
    _set_values({
        x = new_value.position.x,
        y = new_value.position.y,
        width = new_value.size.x,
        height = new_value.size.y,
    })

tool
class_name ColorPalette
extends Node


# Dictionary<String, Color>
var _colors := {}


func set_color(
        key: String,
        color: Color) -> void:
    _colors[key] = color


func get_color(key: String) -> Color:
    return _colors[key]


func _destroy() -> void:
    _colors.clear()

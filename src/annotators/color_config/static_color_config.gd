tool
class_name StaticColorConfig
extends ColorConfig
## FIXME: ------------- Doc comment.


var r: float setget _set_r,_get_r
var g: float setget _set_g,_get_g
var b: float setget _set_b,_get_b

var _color := _TRANSPARENT


func sample() -> Color:
    return _color


func _set_h(value: float) -> void:
    _color.h = value
func _set_s(value: float) -> void:
    _color.s = value
func _set_v(value: float) -> void:
    _color.v = value
func _set_a(value: float) -> void:
    _color.a = value

func _set_r(value: float) -> void:
    _color.r = value
func _set_g(value: float) -> void:
    _color.g = value
func _set_b(value: float) -> void:
    _color.b = value

func _get_h() -> float:
    return _color.h
func _get_s() -> float:
    return _color.s
func _get_v() -> float:
    return _color.v
func _get_a() -> float:
    return _color.a

func _get_r() -> float:
    return _color.r
func _get_g() -> float:
    return _color.g
func _get_b() -> float:
    return _color.b

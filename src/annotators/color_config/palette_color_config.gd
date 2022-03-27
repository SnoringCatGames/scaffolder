tool
class_name PaletteColorConfig
extends ColorConfig
## FIXME: ------------- Doc comment.


var key: String

var _h_override := -1.0
var _s_override := -1.0
var _v_override := -1.0
var _a_override := -1.0


func sample() -> Color:
    var color: Color = Sc.palette.get_color(key)
    color.h = max(color.h, _h_override)
    color.s = max(color.s, _s_override)
    color.v = max(color.v, _v_override)
    color.a = max(color.a, _a_override)
    return color


func _set_h(value: float) -> void:
    _h_override = value
func _set_s(value: float) -> void:
    _s_override = value
func _set_v(value: float) -> void:
    _v_override = value
func _set_a(value: float) -> void:
    _a_override = value

func _get_h() -> float:
    return max(_h_override, 0.0)
func _get_s() -> float:
    return max(_s_override, 0.0)
func _get_v() -> float:
    return max(_v_override, 0.0)
func _get_a() -> float:
    return max(_a_override, 0.0)

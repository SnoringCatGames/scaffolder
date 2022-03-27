tool
class_name PaletteColorConfig
extends ColorConfig
## This lets you reference a dynamic Color value according to its[br]
## corresponding palette key. Then, the actual color can be changed, and a[br]
## static Color representation will only be used when needed.


var key: String

var _h_override := -1.0
var _s_override := -1.0
var _v_override := -1.0
var _a_override := -1.0

var h_delta := 0.0
var s_delta := 0.0
var v_delta := 0.0
var a_delta := 0.0


func sample() -> Color:
    var color: Color = Sc.palette.get_color(key)
    color.h = max(color.h, _h_override)
    color.h += h_delta
    color.s = max(color.s, _s_override)
    color.s += s_delta
    color.v = max(color.v, _v_override)
    color.v += v_delta
    color.a = max(color.a, _a_override)
    color.a += a_delta
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

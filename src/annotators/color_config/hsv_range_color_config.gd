tool
class_name HsvRangeColorConfig
extends ColorConfig
## This lets you define a range of color parameters, and then sample random[br]
## colors within these parameters.


var h_min := 0.0 setget _set_h_min
var s_min := 0.0 setget _set_s_min
var v_min := 0.0 setget _set_v_min
var a_min := 0.0 setget _set_a_min

var h_max := 0.0 setget _set_h_max
var s_max := 0.0 setget _set_s_max
var v_max := 0.0 setget _set_v_max
var a_max := 0.0 setget _set_a_max


func sample(_redirect_depth := 0) -> Color:
    var h := randf() * (h_max - h_min) + h_min
    var s := randf() * (s_max - s_min) + s_min
    var v := randf() * (v_max - v_min) + v_min
    var a := randf() * (a_max - a_min) + a_min
    return Color.from_hsv(h, s, v, a)


func _set_h_min(value: float) -> void:
    h_min = value
func _set_s_min(value: float) -> void:
    s_min = value
func _set_v_min(value: float) -> void:
    v_min = value
func _set_a_min(value: float) -> void:
    a_min = value

func _set_h_max(value: float) -> void:
    h_max = value
func _set_s_max(value: float) -> void:
    s_max = value
func _set_v_max(value: float) -> void:
    v_max = value
func _set_a_max(value: float) -> void:
    a_max = value

func _set_h(value: float) -> void:
    h_min = value
    h_max = value
func _set_s(value: float) -> void:
    s_min = value
    s_max = value
func _set_v(value: float) -> void:
    v_min = value
    v_max = value
func _set_a(value: float) -> void:
    a_min = value
    a_max = value

func _get_h() -> float:
    return h_min
func _get_s() -> float:
    return s_min
func _get_v() -> float:
    return v_min
func _get_a() -> float:
    return a_min

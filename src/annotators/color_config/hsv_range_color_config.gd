tool
class_name HsvRangeColorConfig
extends ColorConfig
## This lets you define a range of color parameters, and then sample random[br]
## colors within these parameters.


const _property_list_addendum = [
    # These fields should not be saved in .tscn files.
    {name = "h", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "s", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "v", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "a", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "min_color", type = TYPE_COLOR, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "max_color", type = TYPE_COLOR, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    # These fields should be saved in .tscn files.
    {name = "h_min", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "s_min", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "v_min", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "a_min", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "h_max", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "s_max", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "v_max", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "a_max", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
]

var h_min := 0.0 setget _set_h_min
var s_min := 0.0 setget _set_s_min
var v_min := 0.0 setget _set_v_min
var a_min := 0.0 setget _set_a_min

var h_max := 0.0 setget _set_h_max
var s_max := 0.0 setget _set_s_max
var v_max := 0.0 setget _set_v_max
var a_max := 0.0 setget _set_a_max

var min_color: Color setget _set_min_color,_get_min_color
var max_color: Color setget _set_max_color,_get_max_color


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

func _set_min_color(value: Color) -> void:
    h_min = value.h
    s_min = value.s
    v_min = value.v
    a_min = value.a
func _set_max_color(value: Color) -> void:
    h_max = value.h
    s_max = value.s
    v_max = value.v
    a_max = value.a

func _get_min_color() -> Color:
    return Color.from_hsv(h_min, s_min, v_min, a_min)
func _get_max_color() -> Color:
    return Color.from_hsv(h_max, s_max, v_max, a_max)


func to_string() -> String:
    return ("HsvRangeColorConfig(" +
            "min=[%s, %s, %s, %s], " +
            "max=[%s, %s, %s, %s])") % [
        h_min,
        s_min,
        v_min,
        a_min,
        h_max,
        s_max,
        v_max,
        a_max,
    ]


func _get_property_list() -> Array:
    return _property_list_addendum

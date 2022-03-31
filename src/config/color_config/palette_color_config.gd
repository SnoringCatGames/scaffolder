tool
class_name PaletteColorConfig
extends ColorConfig
## This lets you reference a dynamic Color value according to its[br]
## corresponding palette key. Then, the actual color can be changed, and a[br]
## static Color representation will only be used when needed.


const _property_list_addendum = [
    # These fields should not be saved in .tscn files.
    {name = "h", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "s", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "v", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "a", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "override_color", type = TYPE_COLOR, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "delta_color", type = TYPE_COLOR, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    # These fields should be saved in .tscn files.
    {name = "key", type = TYPE_STRING, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "_h_override", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "_s_override", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "_v_override", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "_a_override", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "h_delta", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "s_delta", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "v_delta", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
    {name = "a_delta", type = TYPE_REAL, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
]

var key := "transparent"

var _h_override := -1.0
var _s_override := -1.0
var _v_override := -1.0
var _a_override := -1.0

var h_delta := 0.0
var s_delta := 0.0
var v_delta := 0.0
var a_delta := 0.0

var override_color: Color setget _set_override_color,_get_override_color
var delta_color: Color setget _set_delta_color,_get_delta_color


func sample(_redirect_depth := 0) -> Color:
    var color: Color = Sc.palette.get_color(key, _redirect_depth)
    color.h = clamp(
        (_h_override if _h_override >= 0 else color.h) + h_delta,
        0.0,
        1.0)
    color.s = clamp(
        (_s_override if _s_override >= 0 else color.s) + s_delta,
        0.0,
        1.0)
    color.v = clamp(
        (_v_override if _v_override >= 0 else color.v) + v_delta,
        0.0,
        1.0)
    color.a = clamp(
        (_a_override if _a_override >= 0 else color.a) + a_delta,
        0.0,
        1.0)
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

func _set_override_color(value: Color) -> void:
    _h_override = value.h
    _s_override = value.s
    _v_override = value.v
    _a_override = value.a
func _set_delta_color(value: Color) -> void:
    h_delta = value.h
    s_delta = value.s
    v_delta = value.v
    a_delta = value.a

func _get_override_color() -> Color:
    return Color.from_hsv(_h_override, _s_override, _v_override, _a_override)
func _get_delta_color() -> Color:
    return Color.from_hsv(h_delta, s_delta, v_delta, a_delta)


func to_string() -> String:
    return ("PaletteColorConfig(%s, " +
            "override=[%s, %s, %s, %s], " +
            "delta=[%s, %s, %s, %s])") % [
        key,
        _h_override,
        _s_override,
        _v_override,
        _a_override,
        h_delta,
        s_delta,
        v_delta,
        a_delta,
    ]


func _get_property_list() -> Array:
    return _property_list_addendum

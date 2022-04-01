tool
class_name StaticColorConfig
extends ColorConfig
## This lets you use a static color value inter-changeably with the other[br]
## types of ColorConfigs.


const _property_list_addendum = [
    # These fields should not be saved in .tscn files.
    {name = "h", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "s", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "v", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "a", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "r", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "g", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "b", type = TYPE_REAL, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    {name = "color", type = TYPE_COLOR, usage = PROPERTY_USAGE_NO_INSTANCE_STATE},
    # These fields should be saved in .tscn files.
    {name = "_color", type = TYPE_COLOR, usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM},
]

var r: float setget _set_r,_get_r
var g: float setget _set_g,_get_g
var b: float setget _set_b,_get_b
var color: Color setget _set_color,_get_color

var _h := TRANSPARENT.h
var _s := TRANSPARENT.s
var _v := TRANSPARENT.v
var _a := TRANSPARENT.a


func sample(_redirect_depth := 0) -> Color:
    return Color.from_hsv(_h, _s, _v, _a)


func _set_h(value: float) -> void:
    _h = value
func _set_s(value: float) -> void:
    _s = value
func _set_v(value: float) -> void:
    _v = value
func _set_a(value: float) -> void:
    _a = value

func _set_r(value: float) -> void:
    var color = sample()
    color.r = value
    _set_color(color)
func _set_g(value: float) -> void:
    var color = sample()
    color.g = value
    _set_color(color)
func _set_b(value: float) -> void:
    var color = sample()
    color.b = value
    _set_color(color)

func _get_h() -> float:
    return _h
func _get_s() -> float:
    return _s
func _get_v() -> float:
    return _v
func _get_a() -> float:
    return _a

func _get_r() -> float:
    return sample().r
func _get_g() -> float:
    return sample().g
func _get_b() -> float:
    return sample().b

func _set_color(value: Color) -> void:
    _h = value.h
    _s = value.s
    _v = value.v
    _a = value.a
func _get_color() -> Color:
    return sample()


func to_string() -> String:
    return ("StaticColorConfig(%s)") % str(sample())


func _get_property_list() -> Array:
    return _property_list_addendum

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

var _color := TRANSPARENT


func sample(_redirect_depth := 0) -> Color:
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

func _set_color(value: Color) -> void:
    _color = value
func _get_color() -> Color:
    return _color


func to_string() -> String:
    return ("StaticColorConfig(%s)") % str(_color)


func _get_property_list() -> Array:
    return _property_list_addendum

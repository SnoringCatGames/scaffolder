tool
class_name ColorConfig
extends Reference
## -   This provides a more powerful way of representing colors.[br]
## -   With PaletteColorConfig, you can reference a dynamic Color value[br]
##     according to its corresponding palette key. Then, the actual color[br]
##     can be changed, and a static Color representation will only be used[br]
##     when needed.[br]
## -   With HsvRangeColorConfig, you can define a range of color[br]
##     parameters, and then sample random colors within these parameters.[br]
## -   With any ColorConfig subclass, you can define overrides for hue,[br]
##     saturation, value, and alpha, and these overrides will apply on top[br]
##     of whichever color would otherwise have been returned from the subclass.


const ALPHA_SOLID := 1.0
const ALPHA_SLIGHTLY_FAINT := 0.7
const ALPHA_FAINT := 0.5
const ALPHA_XFAINT := 0.3
const ALPHA_XXFAINT := 0.1
const ALPHA_XXXFAINT := 0.03

const TRANSPARENT := Color(0.0, 0.0, 0.0, 0.0)

var h: float setget _set_h,_get_h
var s: float setget _set_s,_get_s
var v: float setget _set_v,_get_v
var a: float setget _set_a,_get_a


func sample(_redirect_depth := 0) -> Color:
    Sc.logger.error("Abstract ColorConfig.sample is not implemented.")
    return TRANSPARENT


func _set_h(value: float) -> void:
    Sc.logger.error("Abstract ColorConfig._set_h is not implemented.")
func _set_s(value: float) -> void:
    Sc.logger.error("Abstract ColorConfig._set_s is not implemented.")
func _set_v(value: float) -> void:
    Sc.logger.error("Abstract ColorConfig._set_v is not implemented.")
func _set_a(value: float) -> void:
    Sc.logger.error("Abstract ColorConfig._set_a is not implemented.")

func _get_h() -> float:
    Sc.logger.error("Abstract ColorConfig._get_h is not implemented.")
    return 0.0
func _get_s() -> float:
    Sc.logger.error("Abstract ColorConfig._get_s is not implemented.")
    return 0.0
func _get_v() -> float:
    Sc.logger.error("Abstract ColorConfig._get_v is not implemented.")
    return 0.0
func _get_a() -> float:
    Sc.logger.error("Abstract ColorConfig._get_a is not implemented.")
    return 0.0

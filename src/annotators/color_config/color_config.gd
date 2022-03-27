tool
class_name ColorConfig
extends Reference
## FIXME: ------------- Doc comment.


# FIXME: LEFT OFF HERE: ------------------
# - Incorporate opacify into this class.
#   - ACTUALLY, refactor this a bit.
#   - Define separate override fields for each component (hsva).
#   - These overrides could then apply to any of the ColorConfig subclasses.
# - Create the ColorPalette global.
# - Replace all of the different color systems I'd built-up previously with this new simpler system.
#   - ColorParams
#   - ColorParamsFactory
#   - Sc.colors
#   - Sc.colors.opacify
#   - SurfacerColors
#   - ScaffolderColors
#   - Sc.ann_params
#   - ScaffolderAnnotationParameters
#   - SurfacerAnnotationParameters
# - Update all references to the Sc.colors values in order to lazily access the
#   actual color as late as possible.
# - Refactor Sc.ann_params/ScaffolderAnnotationParameters/SurfacerAnnotationParameters
#   to instead use a big const dictionary with string keys.
#   - Then, I can dynamically populate the manifest defaults from this.
#   - Then, I can update _get_common_overrides_for_annotations_mode to be DRY.
# - I will need to create new editor widgets for my new ColorConfig type, and
#   for each of its subclasses.
#   - I might need to look into how other subclassed-type editors work, like
#     StyleBox...
# - Set up / register palette.

const _TRANSPARENT := Color(0.0, 0.0, 0.0, 0.0)

var h: float setget _set_h,_get_h
var s: float setget _set_s,_get_s
var v: float setget _set_v,_get_v
var a: float setget _set_a,_get_a


func sample() -> Color:
    Sc.logger.error("Abstract ColorConfig.sample is not implemented.")
    return _TRANSPARENT


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

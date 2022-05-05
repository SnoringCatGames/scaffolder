tool
class_name OutlineableAnimatedSprite, \
"res://addons/scaffolder/assets/images/editor_icons/outlineable_sprite.png"
extends AnimatedSprite
## -   This supports toggling an outline around the sprite, and changing the[br]
##     color of the outline.[br]
## -   TextureOutlineableSprite is more efficient than[br]
##     ShaderOutlineableSprite.[br]
##     -   By a factor of around x7, for a one-pixel border.[br]
## -   But using a separate outline texture is more work for the sprite[br]
##     author.[br]
## -   So shader-based outlines might be better for prototyping, or when you[br]
##     know you won't be rendering too many outlined sprites simultaneously.[br]


export var is_outlined := false setget _set_is_outlined
export var outline_color := Color.black setget _set_outline_color
export var is_desaturatable := true setget _set_is_desaturatable


func _ready() -> void:
    _set_is_desaturatable(is_desaturatable)


func _set_is_outlined(value: bool) -> void:
    is_outlined = value
    _update_outline()


func _set_outline_color(value: Color) -> void:
    outline_color = value
    _update_outline()


func _set_is_desaturatable(value: bool) -> void:
    Sc.logger.error(
        "Abstract OutlineableAnimatedSprite._set_is_desaturatable " +
        "is not implemented")


func _update_outline() -> void:
    Sc.logger.error(
            "Abstract OutlineableAnimatedSprite._update_outline " +
            "is not implemented")

tool
class_name OutlineableSprite, \
"res://addons/scaffolder/assets/images/editor_icons/outlineable_sprite.png"
extends Sprite
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


func _set_is_outlined(value: bool) -> void:
    is_outlined = value
    _update_outline()


func _set_outline_color(value: Color) -> void:
    outline_color = value
    _update_outline()


func _update_outline() -> void:
    Sc.logger.error(
            "Abstract OutlineableSprite._update_outline is not implemented")
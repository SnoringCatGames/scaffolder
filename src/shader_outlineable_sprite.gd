tool
class_name ShaderOutlineableSprite, \
"res://addons/scaffolder/assets/images/editor_icons/outlineable_sprite.png"
extends OutlineableSprite
## -   This supports toggling an outline around the sprite, and changing the[br]
##     color of the outline.[br]
## -   This implementation of OutlineableSprite uses a shader to render the 
##     outline.[br]
## -   TextureOutlineableSprite is more efficient than[br]
##     ShaderOutlineableSprite.[br]
##     -   By a factor of around x7, for a one-pixel border.[br]
## -   But using a separate outline texture is more work for the sprite[br]
##     author.[br]
## -   So shader-based outlines might be better for prototyping, or when you[br]
##     know you won't be rendering too many outlined sprites simultaneously.[br]


const PIXELATED_OUTLINE_SHADER := \
        preload("res://addons/scaffolder/src/pixelated_outline.gdshader")
const ANTIALIASED_OUTLINE_SHADER := \
        preload("res://addons/scaffolder/src/antialiased_outline.gdshader")

export var is_antialiased := false setget _set_is_antialiased

var _outline_material: ShaderMaterial


func _init() -> void:
    _outline_material = ShaderMaterial.new()
    _outline_material.shader = PIXELATED_OUTLINE_SHADER
    


func _update_outline() -> void:
    # FIXME: LEFT OFF HERE: --------------------------------------------
    # - Toggle shader with is_outlined.
    # - Test shader auto-margin adding.
    # - Test other params.
    # - Remove extra sprite from bot animator.
    material.set_shader_param("color", outline_color)


func _set_is_antialiased(value: bool) -> void:
    is_antialiased = value
    _outline_material.shader = \
            ANTIALIASED_OUTLINE_SHADER if \
            is_antialiased else \
            PIXELATED_OUTLINE_SHADER

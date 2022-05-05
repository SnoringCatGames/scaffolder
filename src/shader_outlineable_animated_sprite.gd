tool
class_name ShaderOutlineableAnimatedSprite, \
"res://addons/scaffolder/assets/images/editor_icons/outlineable_animated_sprite.png"
extends OutlineableAnimatedSprite
## -   This supports toggling an outline around the sprite, and changing the[br]
##     color of the outline.[br]
## -   This implementation of OutlineableAnimatedSprite uses a shader to[br]
##     render the outline.[br]
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

export var thickness := 1.0 setget _set_thickness
export(int, "Diamond", "Circle", "Square") var pattern := 2 setget _set_pattern
export var is_inside := false setget _set_is_inside
export var adds_margins := false setget _set_adds_margins

var _outline_material: ShaderMaterial


func _init() -> void:
    _outline_material = ShaderMaterial.new()
    _outline_material.shader = PIXELATED_OUTLINE_SHADER


func _ready() -> void:
    _update_outline()


func _update_outline() -> void:
    _outline_material.shader = ANTIALIASED_OUTLINE_SHADER
    if is_outlined:
        if is_antialiased:
            _outline_material.shader = ANTIALIASED_OUTLINE_SHADER
        else:
            _outline_material.shader = PIXELATED_OUTLINE_SHADER
            _outline_material.set_shader_param("pattern", pattern)
            _outline_material.set_shader_param("is_inside", is_inside)
            _outline_material.set_shader_param("adds_margins", adds_margins)
        _outline_material.set_shader_param("color", outline_color)
        _outline_material.set_shader_param("thickness", thickness)
        self.material = _outline_material
    else:
        self.material = null


func _set_is_antialiased(value: bool) -> void:
    is_antialiased = value
    _update_outline()


func _set_outline_color(value: Color) -> void:
    outline_color = value
    _outline_material.set_shader_param("color", outline_color)


func _set_thickness(value: float) -> void:
    thickness = value
    _outline_material.set_shader_param("thickness", thickness)


func _set_pattern(value: int) -> void:
    pattern = value
    _outline_material.set_shader_param("pattern", pattern)


func _set_is_inside(value: bool) -> void:
    is_inside = value
    _outline_material.set_shader_param("is_inside", is_inside)


func _set_adds_margins(value: bool) -> void:
    adds_margins = value
    _outline_material.set_shader_param("adds_margins", adds_margins)


func _set_is_desaturatable(value: bool) -> void:
    is_desaturatable = value
    if is_desaturatable:
        self.add_to_group(Sc.slow_motion.GROUP_NAME_DESATURATABLES)
    else:
        if self.is_in_group(Sc.slow_motion.GROUP_NAME_DESATURATABLES):
            self.remove_from_group(Sc.slow_motion.GROUP_NAME_DESATURATABLES)

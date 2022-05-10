class_name OutlineableSpriteRadialMenuItem
extends RadialMenuItem


## -   Optional
## -   If omitted, then ShaderOutlineableSprite will be used instead.
var outlined_texture: Texture

var _sprite: OutlineableSprite


func _create_item_level_control() -> ShapedLevelControl:
    var control := ShapedLevelControl.new()
    _sprite = _create_outlineable_sprite()
    control.add_child(_sprite)
    return control


func _create_outlineable_sprite() -> OutlineableSprite:
    var sprite: OutlineableSprite
    if is_instance_valid(outlined_texture):
        sprite = TextureOutlineableSprite.new()
        sprite.normal_texture = texture
        sprite.outlined_texture = outlined_texture
    else:
        sprite = ShaderOutlineableSprite.new()
        sprite.texture = texture
    sprite.scale = \
            Vector2.ONE * \
            Sc.gui.hud.radial_menu_item_radius * 2.0 / \
            texture.get_size() * \
            Sc.gui.scale
    return sprite


func _interpolate_item_hover(progress: float) -> void:
    ._interpolate_item_hover(progress)
    
    var scale: float = lerp(
            1.0, Sc.gui.hud.radial_menu_item_hovered_scale, progress)
    
    var normal_color: Color = \
            Sc.gui.hud.radial_menu_item_normal_color_modulate.sample()
    var hovered_color: Color = \
            Sc.gui.hud.radial_menu_item_hover_color_modulate.sample()
    var color: Color = lerp(normal_color, hovered_color, progress)
    
    if disabled_message != "":
        scale = 1.0
        color = Sc.gui.hud.radial_menu_item_disabled_color_modulate.sample()
    
    _sprite.scale = \
            Vector2.ONE * \
            scale * \
            Sc.gui.hud.radial_menu_item_radius * 2.0 / \
            texture.get_size() * \
            Sc.gui.scale
    _sprite.outline_color = color


func _set_disabled_message(value: String) -> void:
    ._set_disabled_message(value)
    _interpolate_item_hover(0.0)

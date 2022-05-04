class_name SpriteModulationRadialMenuItem
extends RadialMenuItem


const _SPRITE_MODULATION_BUTTON_SCENE := preload(
    "res://addons/scaffolder/src/gui/level_button/sprite_modulation_button.tscn")


func _create_item_level_control() -> ShapedLevelControl:
    var control: SpriteModulationButton = \
        _SPRITE_MODULATION_BUTTON_SCENE.instance()
    control.texture = texture
    control.normal_modulate = ColorFactory.palette("highlight_green")
    control.hover_modulate = ColorFactory.palette("highlight_light_blue")
    control.pressed_modulate = ColorFactory.palette("highlight_light_blue")
    control.disabled_modulate = ColorFactory.palette("highlight_disabled")
    control.alpha_multiplier = 0.999
    control.sprite_scale = \
        Vector2.ONE * \
        Sc.gui.hud.radial_menu_item_radius * 2.0 / \
        texture.get_size() * \
        Sc.gui.scale
    return control


func _interpolate_item_hover(progress: float) -> void:
    ._interpolate_item_hover(progress)
    var hovered_scale: float = lerp(
        1.0, Sc.gui.hud.radial_menu_item_hovered_scale, progress)
    _control.sprite_scale = \
        Vector2.ONE * \
        hovered_scale * \
        Sc.gui.hud.radial_menu_item_radius * 2.0 / \
        texture.get_size() * \
        Sc.gui.scale

class_name SpriteModulationRadialMenuItem
extends RadialMenuItem


const _SPRITE_MODULATION_BUTTON_SCENE := preload(
    "res://addons/scaffolder/src/gui/level_button/sprite_modulation_button.tscn")


func _create_item_level_control() -> ShapedLevelControl:
    var control: SpriteModulationButton = \
        _SPRITE_MODULATION_BUTTON_SCENE.instance()
    control.texture = texture
    control.normal_modulate = \
        Sc.gui.hud.radial_menu_item_normal_color_modulate
    control.hover_modulate = \
        Sc.gui.hud.radial_menu_item_hover_color_modulate
    control.pressed_modulate = \
        Sc.gui.hud.radial_menu_item_hover_color_modulate
    control.disabled_modulate = \
        Sc.gui.hud.radial_menu_item_disabled_color_modulate
    control.alpha_multiplier = 0.999
    return control

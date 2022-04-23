tool
class_name SpriteModulationButton, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_texture_button.png"
extends LevelButton


const _DEFAULT_NORMAL_MODULATE := Color("cc6abe30")
const _DEFAULT_HOVER_MODULATE := Color("ff1cb0ff")
const _DEFAULT_PRESSED_MODULATE := Color("cc003066")
const _DEFAULT_DISABLED_MODULATE := Color("77292929")
#const _DEFAULT_ERROR_MODULATE := Color("ffcc2c16")

export var texture: Texture setget _set_texture,_get_texture

export var normal_modulate := _DEFAULT_NORMAL_MODULATE \
        setget _set_normal_modulate
export var hover_modulate := _DEFAULT_HOVER_MODULATE \
        setget _set_hover_modulate
export var pressed_modulate := _DEFAULT_PRESSED_MODULATE \
        setget _set_pressed_modulate
export var disabled_modulate := _DEFAULT_DISABLED_MODULATE \
        setget _set_disabled_modulate
export var alpha_multiplier := -1.0 \
        setget _set_alpha_multiplier


func _update() -> void:
    ._update()
    assert(shape_is_rectangular)


func _update_modulation() -> void:
    if !_is_ready:
        return
    
    match interaction_mode:
        InteractionMode.NORMAL:
            $Sprite.modulate = normal_modulate
        InteractionMode.HOVER:
            $Sprite.modulate = hover_modulate
        InteractionMode.PRESSED:
            $Sprite.modulate = pressed_modulate
        InteractionMode.DISABLED:
            $Sprite.modulate = disabled_modulate
        _:
            Sc.logger.error(
                "SpriteModulationButton._on_interaction_mode_changed: %s" % \
                str(interaction_mode))
    
    if alpha_multiplier >= 0.0:
        $Sprite.modulate.a *= alpha_multiplier


func _on_interaction_mode_changed(interaction_mode: int) -> void:
#    Sc.logger.print(
#            "_on_interaction_mode_changed: %s" % \
#            get_interaction_mode_string(interaction_mode))
    _update_modulation()


func _set_texture(value: Texture) -> void:
    $Sprite.texture = value


func _get_texture() -> Texture:
    return $Sprite.texture


func _set_normal_modulate(value: Color) -> void:
    normal_modulate = value
    _update_modulation()


func _set_hover_modulate(value: Color) -> void:
    hover_modulate = value
    _update_modulation()


func _set_pressed_modulate(value: Color) -> void:
    pressed_modulate = value
    _update_modulation()


func _set_disabled_modulate(value: Color) -> void:
    disabled_modulate = value
    _update_modulation()


func _set_alpha_multiplier(value: float) -> void:
    alpha_multiplier = value
    _update_modulation()

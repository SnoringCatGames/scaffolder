tool
class_name SpriteModulationButton, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_texture_button.png"
extends LevelButton


var texture: Texture setget _set_texture
var sprite_scale := Vector2.ONE setget _set_sprite_scale

var normal_modulate := ColorFactory.palette("highlight_green") \
        setget _set_normal_modulate
var hover_modulate := ColorFactory.palette("highlight_light_blue") \
        setget _set_hover_modulate
var pressed_modulate := ColorFactory.palette("highlight_dark_blue") \
        setget _set_pressed_modulate
var disabled_modulate := ColorFactory.palette("highlight_disabled") \
        setget _set_disabled_modulate
var alpha_multiplier := -1.0 \
        setget _set_alpha_multiplier

const _PROPERTY_LIST_ADDENDUM := [
    {
        name = "texture",
        type = TYPE_OBJECT,
        hint = PROPERTY_HINT_RESOURCE_TYPE,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
        hint_string = "Texture",
    },
    {
        name = "normal_modulate",
        type = TYPE_OBJECT,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
        hint = ScaffolderPropertyHint.PROPERTY_HINT_COLOR_CONFIG,
    },
    {
        name = "hover_modulate",
        type = TYPE_OBJECT,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
        hint = ScaffolderPropertyHint.PROPERTY_HINT_COLOR_CONFIG,
    },
    {
        name = "pressed_modulate",
        type = TYPE_OBJECT,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
        hint = ScaffolderPropertyHint.PROPERTY_HINT_COLOR_CONFIG,
    },
    {
        name = "disabled_modulate",
        type = TYPE_OBJECT,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
        hint = ScaffolderPropertyHint.PROPERTY_HINT_COLOR_CONFIG,
    },
    {
        name = "alpha_multiplier",
        type = TYPE_REAL,
        usage = Utils.PROPERTY_USAGE_EXPORTED_ITEM,
    },
]


func _get_property_list() -> Array:
    return _PROPERTY_LIST_ADDENDUM


func _ready() -> void:
    _set_texture(texture)
    _set_sprite_scale(sprite_scale)
    _update_modulation()


func _update_shape() -> void:
    ._update_shape()
    # FIXME: LEFT OFF HERE: --------------------------------
#    assert(shape_is_rectangular)


func _update_modulation() -> void:
    if !_is_ready:
        return
    
    match interaction_mode:
        InteractionMode.NORMAL:
            $Sprite.modulate = normal_modulate.sample()
        InteractionMode.HOVER:
            $Sprite.modulate = hover_modulate.sample()
        InteractionMode.PRESSED:
            $Sprite.modulate = pressed_modulate.sample()
        InteractionMode.DISABLED:
            $Sprite.modulate = disabled_modulate.sample()
        _:
            Sc.logger.error(
                "SpriteModulationButton._on_interaction_mode_changed: %s" % \
                str(interaction_mode))
    
    if alpha_multiplier >= 0.0:
        $Sprite.modulate.a *= alpha_multiplier


func _on_interaction_mode_changed(interaction_mode: int) -> void:
    ._on_interaction_mode_changed(interaction_mode)
#    Sc.logger.print(
#            "_on_interaction_mode_changed: %s" % \
#            get_interaction_mode_string(interaction_mode))
    _update_modulation()


func _set_sprite_scale(value: Vector2) -> void:
    sprite_scale = value
    if !_is_ready:
        return
    $Sprite.scale = value


func _set_texture(value: Texture) -> void:
    texture = value
    if !_is_ready:
        return
    $Sprite.texture = value


func _set_normal_modulate(value: ColorConfig) -> void:
    normal_modulate = value
    _update_modulation()


func _set_hover_modulate(value: ColorConfig) -> void:
    hover_modulate = value
    _update_modulation()


func _set_pressed_modulate(value: ColorConfig) -> void:
    pressed_modulate = value
    _update_modulation()


func _set_disabled_modulate(value: ColorConfig) -> void:
    disabled_modulate = value
    _update_modulation()


func _set_alpha_multiplier(value: float) -> void:
    alpha_multiplier = value
    _update_modulation()

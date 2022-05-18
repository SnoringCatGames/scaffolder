tool
class_name SpriteModulationButton, \
"res://addons/scaffolder/assets/images/editor_icons/sprite_modulation_button.png"
extends LevelButton


var texture: Texture setget _set_texture

var normal_modulate := ColorFactory.palette("modulation_button_normal") \
        setget _set_normal_modulate
var hover_modulate := ColorFactory.palette("modulation_button_hover") \
        setget _set_hover_modulate
var pressed_modulate := ColorFactory.palette("modulation_button_pressed") \
        setget _set_pressed_modulate
var disabled_modulate := ColorFactory.palette("modulation_button_disabled") \
        setget _set_disabled_modulate
var alpha_multiplier := -1.0 setget _set_alpha_multiplier

var saturation := 1.0 setget _set_saturation

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
    _update_modulation()


func _update_shape() -> void:
    ._update_shape()
    
    if !_is_ready:
        return
    
    var sprite_scale: Vector2
    if shape_is_rectangular:
        sprite_scale = shape_rectangle_extents * 2.0 / texture.get_size()
    else:
        sprite_scale = \
            Vector2.ONE * shape_circle_radius * 2.0 / texture.get_size()
    $Sprite.scale = sprite_scale


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
    
    $Sprite.modulate.s *= saturation


func _on_interaction_mode_changed(interaction_mode: int) -> void:
    ._on_interaction_mode_changed(interaction_mode)
#    Sc.logger.print(
#            "_on_interaction_mode_changed: %s" % \
#            get_interaction_mode_string(interaction_mode))
    _update_modulation()


func _set_is_desaturatable(value: bool) -> void:
    is_desaturatable = value
    if value:
        self.add_to_group(Sc.slow_motion \
            .GROUP_NAME_NON_SHADER_BASED_DESATURATABLES)
    else:
        if self.is_in_group(Sc.slow_motion \
            .GROUP_NAME_NON_SHADER_BASED_DESATURATABLES):
            self.remove_from_group(Sc.slow_motion \
                .GROUP_NAME_NON_SHADER_BASED_DESATURATABLES)


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


func _set_saturation(value: float) -> void:
    saturation = value
    _update_modulation()


func _set_is_disabled(value: bool) -> void:
    ._set_is_disabled(value)
    _update_modulation()

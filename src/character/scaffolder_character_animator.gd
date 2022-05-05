tool
class_name ScaffolderCharacterAnimator, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_character_animator.png"
extends Node2D
## -   This defines how your character is rendered and animated.[br]
## -   Scaffolder makes some opinionated assumptions about how this will be
##     set-up, but you can probably adjust or ignore some of this to fit your
##     needs.[br]


const UNFLIPPED_HORIZONTAL_SCALE := Vector2(1, 1)
const FLIPPED_HORIZONTAL_SCALE := Vector2(-1, 1)

## Toggle this according to how you've defined the character art.
export var faces_right_by_default := true

## -   Set this export property to `true` if you want to set up all of the
##     animations for this character by changing the `frame` property on a
##     corresponding `Sprite`.[br]
## -   If this is enabled, then the `ScaffolderCharacterAnimator` will expect there
##     to be a one-to-one mapping between immediate-child `Sprites` and
##     animations in the `AnimationPlayer`, and these matching animations and
##     Sprites will need to share the same names.[br]
export var uses_standard_sprite_frame_animations := true \
        setget _set_uses_standard_sprite_frame_animations

## -   Set this to `true` if you want to be able to toggle whether your[br]
##     character has an outline.[br]
## -   However, you have to create the images for this outline![br]
## -   That means you'll need to create a separate copy of all character[br]
##     spritesheets to include this outline.[br]
## -   These separate copies will need to have the same path and filename but
##     with the suffix "_outline".[br]
## -   You will need to use the OutlineableSprite scene to define these
##     Sprites.[br]
export var includes_outlined_versions_of_sprites := true \
        setget _set_includes_outlined_versions_of_sprites

## -   This `Dictionary` is auto-populated with keys corresponding to each
##     animation in the `AnimationPlayer`.[br]
## -   You can configure some additional state for each of the animation
##     configs in this dictionary, such as the default playback speed for the
##     animation, and the name of a `Sprite` to automatically show when
##     starting the animation.[br]
## [br]
## Array<{[br]
##   # This must match an animation in the AnimationPlayer.[br]
##   name: String,[br]
##   [br]
##   # -   Optional.[br]
##   # -   Use this if the animation is based on `Sprite.frame`.[br]
##   # -   This must match the name of a child Sprite.[br]
##   sprite_name: String,[br]
##   [br]
##   # The playback rate for the animation.[br]
##   speed: float,[br]
## }>[br]
export var animations := {} setget _set_animations

export var is_outlined := false setget _set_is_outlined

export var outline_color := Color.black setget _set_outline_color

var is_desaturatable := false setget _set_is_desaturatable

var animation_player: AnimationPlayer
# Array<Sprite>
var _sprites := []

var _specific_name := "Rest"
# The AnimationPlayer implementation could use different animation names from
# the "standard" set that are referenced in framework logic. We need to track
# both versions, in these cases.
# For example, the "standard" animations "ClimbUp" and "ClimbDown" could be
# implemented as a single "Climb" animation with different playback rates on
# the underlying AnimationPlayer.
var _standard_name := "Rest"
var _base_rate := 1.0

var _latest_blend_duration := 0.0

var _is_ready := false
var _configuration_warning := ""

var _debounced_update_editor_configuration: FuncRef


func _enter_tree() -> void:
    # Populate these references immediately, since _update_editor_configuration
    # is debounced.
    var animation_players: Array = Sc.utils.get_children_by_type(
            self, AnimationPlayer)
    if !animation_players.empty():
        animation_player = animation_players[0]
    _sprites = Sc.utils.get_children_by_type(self, Sprite)
    
    if Engine.editor_hint:
        return
    
    Sc.slow_motion.add_animator(self)
    _update_editor_configuration()


func _ready() -> void:
    _is_ready = true
    _debounced_update_editor_configuration = Sc.time.debounce(
            self,
            "_update_editor_configuration_debounced",
            0.02,
            false)
    _update_editor_configuration()


func _exit_tree() -> void:
    Sc.slow_motion.remove_animator(self)


func _destroy() -> void:
    Sc.slow_motion.remove_animator(self)
    if !is_queued_for_deletion():
        queue_free()


func add_child(child: Node, legible_unique_name := false) -> void:
    .add_child(child, legible_unique_name)
    _update_editor_configuration()


func remove_child(child: Node) -> void:
    .remove_child(child)
    _update_editor_configuration()


func _update_editor_configuration() -> void:
    if !_is_ready:
        return
    _debounced_update_editor_configuration.call_func()


func _update_editor_configuration_debounced() -> void:
    if !_is_ready:
        return
    
    if !Sc.utils.check_whether_sub_classes_are_tools(self):
        _set_configuration_warning(
                "Subclasses of AnimationPlayer must be marked as tool.",
                true)
        return
    
    # Get AnimationPlayer from scene configuration.
    var animation_players: Array = Sc.utils.get_children_by_type(
            self, AnimationPlayer)
    if animation_players.size() > 1:
        _set_configuration_warning(
                "Must only define a single AnimationPlayer child node.")
        return
    elif animation_players.size() < 1:
        _set_configuration_warning(
                "Must define an AnimationPlayer child node.")
        return
    animation_player = animation_players[0]
    
    # Make a set of the animation names from the AnimationPlayer.
    var current_animation_names := animation_player.get_animation_list()
    var current_animations := {}
    
    # Add new animation configs.
    for animation_name in current_animation_names:
        current_animations[animation_name] = true
        if !animations.has(animation_name):
            animations[animation_name] = {
                name = animation_name,
                sprite_name = "",
                speed = 1.0,
            }
    
    # Remove old animation configs.
    var animations_to_remove := []
    for animation_name in animations:
        if !current_animations.has(animation_name):
            animations_to_remove.push_back(animation_name)
    for animation_name in animations_to_remove:
        animations.erase(animation_name)
    
    if uses_standard_sprite_frame_animations:
        # Auto-populate each animation config's `sprite_name` to match `name`.
        for animation_config in animations.values():
            animation_config.sprite_name = animation_config.name
    
    _sprites = Sc.utils.get_children_by_type(self, Sprite)
    
    # Ensure that each animation config sprite_name matches a corresponding
    # Sprite.
    if uses_standard_sprite_frame_animations:
        var animations_list := animations.values()
        for i in animations_list.size():
            var animation_name: String = animations_list[i].name
            var sprite_name: String = \
                    animations[animation_name].sprite_name
            if sprite_name != "":
                if !has_node(sprite_name):
                    _set_configuration_warning(
                            ("No immediate child matches sprite_name: " +
                            "sprite_name=%s, name=%s, index=%s.") % 
                            [sprite_name, animation_name, i])
                    return
                elif !(get_node(sprite_name) is Sprite):
                    _set_configuration_warning(
                            "Child matching sprite_name is not a Sprite: %s" %
                            sprite_name)
                    return
    
    if includes_outlined_versions_of_sprites and \
            !uses_standard_sprite_frame_animations:
        _set_configuration_warning(
                "The default outlining system requires " +
                "uses_standard_sprite_frame_animations to be true.")
        return
    if is_outlined and !includes_outlined_versions_of_sprites:
        _set_configuration_warning(
                "is_outlined cannot be true if " +
                "includes_outlined_versions_of_sprites is false.")
        return
    if includes_outlined_versions_of_sprites:
        for sprite in _sprites:
            if !sprite is OutlineableSprite:
                _set_configuration_warning(
                        "includes_outlined_versions_of_sprites is true, but " +
                        "not all Sprites are OutlineableSprites.")
                return
    
    property_list_changed_notify()
    _set_configuration_warning("")


func _set_configuration_warning(
        value: String,
        also_logs_error := false) -> void:
    _configuration_warning = value
    update_configuration_warning()
    if also_logs_error:
        Sc.logger.error(value)


func _get_configuration_warning() -> String:
    return _configuration_warning


func face_left() -> void:
    var scale := \
            FLIPPED_HORIZONTAL_SCALE if \
            faces_right_by_default else \
            UNFLIPPED_HORIZONTAL_SCALE
    self.scale = scale


func face_right() -> void:
    var scale := \
            UNFLIPPED_HORIZONTAL_SCALE if \
            faces_right_by_default else \
            FLIPPED_HORIZONTAL_SCALE
    self.scale = scale


func play(animation_name: String) -> void:
    _play_animation(animation_name)


func set_static_frame(animation_state: CharacterAnimationState) -> void:
    var standard_name := animation_state.animation_name
    var specific_name := \
            _standand_animation_name_to_specific_animation_name(standard_name)
    
    if uses_standard_sprite_frame_animations:
        _show_sprite_exclusively(specific_name)
    
    _standard_name = standard_name
    _specific_name = specific_name
    
    var playback_rate := animation_name_to_playback_rate(standard_name)
    var position := animation_state.animation_position * playback_rate
    
    if animation_state.facing_left:
        face_left()
    else:
        face_right()
    
    animation_player.play(_specific_name)
    animation_player.seek(position, true)
    animation_player.stop(false)


func set_static_frame_position(animation_position: float) -> void:
    var playback_rate := animation_name_to_playback_rate(_standard_name)
    var position := animation_position * playback_rate
    animation_player.seek(position, true)


func match_rate_to_time_scale() -> void:
    if is_instance_valid(animation_player):
        animation_player.playback_speed = \
                _base_rate * Sc.time.get_combined_scale()


func get_current_animation_name() -> String:
    return _standard_name


func set_modulation(modulation: Color) -> void:
    self.modulate = modulation


func _play_animation(
        standard_name: String,
        blend := 0.1) -> bool:
    _standard_name = standard_name
    _specific_name = \
            _standand_animation_name_to_specific_animation_name(_standard_name)
    
    var is_current_animator := \
            animation_player.current_animation == _specific_name
    var is_playing := animation_player.is_playing()
    var animation_is_already_playing := is_current_animator and is_playing
    
    _base_rate = animation_name_to_playback_rate(_standard_name)
    var is_changing_direction := \
            (animation_player.get_playing_speed() < 0) != (_base_rate < 0)
    var is_animation_already_playing_in_correct_direction := \
            is_current_animator and !is_changing_direction
    
    if !animation_is_already_playing and \
            uses_standard_sprite_frame_animations:
        _show_sprite_exclusively(_specific_name)
    
    if animation_is_already_playing and \
            is_animation_already_playing_in_correct_direction:
        false
    
    _latest_blend_duration = blend
    animation_player.play(_specific_name, blend)
    match_rate_to_time_scale()
    return true


func skip_current_blend() -> void:
    var animation_name := animation_player.current_animation
    var playback_speed := animation_player.playback_speed
    animation_player.stop(true)
    animation_player.clear_queue()


func _show_sprite_exclusively(specific_name: String) -> void:
    # Hide the other sprites.
    for sprite in _sprites:
        sprite.visible = false
    
    # Show the current sprite.
    var sprite := _animation_name_to_sprite(specific_name)
    sprite.visible = true


func _animation_name_to_sprite(specific_name: String) -> Sprite:
    if uses_standard_sprite_frame_animations:
        return get_node(specific_name) as Sprite
    else:
        Sc.logger.error(
                "The default implementation of " +
                "ScaffolderCharacterAnimator._animation_name_to_sprite only " +
                "works when uses_standard_sprite_frame_animations is true.")
        return null


func animation_name_to_playback_rate(standard_name: String) -> float:
    var specific_name := \
            _standand_animation_name_to_specific_animation_name(standard_name)
    return animations[specific_name].speed


# By default, this does nothing.
func _standand_animation_name_to_specific_animation_name(
        standard_name: String) -> String:
    return standard_name


func _set_uses_standard_sprite_frame_animations(value: bool) -> void:
    uses_standard_sprite_frame_animations = value
    if !uses_standard_sprite_frame_animations:
        # Clear each animation config's `sprite_name`.
        for animation_config in animations.values():
            animation_config.sprite_name = ""
    _update_editor_configuration()


func _set_includes_outlined_versions_of_sprites(value: bool) -> void:
    includes_outlined_versions_of_sprites = value
    _update_editor_configuration()


func _set_animations(value: Dictionary) -> void:
    animations = value
    _update_editor_configuration()


# Register as desaturatable for the slow-motion effect.
func _set_is_desaturatable(value: bool) -> void:
    is_desaturatable = value
    var sprites: Array = Sc.utils.get_children_by_type(self, Sprite, true)
    for sprite in sprites:
        Sc.utils.set_is_desaturatable(sprite, is_desaturatable)


func _set_is_outlined(value: bool) -> void:
    is_outlined = value
    _update_outlines()


func _set_outline_color(value: Color) -> void:
    outline_color = value
    _update_outlines()


func _update_outlines() -> void:
    for sprite in _sprites:
        sprite.is_outlined = is_outlined
        sprite.outline_color = outline_color

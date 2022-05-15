tool
class_name ScaffolderCharacter, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_character.png"
extends KinematicBody2D


const _RECENT_LOGS_COUNT_TO_STORE_ON_CHARACTER_INSTANCE := 20

# ---

export var character_name := "" setget _set_character_name

## -   This helps your `ScaffolderCharacter` detect when other areas or bodies
##     collide with the character.[br]
## -   The default `PhysicsBody2D.collision_layer` property is limited, because
##     the `move_and_slide` system will adjust our movement when we collide
##     with matching objects.[br]
## -   So this separate `collision_detection_layers` property lets us detect
##     collisions without adjusting our movement.[br]
export(int, LAYERS_2D_PHYSICS) var collision_detection_layers := 0

export var detects_pointer := true setget _set_detects_pointer

export var pointer_screen_radius := 40.0 setget _set_pointer_screen_radius
export var pointer_distance_squared_offset_for_selection_priority := 40.0 \
    setget _set_pointer_distance_squared_offset_for_selection_priority

# --- Colors ---

const _COLORS_GROUP := {
    group_name = "Colors",
    first_property_name = "primary_annotation_color",
    last_property_name = "position_annotation_color_override",
    overrides = {
        primary_annotation_color = \
            {hint = ScaffolderPropertyHint.PROPERTY_HINT_COLOR_CONFIG},
        secondary_annotation_color = \
            {hint = ScaffolderPropertyHint.PROPERTY_HINT_COLOR_CONFIG},
        navigation_annotation_color_override = \
            {hint = ScaffolderPropertyHint.PROPERTY_HINT_COLOR_CONFIG},
        position_annotation_color_override = \
            {hint = ScaffolderPropertyHint.PROPERTY_HINT_COLOR_CONFIG},
    },
}

## Used for things like the fill-color of exclamation-mark annotations.
var primary_annotation_color := ColorFactory.palette("black")
## Used for things like the border-color of exclamation-mark annotations.
var secondary_annotation_color := ColorFactory.palette("white")
## -   Used for things like the navigation trajectory annotation.
## -   If not defined, then primary_annotation_color will be used for this.
var navigation_annotation_color_override := ColorFactory.palette("black")
## -   Used for things like the character position annotation.
## -   If not defined, then primary_annotation_color will be used for this.
var position_annotation_color_override := ColorFactory.palette("black")

var navigation_annotation_color: ColorConfig \
    setget ,_get_navigation_annotation_color
var position_annotation_color: ColorConfig \
    setget ,_get_position_annotation_color

# --- Exclamation mark ---

const _EXCLAMATION_MARK_GROUP := {
    group_name = "Exclamation mark",
    first_property_name = "exclamation_mark_width_start",
    last_property_name = "exclamation_mark_throttle_interval",
}

var exclamation_mark_width_start := 4.0
var exclamation_mark_length_start := 24.0
var exclamation_mark_stroke_width_start := 1.2
var exclamation_mark_duration := 1.8
var exclamation_mark_throttle_interval := 1.0

# --- Logs ---

const _LOGS_GROUP := {
    group_name = "Logs",
    first_property_name = "logs_common_debugging_events",
    last_property_name = "stores_logs_on_character_instances",
}

## -   If true, a subset of the following log flags will be enabled.
## -   These logs are often useful for debugging.
var logs_common_debugging_events := false \
        setget _set_logs_common_debugging_events

## -   If true, custom character events will be printed.
var logs_custom_events := true \
        setget _set_logs_custom_events
## -   If true, behavior events will be printed.
var logs_behavior_events := false \
        setget _set_logs_behavior_events
## -   If true, navigator events will be printed.
var logs_navigator_events := false \
        setget _set_logs_navigator_events
## -   If true, non-surface collison events will be printed.
var logs_collision_events := false \
        setget _set_logs_collision_events
## -   If true, surface-interaction events will be printed.
var logs_surface_events := false \
        setget _set_logs_surface_events
## -   If true, action/input events will be printed.
var logs_action_events := false \
        setget _set_logs_action_events
## -   If true, lower-level framework events will be printed.
var logs_verbose_events := false \
        setget _set_logs_verbose_events
## -   If true, lower-level navigation events will be printed.
## -   These are pretty verbose!
var logs_verbose_navigator_events := false \
        setget _set_logs_verbose_navigator_events
## -   If ture, then all character logs will also be stored on their
##     corresponding character instance.
## -   This might be useful for debugging, but will take extra run-time space.
var stores_logs_on_character_instances := false \
        setget _set_stores_logs_on_character_instances
# ---

const _PROPERTY_GROUPS := [
    _COLORS_GROUP,
    _EXCLAMATION_MARK_GROUP,
    _LOGS_GROUP,
]

var category: ScaffolderCharacterCategory
var can_be_player_character := false setget set_can_be_player_character
var is_player_control_active: bool \
        setget set_is_player_control_active,_get_is_player_control_active
var _is_ready := false
var _is_destroyed := false

var _property_list_addendum := []
var _configuration_warning := ""

var velocity := Vector2.ZERO
var start_position := Vector2.INF
var previous_position := Vector2.INF
var did_move_last_frame := false

var collider := RotatedShape.new()
var collision_shape: CollisionShape2D
var animator: ScaffolderCharacterAnimator

var distance_travelled := INF

var start_time := INF
var previous_total_time := INF
var total_time := INF

var _extra_collision_detection_area: Area2D
# Dictionary<String, Area2D>
var _layers_for_entered_proximity_detection := {}
# Dictionary<String, Area2D>
var _layers_for_exited_proximity_detection := {}

var _pointer_detector: LevelControl

var _resized_character_name: String
var _recent_logs: CircularBuffer

var _debounced_update_editor_configuration: FuncRef
var _throttled_show_exclamation_mark: FuncRef

# ---


func _init() -> void:
    _property_list_addendum = \
            Sc.utils.get_property_list_for_contiguous_inspector_groups(
                    self, _PROPERTY_GROUPS)


func _enter_tree() -> void:
    _update_editor_configuration()


func _ready() -> void:
    _is_ready = true
    
    distance_travelled = 0.0
    start_time = Sc.time.get_scaled_play_time()
    total_time = 0.0
    
    start_position = position
    _debounced_update_editor_configuration = Sc.time.debounce(
            self,
            "_update_editor_configuration_debounced",
            0.02,
            true)
    _throttled_show_exclamation_mark = Sc.time.throttle(
            self,
            "_show_exclamation_mark_throttled",
            exclamation_mark_throttle_interval,
            false,
            TimeType.PLAY_PHYSICS_SCALED)
    
    _update_editor_configuration_debounced()
    _initialize_children_proximity_detectors()
    
    if Engine.editor_hint:
        return
    
    # Start facing right.
    animator.face_right()
    
    var collision_detection_layer_names: Array = \
            Sc.utils.get_physics_layer_names_from_bitmask(
                    collision_detection_layers)
    for layer_name in collision_detection_layer_names:
        _add_layer_for_collision_detection(layer_name)
    
    Sc.device.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _destroy() -> void:
    _is_destroyed = true
    if is_instance_valid(animator):
        animator._destroy()
    if is_instance_valid(_pointer_detector):
        _pointer_detector._destroy()
    Sc.annotators.destroy_character_annotator(self)
    if !is_queued_for_deletion():
        queue_free()


func _on_resized() -> void:
    pass


func _on_annotators_ready() -> void:
    pass


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
    if !Sc.utils.check_whether_sub_classes_are_tools(self):
        _set_configuration_warning(
                "Subclasses of ScaffolderCharacter must be marked as tool.")
        return
    
    if character_name == "":
        _set_configuration_warning("Must define character_name.")
        return
    elif Sc.characters.categories.has(character_name):
        _set_configuration_warning(
                "There is already a character category registered in the " + \
                "app manifest with this character_name.")
        return
    
    # Get AnimationPlayer from scene configuration.
    if !is_instance_valid(animator):
        var character_animators: Array = Sc.utils.get_children_by_type(
                self,
                ScaffolderCharacterAnimator)
        if character_animators.size() > 1:
            _set_configuration_warning(
                    "Must only define a single ScaffolderCharacterAnimator " +
                    "child node.")
            return
        elif character_animators.size() < 1:
            _set_configuration_warning(
                    "Must define a ScaffolderCharacterAnimator-subclass " +
                    "child node.")
            return
        animator = character_animators[0]
        animator.is_desaturatable = true
    
    if !is_instance_valid(collision_shape):
        collision_shape = Sc.utils.get_child_by_type(self, CollisionShape2D)
        if is_instance_valid(collision_shape):
            collider.update(collision_shape.shape, collision_shape.rotation)
            _update_pointer_detector()
            # Ensure that collision boundaries are only ever axially aligned.
            if !collider.is_axially_aligned:
                _set_configuration_warning(
                        "CollisionShape2D rotation must be 0 or 90.")
                return
        else:
            collider.reset()
    
    _set_configuration_warning("")


func _set_configuration_warning(value: String) -> void:
    if !_is_ready:
        return
    _configuration_warning = value
    update_configuration_warning()
    property_list_changed_notify()
    if value != "" and \
            !Engine.editor_hint:
        Sc.logger.error(value)


func _get_configuration_warning() -> String:
    return _configuration_warning


# NOTE: _get_property_list **appends** to the default list of properties.
#       It does not replace.
func _get_property_list() -> Array:
    return _property_list_addendum


func _initialize_children_proximity_detectors() -> void:
    # Get ProximityDetectors from scene configuration.
    for detector in Sc.utils.get_children_by_type(self, ProximityDetector):
        if detector.is_detecting_enter:
            _add_layer_for_entered_shape_proximity_detection(
                    detector.get_layer_names(),
                    detector.shape,
                    detector.rotation)
        if detector.is_detecting_exit:
            _add_layer_for_exited_shape_proximity_detection(
                    detector.get_layer_names(),
                    detector.shape,
                    detector.rotation)


func set_can_be_player_character(value: bool) -> void:
    can_be_player_character = value


func set_is_player_control_active(
        value: bool,
        should_also_update_level := true) -> void:
    assert(!value or can_be_player_character)
    
    if value:
        self.add_to_group(Sc.characters.GROUP_NAME_PLAYERS)
        if self.is_in_group(Sc.characters.GROUP_NAME_NPCS):
            self.remove_from_group(Sc.characters.GROUP_NAME_NPCS)
    else:
        self.add_to_group(Sc.characters.GROUP_NAME_NPCS)
        if self.is_in_group(Sc.characters.GROUP_NAME_PLAYERS):
            self.remove_from_group(Sc.characters.GROUP_NAME_PLAYERS)
    
    if should_also_update_level:
        if value:
            if Sc.level.active_player_character != self:
                Sc.level.active_player_character = self
        else:
            if Sc.level.active_player_character == self:
                Sc.level.active_player_character = null


func _get_is_player_control_active() -> bool:
    return Sc.characters.get_active_player_character() == self


func _physics_process(delta: float) -> void:
    if !_is_ready or \
            _is_destroyed or \
            Engine.editor_hint:
        return
    
    previous_total_time = total_time
    total_time = Sc.time.get_scaled_play_time() - start_time
    
    previous_position = position
    _on_physics_process(delta)
    did_move_last_frame = !Sc.geometry.are_points_equal_with_epsilon(
            previous_position, position, 0.00001)
    
    distance_travelled += position.distance_to(previous_position)


func _on_physics_process(delta: float) -> void:
    _process_animation()
    _process_sounds()


func _process_animation() -> void:
    pass


func _process_sounds() -> void:
    pass


## Conditionally prints the given message, depending on the character's
## configuration.
## 
## -   message should be no more than 12 characters long.
func _log(
        message: String,
        details := "",
        type := CharacterLogType.CUSTOM,
        is_verbose := false,
        includes_position := true,
        standardizes_message := true) -> void:
    if _get_should_log_this_type(type, is_verbose):
        if standardizes_message:
            var prefix := CharacterLogType.get_prefix(type)
            var position_string: String = \
                    ";%17s" % Sc.utils.get_vector_string(position, 1) if \
                    includes_position else \
                    ""
            details = \
                    "; %s" % details if \
                    !details.empty() else \
                    details
            message = "[%s] %s: %s;%8.3f%s%s" % [
                        prefix,
                        Sc.utils.resize_string(message, 12, false),
                        _resized_character_name,
                        Sc.time.get_play_time(),
                        position_string,
                        details,
                    ]
        Sc.logger.print(message)
        if stores_logs_on_character_instances:
            _recent_logs.push(message)


func _get_should_log_this_type(
        type: int,
        is_verbose = false) -> bool:
    var logs_this_type := \
            (type == CharacterLogType.DEFAULT and logs_custom_events) or \
            (type == CharacterLogType.CUSTOM and logs_custom_events) or \
            (type == CharacterLogType.BEHAVIOR and logs_behavior_events) or \
            (type == CharacterLogType.NAVIGATOR and logs_navigator_events) or \
            (type == CharacterLogType.COLLISION and logs_collision_events) or \
            (type == CharacterLogType.SURFACE and logs_surface_events) or \
            (type == CharacterLogType.ACTION and logs_action_events) or \
            type == CharacterLogType.UNKNOWN
    var logs_this_verbose_type: bool = \
            !is_verbose or \
            (logs_verbose_events and \
                    type != CharacterLogType.NAVIGATOR or \
            logs_verbose_navigator_events and \
                    type == CharacterLogType.NAVIGATOR)
    return logs_this_type and \
            logs_this_verbose_type and \
            Sc.metadata.logs_character_events


func get_next_position_prediction() -> Vector2:
    # Since move_and_slide automatically accounts for delta, we need to
    # compensate for that in order to support our modified framerate.
    var modified_velocity: Vector2 = velocity * Sc.time.get_combined_scale()
    return position + modified_velocity * Sc.time.PHYSICS_TIME_STEP


func show_exclamation_mark() -> void:
    _throttled_show_exclamation_mark.call_func()


func _show_exclamation_mark_throttled() -> void:
    Sc.annotators.add_transient(ExclamationMarkAnnotator.new(
            self,
            collider.half_width_height.y * 2.0,
            primary_annotation_color,
            secondary_annotation_color,
            exclamation_mark_width_start,
            exclamation_mark_length_start,
            exclamation_mark_stroke_width_start,
            exclamation_mark_duration))


func set_is_sprite_visible(is_visible: bool) -> void:
    animator.visible = is_visible


func get_is_sprite_visible() -> bool:
    return animator.visible


# Uses physics layers and an auxiliary Area2D to detect collisions with areas
# and objects.
func _add_layer_for_collision_detection(layer_name_or_names) -> void:
    # Create the Area2D if it doesn't exist yet.
    if !is_instance_valid(_extra_collision_detection_area):
        _extra_collision_detection_area = _add_detection_area(
                collider.shape,
                collider.rotation,
                "_on_started_colliding",
                "_on_stopped_colliding")
    _enable_layer(layer_name_or_names, _extra_collision_detection_area)


func _remove_layer_for_collision_detection(layer_name_or_names) -> void:
    if !is_instance_valid(_extra_collision_detection_area):
        return
    
    _disable_layer(layer_name_or_names, _extra_collision_detection_area)
    
    # Destroy the Area2D if it is no longer listening to anything.
    if _extra_collision_detection_area.collision_mask == 0:
        _extra_collision_detection_area.queue_free()
        _extra_collision_detection_area = null


func _add_layer_for_entered_radius_proximity_detection(
        layer_name_or_names,
        radius: float) -> void:
    var shape := CircleShape2D.new()
    shape.radius = radius
    _add_layer_for_entered_shape_proximity_detection(
            layer_name_or_names,
            shape,
            0.0)


func _add_layer_for_exited_radius_proximity_detection(
        layer_name_or_names,
        radius: float) -> void:
    var shape := CircleShape2D.new()
    shape.radius = radius
    _add_layer_for_exited_shape_proximity_detection(
            layer_name_or_names,
            shape,
            0.0)


func _add_layer_for_entered_shape_proximity_detection(
        layer_name_or_names,
        detection_shape: Shape2D,
        detection_shape_rotation: float) -> void:
    var area := _add_detection_area(
            detection_shape,
            detection_shape_rotation,
            "_on_entered_proximity",
            "")
    _enable_layer(layer_name_or_names, area)
    
    var layer_names := \
            [layer_name_or_names] if \
            layer_name_or_names is String else \
            layer_name_or_names
    for layer_name in layer_names:
        _layers_for_entered_proximity_detection[layer_name] = area


func _add_layer_for_exited_shape_proximity_detection(
        layer_name_or_names,
        detection_shape: Shape2D,
        detection_shape_rotation: float) -> void:
    var area := _add_detection_area(
            detection_shape,
            detection_shape_rotation,
            "",
            "_on_exited_proximity")
    _enable_layer(layer_name_or_names, area)
    
    var layer_names := \
            [layer_name_or_names] if \
            layer_name_or_names is String else \
            layer_name_or_names
    for layer_name in layer_names:
        _layers_for_exited_proximity_detection[layer_name] = area


func _remove_layer_for_proximity_detection(layer_name_or_names) -> void:
    var layer_names := \
            [layer_name_or_names] if \
            layer_name_or_names is String else \
            layer_name_or_names
    for layer_name in layer_names:
        if _layers_for_entered_proximity_detection.has(layer_name):
            var area: Area2D = \
                    _layers_for_entered_proximity_detection[layer_name]
            if is_instance_valid(area):
                area.queue_free()
            _layers_for_entered_proximity_detection.erase(layer_name)
        
        if _layers_for_exited_proximity_detection.has(layer_name):
            var area: Area2D = \
                    _layers_for_exited_proximity_detection[layer_name]
            if is_instance_valid(area):
                area.queue_free()
            _layers_for_exited_proximity_detection.erase(layer_name)


func _on_detection_area_enter_exit(
        target,
        callback_name: String,
        detection_area: Area2D) -> void:
    # Ignore any events that are triggered at invalid times.
    if _is_destroyed or \
            !Sc.levels.session.has_started:
        return
    
    # Get a list of the collision-layer names that are matched between the
    # given detector and detectee.
    var shared_bits: int = \
            target.collision_layer & detection_area.collision_mask
    var layer_names: Array = \
            Sc.utils.get_physics_layer_names_from_bitmask(shared_bits)
    assert(!layer_names.empty())
    
    if _get_should_log_this_type(CharacterLogType.COLLISION, true):
        _log(callback_name.trim_prefix("_on_"),
                "layer=%s" % Sc.utils.join(layer_names),
                CharacterLogType.COLLISION,
                false)
    
    self.call(callback_name, target, layer_names)


func _on_started_colliding(target: Node2D, layer_names: Array) -> void:
    pass


func _on_stopped_colliding(target: Node2D, layer_names: Array) -> void:
    pass


func _on_entered_proximity(target: Node2D, layer_names: Array) -> void:
    pass


func _on_exited_proximity(target: Node2D, layer_names: Array) -> void:
    pass


func _on_touch_entered() -> void:
    pass


func _on_touch_exited() -> void:
    pass


func _on_touch_down(
        level_position: Vector2,
        is_already_handled: bool) -> void:
    pass


func _on_touch_up(
        level_position: Vector2,
        is_already_handled: bool) -> void:
    pass


func _on_full_pressed(
        level_position: Vector2,
        is_already_handled: bool) -> void:
    pass


func _on_interaction_mode_changed(interaction_mode: int) -> void:
    pass


func _add_detection_area(
        detection_shape: Shape2D,
        detection_shape_rotation: float,
        enter_callback_name: String,
        exit_callback_name: String) -> Area2D:
    var area := Area2D.new()
    area.monitoring = true
    area.monitorable = false
    area.collision_layer = 0
    area.collision_mask = 0
    
    if enter_callback_name != "":
        area.connect(
                "area_entered",
                self,
                "_on_detection_area_enter_exit",
                [enter_callback_name, area])
        area.connect(
                "body_entered",
                self,
                "_on_detection_area_enter_exit",
                [enter_callback_name, area])
    if exit_callback_name != "":
        area.connect(
                "area_exited",
                self,
                "_on_detection_area_enter_exit",
                [exit_callback_name, area])
        area.connect(
                "body_exited",
                self,
                "_on_detection_area_enter_exit",
                [exit_callback_name, area])
    
    var collision_shape := CollisionShape2D.new()
    collision_shape.shape = detection_shape
    collision_shape.rotation = detection_shape_rotation
    
    area.add_child(collision_shape)
    self.add_child(area)
    
    return area


func _enable_layer(
        layer_name_or_names,
        area: Area2D) -> void:
    assert(layer_name_or_names is String or \
            layer_name_or_names is Array)
    var layer_names := \
            [layer_name_or_names] if \
            layer_name_or_names is String else \
            layer_name_or_names
    
    for layer_name in layer_names:
        # Enable the bit for this layer.
        var layer_bit_mask: int = \
                Sc.utils.get_physics_layer_bitmask_from_name(layer_name)
        area.collision_mask |= layer_bit_mask


func _disable_layer(
        layer_name_or_names,
        area: Area2D) -> void:
    assert(layer_name_or_names is String or \
            layer_name_or_names is Array)
    var layer_names := \
            [layer_name_or_names] if \
            layer_name_or_names is String else \
            layer_name_or_names
    
    for layer_name in layer_names:
        # Disable the bit for this layer.
        var layer_bit_mask: int = \
                Sc.utils.get_physics_layer_bitmask_from_name(layer_name)
        area.collision_mask &= ~layer_bit_mask


func _set_character_name(value: String) -> void:
    character_name = value
    _resized_character_name = Sc.utils.resize_string(character_name, 8, false)
    category = Sc.characters.get_category_for_character(character_name)
    _update_editor_configuration()


func _set_detects_pointer(value: bool) -> void:
    detects_pointer = value
    _update_pointer_detector()


func _set_pointer_screen_radius(value: float) -> void:
    pointer_screen_radius = value
    _update_pointer_detector()


func _set_pointer_distance_squared_offset_for_selection_priority(value: float) -> void:
    pointer_distance_squared_offset_for_selection_priority = value
    _update_pointer_detector()


func _update_pointer_detector() -> void:
    if detects_pointer:
        if !is_instance_valid(_pointer_detector):
            _pointer_detector = LevelControl.new()
            _pointer_detector.connect(
                "touch_entered", self, "_on_touch_entered")
            _pointer_detector.connect("touch_exited", self, "_on_touch_exited")
            _pointer_detector.connect("touch_up", self, "_on_touch_up")
            _pointer_detector.connect("touch_down", self, "_on_touch_down")
            _pointer_detector.connect("full_pressed", self, "_on_full_pressed")
            _pointer_detector.connect(
                "interaction_mode_changed", self, "_on_interaction_mode_changed")
            add_child(_pointer_detector)
            var detector_shape := CollisionShape2D.new()
            _pointer_detector.add_child(detector_shape)
        
        # Sync the detector shape to the character's collision shape.
        var detector_shape: CollisionShape2D = \
                Sc.utils.get_child_by_type(_pointer_detector, CollisionShape2D)
        if is_instance_valid(collision_shape):
            detector_shape.shape = collision_shape.shape
            detector_shape.position = collision_shape.position
        elif !is_instance_valid(detector_shape.shape):
            detector_shape.shape = CircleShape2D.new()
            detector_shape.shape.radius = 8.0
        
        _pointer_detector.screen_radius = pointer_screen_radius
        _pointer_detector.distance_squared_offset_for_selection_priority = \
            pointer_distance_squared_offset_for_selection_priority
    else:
        if is_instance_valid(_pointer_detector):
            _pointer_detector._destroy()
            _pointer_detector = null


func get_position_in_screen_space() -> Vector2:
    return Sc.utils.get_screen_position_of_node_in_level(self)


func _get_navigation_annotation_color() -> ColorConfig:
    return navigation_annotation_color_override if \
            !navigation_annotation_color_override is PaletteColorConfig or \
                navigation_annotation_color_override.key != "black" else \
            primary_annotation_color


func _get_position_annotation_color() -> ColorConfig:
    return position_annotation_color_override if \
            !position_annotation_color_override is PaletteColorConfig or \
                position_annotation_color_override.key != "black" else \
            primary_annotation_color


func _set_logs_common_debugging_events(value: bool) -> void:
    logs_common_debugging_events = value
    if logs_common_debugging_events:
        logs_custom_events = true
        logs_behavior_events = true
        logs_navigator_events = true
        logs_collision_events = true
        logs_surface_events = true
        logs_action_events = true
    elif logs_custom_events and \
            logs_behavior_events and \
            logs_navigator_events and \
            logs_collision_events:
        logs_custom_events = false
        logs_behavior_events = false
        logs_navigator_events = false
        logs_collision_events = false
        logs_surface_events = false
        logs_action_events = false
    _update_editor_configuration()


func _set_logs_custom_events(value: bool) -> void:
    logs_custom_events = value
    if !logs_custom_events:
        logs_common_debugging_events = false
    _update_editor_configuration()


func _set_logs_behavior_events(value: bool) -> void:
    logs_behavior_events = value
    if !logs_behavior_events:
        logs_common_debugging_events = false
    _update_editor_configuration()


func _set_logs_navigator_events(value: bool) -> void:
    logs_navigator_events = value
    if !logs_navigator_events:
        logs_common_debugging_events = false
    _update_editor_configuration()


func _set_logs_collision_events(value: bool) -> void:
    logs_collision_events = value
    if !logs_collision_events:
        logs_common_debugging_events = false
    _update_editor_configuration()


func _set_logs_surface_events(value: bool) -> void:
    logs_surface_events = value
    if !logs_surface_events:
        logs_common_debugging_events = false
    _update_editor_configuration()


func _set_logs_action_events(value: bool) -> void:
    logs_action_events = value
    if !logs_action_events:
        logs_common_debugging_events = false
    _update_editor_configuration()


func _set_logs_verbose_events(value: bool) -> void:
    logs_verbose_events = value
    _update_editor_configuration()


func _set_logs_verbose_navigator_events(value: bool) -> void:
    logs_verbose_navigator_events = value
    _update_editor_configuration()


func _set_stores_logs_on_character_instances(value: bool) -> void:
    var previous_stores_logs_on_character_instances := \
            stores_logs_on_character_instances
    stores_logs_on_character_instances = value
    if !previous_stores_logs_on_character_instances and \
            stores_logs_on_character_instances:
        _recent_logs = CircularBuffer.new(
                _RECENT_LOGS_COUNT_TO_STORE_ON_CHARACTER_INSTANCE)
    _update_editor_configuration()

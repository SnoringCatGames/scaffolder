tool
class_name LevelControl, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_node.png"
extends Area2D
## -   This bypasses Godot's normal Control logic, and re-implements mouse/touch
##     behavior from scratch.
## -   This is needed, because Godot's normal Button behavior captures scroll
##     events, and prevents the level from processing them.
##     -   This capturing is not disablable in the normal way with mouse_filter.


enum InteractionMode {
    UNKNOWN,
    HOVER,
    PRESSED,
    DISABLED,
    NORMAL,
}

signal interaction_mode_changed(interaction_mode)

export var is_disabled := false setget _set_is_disabled
export var is_focused := false setget _set_is_focused

export var mouse_cursor_override := -1

var interaction_mode: int = InteractionMode.NORMAL

var _was_touch_down_in_this_control := false

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    self.connect("mouse_entered", self, "_on_mouse_entered")
    self.connect("mouse_exited", self, "_on_mouse_exited")
    self.connect("input_event", self, "_on_input_event")
    self.collision_layer = Sc.gui.GUI_COLLISION_LAYER
    self.monitoring = false
    self.monitorable = false
    self.input_pickable = true
    _update_interaction_mode(InteractionMode.NORMAL)


func _set_is_disabled(value: bool) -> void:
    is_disabled = value
    _update_interaction_mode(InteractionMode.DISABLED)


func _set_is_focused(value: bool) -> void:
    is_focused = value
    _update_interaction_mode(interaction_mode)


func _update_interaction_mode(attempted_interaction_mode: int) -> void:
    var previous_interaction_mode := interaction_mode
    
    if is_disabled:
        interaction_mode = InteractionMode.DISABLED
    else:
        interaction_mode = attempted_interaction_mode
    
    if interaction_mode != previous_interaction_mode:
        _on_interaction_mode_changed(interaction_mode)


func _on_mouse_entered() -> void:
#    Sc.logger.print("LevelControl._on_mouse_entered")
    _was_touch_down_in_this_control = false
    if mouse_cursor_override >= 0:
        Input.set_default_cursor_shape(mouse_cursor_override)
    _update_interaction_mode(InteractionMode.HOVER)


func _on_mouse_exited() -> void:
#    Sc.logger.print("LevelControl._on_mouse_exited")
    _was_touch_down_in_this_control = false
    if mouse_cursor_override >= 0:
        # FIXME: -----------------------
        # - Configure the default in ScaffolderGuiConfig.
        # - Add logic to check whether the cursor was also assigned to a
        #   non-default value this frame, and, if so, don't reset it.
        Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    _update_interaction_mode(InteractionMode.NORMAL)


func _on_input_event(
        viewport: Node,
        event: InputEvent,
        shape_idx: int) -> void:
#    Sc.logger.print("LevelControl._on_input_event")
    var screen_position := Vector2.INF
    var level_position := Vector2.INF
    var is_touch_down := false
    var is_touch_up := false
    var is_touch_drag := false
    var event_type := "UNKNOWN_INP"
    
    # NOTE: We don't handle mouse left-click events, since we should be
    #       emulating touch events for those.
    
#    # Mouse-up: Position selection.
#    if event is InputEventMouseButton and \
#            event.button_index == BUTTON_LEFT and \
#            !event.pressed:
#        event_type = "MOUSE_UP   "
#        is_touch_up = true
#        screen_position = event.position
#        level_position = Sc.utils.get_level_touch_position(event)
#
#    # Mouse-down: Position pre-selection.
#    elif event is InputEventMouseButton and \
#            event.button_index == BUTTON_LEFT and \
#            event.pressed:
#        event_type = "MOUSE_DOWN "
#        is_touch_down = true
#        screen_position = event.position
#        level_position = Sc.utils.get_level_touch_position(event)
#
#    # Mouse-move: Position pre-selection.
#    elif event is InputEventMouseMotion and \
#            !_active_gestures.empty():
#        event_type = "MOUSE_DRAG "
#        is_touch_drag = true
#        screen_position = event.position
#        level_position = Sc.utils.get_level_touch_position(event)
    
    # Touch-up: Position selection.
    if event is InputEventScreenTouch and \
            !event.pressed:
        event_type = "TOUCH_UP   "
        is_touch_up = true
        screen_position = event.position
        level_position = Sc.utils.get_level_touch_position(event)
        
    # Touch-down: Position pre-selection.
    elif event is InputEventScreenTouch and \
            event.pressed:
        event_type = "TOUCH_DOWN "
        is_touch_down = true
        screen_position = event.position
        level_position = Sc.utils.get_level_touch_position(event)
        
    # Touch-move: Position pre-selection.
    elif event is InputEventScreenDrag:
        event_type = "TOUCH_DRAG "
        is_touch_drag = true
        screen_position = event.position
        level_position = Sc.utils.get_level_touch_position(event)
    
#    if level_position != Vector2.INF:
#        var position_string: String = \
#                ";%17s" % Sc.utils.get_vector_string(level_position, 1)
#        var message := "[%s] %s: %8.3f%s" % [
#                    "TCH",
#                    Sc.utils.resize_string(event_type, 12, false),
#                    Sc.time.get_play_time(),
#                    position_string,
#                ]
#        Sc.logger.print(message)
    
    var is_full_press := is_touch_up and _was_touch_down_in_this_control
    
    if is_touch_down:
        _on_touch_down(level_position, screen_position)
    elif is_touch_up:
        _on_touch_up(level_position, screen_position)
        if is_full_press:
            _on_full_press(level_position, screen_position)


func _on_touch_down(
        level_position: Vector2,
        screen_position: Vector2) -> void:
    _was_touch_down_in_this_control = true
    _update_interaction_mode(InteractionMode.PRESSED)


func _on_touch_up(
        level_position: Vector2,
        screen_position: Vector2) -> void:
    _was_touch_down_in_this_control = false
    _update_interaction_mode(InteractionMode.HOVER)


func _on_full_press(
        level_position: Vector2,
        screen_position: Vector2) -> void:
    pass


func _on_interaction_mode_changed(interaction_mode: int) -> void:
    emit_signal("interaction_mode_changed", interaction_mode)


static func get_interaction_mode_string(type: int) -> String:
    match type:
        InteractionMode.UNKNOWN:
            return "UNKNOWN"
        InteractionMode.HOVER:
            return "HOVER"
        InteractionMode.PRESSED:
            return "PRESSED"
        InteractionMode.DISABLED:
            return "DISABLED"
        InteractionMode.NORMAL:
            return "NORMAL"
        _:
            Sc.logger.error("LevelControl.get_interaction_mode_string")
            return ""

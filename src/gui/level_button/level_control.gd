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

enum TouchType {
    TOUCH_DOWN,
    TOUCH_UP,
    TOUCH_MOVE,
}

signal touch_entered
signal touch_exited
signal touch_up(level_position, is_already_handled)
signal touch_down(level_position, is_already_handled)
signal full_pressed(level_position, is_already_handled)
signal interaction_mode_changed(interaction_mode)

export var is_disabled := false setget _set_is_disabled
export var is_focused := false setget _set_is_focused

export var screen_radius := 16.0 setget _set_screen_radius

export var distance_squared_offset_for_selection_priority := 0.0 \
    setget _set_distance_squared_offset_for_selection_priority

export var mouse_filter := Control.MOUSE_FILTER_STOP

export var is_desaturatable := false setget _set_is_desaturatable

var interaction_mode: int = InteractionMode.NORMAL
var attempted_interaction_mode: int = InteractionMode.NORMAL

var _was_touch_down_in_this_control := false
var _was_touch_up_a_full_press := false

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    self.connect("mouse_entered", self, "_on_touch_entered_unfiltered")
    self.connect("mouse_exited", self, "_on_touch_exited_unfiltered")
    self.connect("input_event", self, "_on_input_event")
    self.collision_layer |= Sc.gui.GUI_COLLISION_LAYER
    self.monitoring = false
    self.monitorable = false
    self.input_pickable = true
    _update_interaction_mode(InteractionMode.NORMAL)
    _set_is_desaturatable(is_desaturatable)
    if Engine.editor_hint:
        return
    Sc.level.level_control_press_controller.add_control(self)


func _destroy() -> void:
    Sc.level.level_control_press_controller.remove_control(self)
    queue_free()


func _set_is_disabled(value: bool) -> void:
    var was_disabled := is_disabled
    is_disabled = value
    if is_disabled != was_disabled:
        _update_interaction_mode()


func _set_is_focused(value: bool) -> void:
    is_focused = value
    _update_interaction_mode(interaction_mode)


func _set_screen_radius(value: float) -> void:
    screen_radius = value


func _set_distance_squared_offset_for_selection_priority(value: float) -> void:
    distance_squared_offset_for_selection_priority = value


func _set_is_desaturatable(value: bool) -> void:
    is_desaturatable = value


func get_screen_radius_in_level_space() -> float:
    return screen_radius * Sc.level.camera.zoom.x * Sc.gui.scale


func get_center_in_level_space() -> Vector2:
    return Sc.utils.transform_screen_position_to_level_position(
            get_center_in_screen_space())


func get_center_in_screen_space() -> Vector2:
    return Sc.utils.get_screen_position_of_node_in_level(self)


func _update_interaction_mode(
        attempted_interaction_mode := InteractionMode.UNKNOWN) -> void:
    if attempted_interaction_mode == InteractionMode.UNKNOWN:
        attempted_interaction_mode = self.attempted_interaction_mode
    else:
        self.attempted_interaction_mode = attempted_interaction_mode
    
    var previous_interaction_mode := interaction_mode
    
    if is_disabled:
        interaction_mode = InteractionMode.DISABLED
    else:
        interaction_mode = attempted_interaction_mode
    
    if interaction_mode != previous_interaction_mode:
        _on_interaction_mode_changed(interaction_mode)


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
#        level_position = Sc.utils.get_level_position_for_screen_event(event)
#
#    # Mouse-down: Position pre-selection.
#    elif event is InputEventMouseButton and \
#            event.button_index == BUTTON_LEFT and \
#            event.pressed:
#        event_type = "MOUSE_DOWN "
#        is_touch_down = true
#        screen_position = event.position
#        level_position = Sc.utils.get_level_position_for_screen_event(event)
#
#    # Mouse-move: Position pre-selection.
#    elif event is InputEventMouseMotion and \
#            !_active_gestures.empty():
#        event_type = "MOUSE_DRAG "
#        is_touch_drag = true
#        screen_position = event.position
#        level_position = Sc.utils.get_level_position_for_screen_event(event)
    
    # Touch-up: Position selection.
    if event is InputEventScreenTouch and \
            !event.pressed:
        event_type = "TOUCH_UP   "
        is_touch_up = true
        screen_position = event.position
        level_position = Sc.utils.get_level_position_for_screen_event(event)
        
    # Touch-down: Position pre-selection.
    elif event is InputEventScreenTouch and \
            event.pressed:
        event_type = "TOUCH_DOWN "
        is_touch_down = true
        screen_position = event.position
        level_position = Sc.utils.get_level_position_for_screen_event(event)
        
    # Touch-move: Position pre-selection.
    elif event is InputEventScreenDrag:
        event_type = "TOUCH_DRAG "
        is_touch_drag = true
        screen_position = event.position
        level_position = Sc.utils.get_level_position_for_screen_event(event)
    
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
        _on_touch_down_unfiltered(level_position)
    elif is_touch_up:
        _on_touch_up_unfiltered(level_position)
        if is_full_press:
            _on_full_pressed_unfiltered(level_position)


func _on_touch_entered_unfiltered() -> void:
#    Sc.logger.print("LevelControl._on_touch_entered_unfiltered")
    _was_touch_down_in_this_control = false
    Sc.level.level_control_press_controller.register_touch_entered(self)


func _on_touch_exited_unfiltered() -> void:
#    Sc.logger.print("LevelControl._on_touch_exited_unfiltered")
    _was_touch_down_in_this_control = false
    Sc.level.level_control_press_controller.register_touch_exited(self)


func _on_touch_down_unfiltered(level_position: Vector2) -> void:
    Sc.level.level_control_press_controller.register_touch_event(
            TouchType.TOUCH_DOWN,
            level_position,
            self)
    _was_touch_down_in_this_control = true


func _on_touch_up_unfiltered(level_position: Vector2) -> void:
    _was_touch_up_a_full_press = _was_touch_down_in_this_control
    Sc.level.level_control_press_controller.register_touch_event(
            TouchType.TOUCH_UP,
            level_position,
            self)
    _was_touch_down_in_this_control = false


func _on_full_pressed_unfiltered(level_position: Vector2) -> void:
    pass


func _on_touch_entered() -> void:
#    Sc.logger.print("LevelControl._on_touch_entered")
    _was_touch_up_a_full_press = false
    _update_interaction_mode(InteractionMode.HOVER)
    if mouse_filter == Control.MOUSE_FILTER_STOP:
        Sc.level.touch_listener.set_current_touch_as_handled()
    emit_signal("touch_entered")


func _on_touch_exited() -> void:
#    Sc.logger.print("LevelControl._on_touch_exited")
    _was_touch_up_a_full_press = false
    _update_interaction_mode(InteractionMode.NORMAL)
    emit_signal("touch_exited")


func _on_touch_down(
        level_position: Vector2,
        is_already_handled: bool) -> void:
    if !is_already_handled:
        _update_interaction_mode(InteractionMode.PRESSED)
    if mouse_filter == Control.MOUSE_FILTER_STOP:
        Sc.level.touch_listener.set_current_touch_as_handled()
    emit_signal("touch_down", level_position, is_already_handled)


func _on_touch_up(
        level_position: Vector2,
        is_already_handled: bool) -> void:
    _update_interaction_mode(InteractionMode.HOVER)
    if mouse_filter == Control.MOUSE_FILTER_STOP:
        Sc.level.touch_listener.set_current_touch_as_handled()
    if _was_touch_up_a_full_press:
        _on_full_pressed(level_position, is_already_handled)
    _was_touch_up_a_full_press = false
    emit_signal("touch_up", level_position, is_already_handled)


func _on_full_pressed(
        level_position: Vector2,
        is_already_handled: bool) -> void:
#    Sc.logger.print("LevelControl._on_full_pressed")
    emit_signal("full_pressed", level_position, is_already_handled)


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

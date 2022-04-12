class_name LevelPointerListener
extends Node2D


signal dragged(pointer_screen_position, pointer_level_position)
signal released(pointer_screen_position, pointer_level_position)
signal pinch_changed(pinch_distance, pinch_angle)
signal pinch_finished()

var is_touch_active: bool setget ,_get_is_touch_active
var is_multi_touch_active: bool setget ,_get_is_multi_touch_active

var was_latest_touch_part_of_multi_touch := false

var previous_drag_screen_position := Vector2.INF
var current_drag_screen_position := Vector2.INF
var release_screen_position := Vector2.INF
var previous_drag_level_position := Vector2.INF
var current_drag_level_position := Vector2.INF
var release_level_position := Vector2.INF
var current_drag_screen_displacement: Vector2 \
        setget ,_get_current_drag_screen_displacement

var previous_pinch_screen_distance := INF
var current_pinch_screen_distance := INF
var current_pinch_distance_change: float \
        setget ,_get_current_pinch_distance_change
var current_pinch_distance_ratio_from_previous: float \
        setget ,_get_current_pinch_distance_ratio_from_previous

var previous_pinch_angle := INF
var current_pinch_angle := INF
var current_pinch_angle_change: float setget ,_get_current_pinch_angle_change

# Dictionary<int, Vector2>
var _active_touch_screen_positions := {}


func _init() -> void:
    assert(Sc.gui.is_player_interaction_enabled)


func _unhandled_input(event: InputEvent) -> void:
    var pointer_up_screen_position := Vector2.INF
    var pointer_drag_screen_position := Vector2.INF
    var pointer_up_level_position := Vector2.INF
    var pointer_drag_level_position := Vector2.INF
    var event_type := "UNKNOWN_INP"
    
    # NOTE: Shouldn't need to handle mouse events, since we should be emulating
    #       touch events.
    
#    # Mouse-up: Position selection.
#    if event is InputEventMouseButton and \
#            event.button_index == BUTTON_LEFT and \
#            !event.pressed and \
#            !event.control:
#        event_type = "MOUSE_UP   "
#        pointer_up_position = Sc.utils.get_level_touch_position(event)
#
#    # Mouse-down: Position pre-selection.
#    if event is InputEventMouseButton and \
#            event.button_index == BUTTON_LEFT and \
#            event.pressed and \
#            !event.control:
#        event_type = "MOUSE_DOWN "
#        pointer_drag_level_position = \
#                Sc.utils.get_level_touch_position(event)
#
#    # Mouse-move: Position pre-selection.
#    if event is InputEventMouseMotion and \
#            _last_pointer_drag_level_position != Vector2.INF:
#        event_type = "MOUSE_DRAG "
#        pointer_drag_level_position = \
#                Sc.utils.get_level_touch_position(event)
    
    # Touch-up: Position selection.
    if event is InputEventScreenTouch and \
            !event.pressed:
        event_type = "TOUCH_UP   "
        pointer_up_screen_position = event.position
        pointer_up_level_position = Sc.utils.get_level_touch_position(event)
        _active_touch_screen_positions.erase(event.index)
    
    # Touch-down: Position pre-selection.
    if event is InputEventScreenTouch and \
            event.pressed:
        if _active_touch_screen_positions.size() == 0:
            # This is the first touch of a new touch set.
            was_latest_touch_part_of_multi_touch = false
        event_type = "TOUCH_DOWN "
        pointer_drag_screen_position = event.position
        pointer_drag_level_position = Sc.utils.get_level_touch_position(event)
        _active_touch_screen_positions[event.index] = \
                pointer_drag_screen_position
        if _active_touch_screen_positions.size() > 1:
            was_latest_touch_part_of_multi_touch = true
    
    # Touch-move: Position pre-selection.
    if event is InputEventScreenDrag:
        if _active_touch_screen_positions.size() == 0:
            # This is the first touch of a new touch set.
            was_latest_touch_part_of_multi_touch = false
        event_type = "TOUCH_DRAG "
        pointer_drag_screen_position = event.position
        pointer_drag_level_position = Sc.utils.get_level_touch_position(event)
        _active_touch_screen_positions[event.index] = \
                pointer_drag_screen_position
        if _active_touch_screen_positions.size() > 1:
            was_latest_touch_part_of_multi_touch = true
    
#    if pointer_up_position != Vector2.INF or \
#            pointer_drag_level_position != Vector2.INF:
#        var pointer_position := \
#                pointer_drag_level_position if \
#                pointer_drag_level_position != Vector2.INF else \
#                pointer_up_position
#        var position_string: String = \
#                ";%17s" % Sc.utils.get_vector_string(pointer_position, 1)
#        var message := "[%s] %s: %8.3f%s" % [
#                    "TCH",
#                    Sc.utils.resize_string(event_type, 12, false),
#                    Sc.time.get_play_time(),
#                    position_string,
#                ]
#        Sc.logger.print(message)
    
    if _active_touch_screen_positions.size() == 1:
        # This could be false if we just released one touch in a multi-touch
        # set.
        if pointer_drag_level_position != Vector2.INF:
            _on_single_touch_moved(
                    pointer_drag_screen_position,
                    pointer_drag_level_position)
    elif _active_touch_screen_positions.size() == 2:
        _on_pinch_changed()
    elif _active_touch_screen_positions.size() == 0:
        if pointer_up_level_position != Vector2.INF:
            _on_single_touch_released(
                    pointer_up_screen_position,
                    pointer_up_level_position)
        if was_latest_touch_part_of_multi_touch:
            _on_pinch_finished()
    else:
        # Multi-touch event with more than 2 touches.
        pass


func _on_single_touch_moved(
        pointer_screen_position: Vector2,
        pointer_level_position: Vector2) -> void:
    self.previous_drag_screen_position = current_drag_screen_position
    self.current_drag_screen_position = pointer_screen_position
    self.release_screen_position = Vector2.INF
    self.previous_drag_level_position = current_drag_level_position
    self.current_drag_level_position = pointer_level_position
    self.release_level_position = Vector2.INF
    self.previous_pinch_screen_distance = INF
    self.current_pinch_screen_distance = INF
    self.previous_pinch_angle = INF
    self.current_pinch_angle = INF
    emit_signal("dragged", pointer_screen_position, pointer_level_position)


func _on_single_touch_released(
        pointer_screen_position: Vector2,
        pointer_level_position: Vector2) -> void:
    self.previous_drag_screen_position = Vector2.INF
    self.current_drag_screen_position = Vector2.INF
    self.release_screen_position = pointer_screen_position
    self.previous_drag_level_position = Vector2.INF
    self.current_drag_level_position = Vector2.INF
    self.release_level_position = pointer_level_position
    self.previous_pinch_screen_distance = INF
    self.current_pinch_screen_distance = INF
    self.previous_pinch_angle = INF
    self.current_pinch_angle = INF
    emit_signal("released", pointer_screen_position, pointer_level_position)


func _on_pinch_changed() -> void:
    self.previous_drag_screen_position = Vector2.INF
    self.current_drag_screen_position = Vector2.INF
    self.release_screen_position = Vector2.INF
    self.previous_drag_level_position = Vector2.INF
    self.current_drag_level_position = Vector2.INF
    self.release_level_position = Vector2.INF
    self.previous_pinch_screen_distance = self.current_pinch_screen_distance
    self.current_pinch_screen_distance = \
            _active_touch_screen_positions[0].distance_to(
                _active_touch_screen_positions[1])
    self.previous_pinch_angle = self.current_pinch_angle
    self.current_pinch_angle = \
            _active_touch_screen_positions[0].angle_to_point(
                _active_touch_screen_positions[1])
    emit_signal(
            "pinch_changed",
            current_pinch_screen_distance,
            current_pinch_angle)


func _on_pinch_finished() -> void:
    self.previous_drag_screen_position = Vector2.INF
    self.current_drag_screen_position = Vector2.INF
    self.release_screen_position = Vector2.INF
    self.previous_drag_level_position = Vector2.INF
    self.current_drag_level_position = Vector2.INF
    self.release_level_position = Vector2.INF
    self.previous_pinch_screen_distance = INF
    self.current_pinch_screen_distance = INF
    self.previous_pinch_angle = INF
    self.current_pinch_angle = INF
    emit_signal("pinch_released")


func _get_is_touch_active() -> bool:
    return _active_touch_screen_positions.size() > 0


func _get_is_multi_touch_active() -> bool:
    return _active_touch_screen_positions.size() > 1


func _get_current_drag_screen_displacement() -> Vector2:
    return current_drag_screen_position - previous_drag_screen_position if \
            !Sc.geometry.is_point_partial_inf(
                previous_drag_screen_position) else \
            Vector2.ZERO


func _get_current_pinch_distance_change() -> float:
    return current_pinch_screen_distance - previous_pinch_screen_distance if \
            !is_inf(previous_pinch_screen_distance) else \
            0.0


func _get_current_pinch_distance_ratio_from_previous() -> float:
    return current_pinch_screen_distance / previous_pinch_screen_distance if \
            !is_inf(previous_pinch_screen_distance) else \
            1.0


func _get_current_pinch_angle_change() -> float:
    return current_pinch_angle - previous_pinch_angle if \
            !is_inf(previous_pinch_angle) else \
            0.0


func get_is_control_pressed() -> bool:
    return Sc.level_button_input.is_key_pressed(KEY_CONTROL) or \
            Sc.level_button_input.is_key_pressed(KEY_META)

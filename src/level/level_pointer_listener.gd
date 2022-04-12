class_name LevelPointerListener
extends Node2D


signal dragged(pointer_position)
signal released(pointer_position)
signal pinch_changed(pinch_distance, pinch_angle)
signal pinch_finished()

var is_touch_active: bool setget ,_get_is_touch_active
var is_multi_touch_active: bool setget ,_get_is_multi_touch_active

var was_latest_touch_part_of_multi_touch := false

var previous_drag_position := Vector2.INF
var current_drag_position := Vector2.INF
var release_position := Vector2.INF

var previous_pinch_screen_distance := INF
var current_pinch_screen_distance := INF

var previous_pinch_angle := INF
var current_pinch_angle := INF

# Dictionary<int, Vector2>
var _active_touch_screen_positions := {}


func _init() -> void:
    assert(Sc.gui.is_player_interaction_enabled)


func _unhandled_input(event: InputEvent) -> void:
    var pointer_up_position := Vector2.INF
    var pointer_drag_position := Vector2.INF
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
#        pointer_drag_position = \
#                Sc.utils.get_level_touch_position(event)
#
#    # Mouse-move: Position pre-selection.
#    if event is InputEventMouseMotion and \
#            _last_pointer_drag_position != Vector2.INF:
#        event_type = "MOUSE_DRAG "
#        pointer_drag_position = \
#                Sc.utils.get_level_touch_position(event)
    
    # Touch-up: Position selection.
    if event is InputEventScreenTouch and \
            !event.pressed:
        event_type = "TOUCH_UP   "
        pointer_up_position = Sc.utils.get_level_touch_position(event)
        assert(_active_touch_screen_positions.has(event.index))
        _active_touch_screen_positions.erase(event.index)
    
    # Touch-down: Position pre-selection.
    if event is InputEventScreenTouch and \
            event.pressed:
        if _active_touch_screen_positions.size() == 0:
            # This is the first touch of a new touch set.
            was_latest_touch_part_of_multi_touch = false
        event_type = "TOUCH_DOWN "
        pointer_drag_position = Sc.utils.get_level_touch_position(event)
        assert(!_active_touch_screen_positions.has(event.index))
        _active_touch_screen_positions[event.index] = event.position
        if _active_touch_screen_positions.size() > 1:
            was_latest_touch_part_of_multi_touch = true
    
    # Touch-move: Position pre-selection.
    if event is InputEventScreenDrag:
        if _active_touch_screen_positions.size() == 0:
            # This is the first touch of a new touch set.
            was_latest_touch_part_of_multi_touch = false
        event_type = "TOUCH_DRAG "
        pointer_drag_position = Sc.utils.get_level_touch_position(event)
        assert(_active_touch_screen_positions.has(event.index))
        _active_touch_screen_positions[event.index] = event.position
        if _active_touch_screen_positions.size() > 1:
            was_latest_touch_part_of_multi_touch = true
    
#    if pointer_up_position != Vector2.INF or \
#            pointer_drag_position != Vector2.INF:
#        _character._log(
#                event_type,
#                "",
#                CharacterLogType.ACTION,
#                true)
    
    if was_latest_touch_part_of_multi_touch:
        if _active_touch_screen_positions.size() == 2:
            _on_pinch_changed()
        elif _active_touch_screen_positions.size() == 0:
            _on_pinch_finished()
    else:
        if pointer_up_position != Vector2.INF:
            _on_single_touch_released(pointer_up_position)
        elif pointer_drag_position != Vector2.INF:
            _on_single_touch_moved(pointer_drag_position)


func _on_single_touch_moved(pointer_position: Vector2) -> void:
    if was_latest_touch_part_of_multi_touch:
        return
    self.previous_drag_position = current_drag_position
    self.current_drag_position = pointer_position
    self.release_position = Vector2.INF
    self.previous_pinch_screen_distance = INF
    self.current_pinch_screen_distance = INF
    self.previous_pinch_angle = INF
    self.current_pinch_angle = INF
    emit_signal("dragged", pointer_position)


func _on_single_touch_released(pointer_position: Vector2) -> void:
    if was_latest_touch_part_of_multi_touch:
        return
    self.previous_drag_position = Vector2.INF
    self.current_drag_position = Vector2.INF
    self.release_position = pointer_position
    self.previous_pinch_screen_distance = INF
    self.current_pinch_screen_distance = INF
    self.previous_pinch_angle = INF
    self.current_pinch_angle = INF
    emit_signal("released", pointer_position)


func _on_pinch_changed() -> void:
    self.previous_drag_position = Vector2.INF
    self.current_drag_position = Vector2.INF
    self.release_position = Vector2.INF
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
    self.previous_drag_position = Vector2.INF
    self.current_drag_position = Vector2.INF
    self.release_position = Vector2.INF
    self.previous_pinch_screen_distance = INF
    self.current_pinch_screen_distance = INF
    self.previous_pinch_angle = INF
    self.current_pinch_angle = INF
    emit_signal("pinch_released")


func _get_is_touch_active() -> bool:
    return _active_touch_screen_positions.size() > 0


func _get_is_multi_touch_active() -> bool:
    return _active_touch_screen_positions.size() > 1


func get_is_control_pressed() -> bool:
    return Sc.level_button_input.is_key_pressed(KEY_CONTROL) or \
            Sc.level_button_input.is_key_pressed(KEY_META)

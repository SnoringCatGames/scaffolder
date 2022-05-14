class_name LevelTouchListener
extends Node2D


signal single_touch_down(
        pointer_screen_position,
        pointer_level_position)
signal single_touch_dragged(
        pointer_screen_position,
        pointer_level_position,
        has_corresponding_touch_down)
signal single_touch_released(
        pointer_screen_position,
        pointer_level_position,
        has_corresponding_touch_down)

signal single_unhandled_touch_down(
        pointer_screen_position,
        pointer_level_position)
signal single_unhandled_touch_dragged(
        pointer_screen_position,
        pointer_level_position,
        has_corresponding_touch_down)
signal single_unhandled_touch_released(
        pointer_screen_position,
        pointer_level_position,
        has_corresponding_touch_down)

signal pinch_changed(
        pinch_distance,
        pinch_angle)
signal pinch_second_touch_down()
signal pinch_first_touch_released()
signal pinch_second_touch_released()

const _DRAG_DELTA_TIME_FOR_VELOCITY_TRACKING_FOR_PC := 0.07
const _DRAG_DELTA_TIME_FOR_VELOCITY_TRACKING_FOR_ANDROID := 0.04

var _DRAG_DELTA_TIME_FOR_VELOCITY_TRACKING := \
        _DRAG_DELTA_TIME_FOR_VELOCITY_TRACKING_FOR_ANDROID if \
        Sc.device.get_is_mobile_device() else \
        _DRAG_DELTA_TIME_FOR_VELOCITY_TRACKING_FOR_PC
var _TOUCH_EVENT_CIRCULAR_BUFFER_SIZE := \
        int(_DRAG_DELTA_TIME_FOR_VELOCITY_TRACKING * 400) + 1

var is_touch_active: bool setget ,_get_is_touch_active
var is_multi_touch_active: bool setget ,_get_is_multi_touch_active

var was_latest_touch_part_of_multi_touch := false

var touch_down_screen_position := Vector2.INF
var latest_drag_screen_position := Vector2.INF
var release_screen_position := Vector2.INF

var touch_down_level_position := Vector2.INF
var latest_drag_level_position := Vector2.INF
var release_level_position := Vector2.INF

var _latest_drag_event: InputEvent

var current_drag_level_position_with_current_camera_pan: Vector2 \
        setget ,_get_current_drag_level_position_with_current_camera_pan

var has_corresponding_touch_down: bool \
        setget ,_get_has_corresponding_touch_down

var current_drag_screen_displacement: Vector2 \
        setget ,_get_current_drag_screen_displacement
var current_drag_level_velocity: Vector2 \
        setget ,_get_current_drag_level_velocity

var latest_touch_time := INF
var touch_down_time := INF
var release_time := INF

var current_pinch_screen_distance := INF
var current_pinch_screen_distance_change: float \
        setget ,_get_current_pinch_screen_distance_change
var current_pinch_screen_distance_ratio_from_previous: float \
        setget ,_get_current_pinch_screen_distance_ratio_from_previous
var current_pinch_screen_distance_speed: float \
        setget ,_get_current_pinch_screen_distance_speed

var current_pinch_angle := INF
var current_pinch_angle_change: float setget ,_get_current_pinch_angle_change
var current_pinch_angle_speed: float setget ,_get_current_pinch_angle_speed

var current_pinch_center_level_position := Vector2.INF

var _current_touch: Touch

# Dictionary<int, CircularBuffer<Touch>>
var _active_gestures := {}

# Dictionary<int, CircularBuffer<Touch>>
var _touch_index_to_touch_buffer := {}

var _touch_handled_time := -INF


func _init() -> void:
    assert(Sc.gui.is_player_interaction_enabled)


func _destroy() -> void:
    # Call `free` on each Touch object (they aren't reference-counted).
    for touch_buffer in _touch_index_to_touch_buffer.values():
        touch_buffer.clear()
    self.queue_free()


func _unhandled_input(event: InputEvent) -> void:
    var pointer_up_screen_position := Vector2.INF
    var pointer_drag_screen_position := Vector2.INF
    var pointer_up_level_position := Vector2.INF
    var pointer_drag_level_position := Vector2.INF
    var is_touch_down := false
    var event_type := "UNKNOWN_INP"
    var touch: Touch
    var previous_touch_count := _active_gestures.size()
    
    # NOTE:
    # -   We don't handle mouse left-click events, since we should be emulating
    #     touch events for those.
    # -   We _do_ handle mouse middle-click events, since Godot's
    #     touch-emulation doesn't recognize those.
    
    # Mouse-up: Position selection.
    if event is InputEventMouseButton and \
            event.button_index == BUTTON_MIDDLE and \
            !event.pressed:
        was_latest_touch_part_of_multi_touch = false
        event_type = "MOUSE_UP   "
        pointer_up_screen_position = event.position
        pointer_up_level_position = Sc.utils.get_level_position_for_screen_event(event)
        _clear_touch_buffer(0)
        
    # Mouse-down: Position pre-selection.
    elif event is InputEventMouseButton and \
            event.button_index == BUTTON_MIDDLE and \
            event.pressed:
        was_latest_touch_part_of_multi_touch = false
        event_type = "MOUSE_DOWN "
        _latest_drag_event = event
        is_touch_down = true
        pointer_drag_screen_position = event.position
        pointer_drag_level_position = Sc.utils.get_level_position_for_screen_event(event)
        touch = _add_touch_to_buffer(
                0,
                pointer_drag_screen_position,
                pointer_drag_level_position)
        
    # Mouse-move: Position pre-selection.
    elif event is InputEventMouseMotion and \
            !_active_gestures.empty():
        was_latest_touch_part_of_multi_touch = false
        event_type = "MOUSE_DRAG "
        _latest_drag_event = event
        pointer_drag_screen_position = event.position
        pointer_drag_level_position = Sc.utils.get_level_position_for_screen_event(event)
        touch = _add_touch_to_buffer(
                0,
                pointer_drag_screen_position,
                pointer_drag_level_position)
        
    # Touch-up: Position selection.
    elif event is InputEventScreenTouch and \
            !event.pressed:
        event_type = "TOUCH_UP   "
        pointer_up_screen_position = event.position
        pointer_up_level_position = Sc.utils.get_level_position_for_screen_event(event)
        _clear_touch_buffer(event.index)
        
    # Touch-down: Position pre-selection.
    elif event is InputEventScreenTouch and \
            event.pressed:
        if _active_gestures.empty():
            # This is the first touch of a new touch set.
            was_latest_touch_part_of_multi_touch = false
        event_type = "TOUCH_DOWN "
        _latest_drag_event = event
        is_touch_down = true
        pointer_drag_screen_position = event.position
        pointer_drag_level_position = Sc.utils.get_level_position_for_screen_event(event)
        touch = _add_touch_to_buffer(
                event.index,
                pointer_drag_screen_position,
                pointer_drag_level_position)
        if _active_gestures.size() > 1:
            was_latest_touch_part_of_multi_touch = true
        
    # Touch-move: Position pre-selection.
    elif event is InputEventScreenDrag:
        if _active_gestures.empty():
            # This is the first touch of a new touch set.
            was_latest_touch_part_of_multi_touch = false
        event_type = "TOUCH_DRAG "
        _latest_drag_event = event
        pointer_drag_screen_position = event.position
        pointer_drag_level_position = Sc.utils.get_level_position_for_screen_event(event)
        touch = _add_touch_to_buffer(
                event.index,
                pointer_drag_screen_position,
                pointer_drag_level_position)
        if _active_gestures.size() > 1:
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
    
    if pointer_drag_level_position != Vector2.INF:
        _current_touch = touch
    
    if _active_gestures.size() == 1:
        # This could be false if we just released one touch in a multi-touch
        # set.
        if pointer_drag_level_position != Vector2.INF:
            if is_touch_down:
                _on_single_touch_down(touch)
            else:
                _on_single_touch_moved(touch)
        if pointer_up_level_position != Vector2.INF:
            _on_pinch_first_touch_released(
                    pointer_up_screen_position,
                    pointer_up_level_position)
    elif _active_gestures.size() == 2:
        if previous_touch_count == 1:
            _on_pinch_second_touch_down(touch)
        _on_pinch_changed(touch)
    elif _active_gestures.empty():
        _current_touch = null
        if pointer_up_level_position != Vector2.INF:
            _on_single_touch_released(
                    pointer_up_screen_position,
                    pointer_up_level_position)
            if was_latest_touch_part_of_multi_touch:
                _on_pinch_second_touch_released(
                    pointer_up_screen_position,
                    pointer_up_level_position)
    else:
        # Multi-touch event with more than 2 touches.
        pass


func _on_single_touch_down(touch: Touch) -> void:
    touch_down_screen_position = touch.screen_position
    latest_drag_screen_position = touch.screen_position
    release_screen_position = Vector2.INF
    touch_down_level_position = touch.level_position
    latest_drag_level_position = touch.level_position
    release_level_position = Vector2.INF
    latest_touch_time = Sc.time.get_play_time()
    touch_down_time = Sc.time.get_play_time()
    current_pinch_screen_distance = INF
    current_pinch_angle = INF
    current_pinch_center_level_position = Vector2.INF
    emit_signal(
            "single_touch_down",
            touch.screen_position,
            touch.level_position)
    call_deferred("call_deferred", "_check_for_unhandled_single_touch_down")


func _on_single_touch_moved(touch: Touch) -> void:
    latest_drag_screen_position = touch.screen_position
    release_screen_position = Vector2.INF
    latest_drag_level_position = touch.level_position
    release_level_position = Vector2.INF
    latest_touch_time = Sc.time.get_play_time()
    current_pinch_screen_distance = INF
    current_pinch_angle = INF
    current_pinch_center_level_position = Vector2.INF
    emit_signal(
            "single_touch_dragged",
            touch.screen_position,
            touch.level_position,
            _get_has_corresponding_touch_down())
    call_deferred("call_deferred", "_check_for_unhandled_single_touch_dragged")


func _on_single_touch_released(
        pointer_screen_position: Vector2,
        pointer_level_position: Vector2) -> void:
    latest_drag_screen_position = Vector2.INF
    release_screen_position = pointer_screen_position
    latest_drag_level_position = Vector2.INF
    release_level_position = pointer_level_position
    latest_touch_time = Sc.time.get_play_time()
    release_time = Sc.time.get_play_time()
    current_pinch_screen_distance = INF
    current_pinch_angle = INF
    current_pinch_center_level_position = Vector2.INF
    emit_signal(
            "single_touch_released",
            pointer_screen_position,
            pointer_level_position,
            _get_has_corresponding_touch_down())
    call_deferred("call_deferred", "_check_for_unhandled_single_touch_released")


func _check_for_unhandled_single_touch_down() -> void:
    if !get_is_current_touch_handled():
        emit_signal(
                "single_unhandled_touch_down",
                touch_down_screen_position,
                touch_down_level_position)


func _check_for_unhandled_single_touch_dragged() -> void:
    if !get_is_current_touch_handled():
        emit_signal(
                "single_unhandled_touch_dragged",
                latest_drag_screen_position,
                latest_drag_level_position,
                _get_has_corresponding_touch_down())


func _check_for_unhandled_single_touch_released() -> void:
    if !get_is_current_touch_handled():
        emit_signal(
                "single_unhandled_touch_released",
                release_screen_position,
                release_level_position,
                _get_has_corresponding_touch_down())


func _on_pinch_second_touch_down(touch: Touch) -> void:
    latest_touch_time = Sc.time.get_play_time()
    emit_signal("pinch_second_touch_down")


func _on_pinch_changed(touch: Touch) -> void:
    latest_drag_screen_position = Vector2.INF
    release_screen_position = Vector2.INF
    latest_drag_level_position = Vector2.INF
    release_level_position = Vector2.INF
    latest_touch_time = Sc.time.get_play_time()
    current_pinch_screen_distance = touch.pinch_distance
    current_pinch_angle = touch.pinch_angle
    current_pinch_center_level_position = touch.pinch_center_level_position
    emit_signal(
            "pinch_changed", current_pinch_screen_distance, current_pinch_angle)


func _on_pinch_first_touch_released(
        pointer_screen_position: Vector2,
        pointer_level_position: Vector2) -> void:
    latest_touch_time = Sc.time.get_play_time()
    emit_signal("pinch_first_touch_released")


func _on_pinch_second_touch_released(
        pointer_screen_position: Vector2,
        pointer_level_position: Vector2) -> void:
    latest_drag_screen_position = Vector2.INF
    release_screen_position = Vector2.INF
    latest_drag_level_position = Vector2.INF
    release_level_position = Vector2.INF
    latest_touch_time = Sc.time.get_play_time()
    current_pinch_screen_distance = INF
    current_pinch_angle = INF
    current_pinch_center_level_position = Vector2.INF
    emit_signal("pinch_second_touch_released")


func set_current_touch_as_handled() -> void:
    _touch_handled_time = Sc.time.get_play_time()


func set_current_touch_as_not_handled() -> void:
    _touch_handled_time = -INF


func get_is_current_touch_handled() -> bool:
    return latest_touch_time - _touch_handled_time < \
            Sc.time.PHYSICS_TIME_STEP + 0.001


func _get_is_touch_active() -> bool:
    return _active_gestures.size() > 0


func _get_is_multi_touch_active() -> bool:
    return _active_gestures.size() > 1


func _get_current_drag_screen_displacement() -> Vector2:
    if _active_gestures.size() == 1:
        return _current_touch.get_current_drag_screen_displacement()
    else:
        return Vector2.ZERO


func _get_current_drag_level_velocity() -> Vector2:
    if _active_gestures.size() == 1:
        return _current_touch.level_velocity
    else:
        return Vector2.ZERO


func _get_current_pinch_screen_distance_change() -> float:
    if _active_gestures.size() == 2:
        var previous_pinch_distance := \
                _current_touch.get_previous_pinch_distance()
        if !is_inf(previous_pinch_distance):
            return _current_touch.pinch_distance - previous_pinch_distance
        else:
            return 0.0
    else:
        return 0.0


func _get_current_pinch_screen_distance_ratio_from_previous() -> float:
    if _active_gestures.size() == 2:
        var previous_pinch_distance := \
                _current_touch.get_previous_pinch_distance()
        if !is_inf(previous_pinch_distance):
            return _current_touch.pinch_distance / previous_pinch_distance
        else:
            return 1.0
    else:
        return 1.0


func _get_current_pinch_screen_distance_speed() -> float:
    # FIXME: ------ Implement this.
    return 0.0


func _get_current_pinch_angle_change() -> float:
    if _active_gestures.size() == 2:
        var previous_pinch_angle := _current_touch.get_previous_pinch_angle()
        if !is_inf(previous_pinch_angle):
            return _current_touch.pinch_angle - previous_pinch_angle
        else:
            return 0.0
    else:
        return 0.0


func _get_current_pinch_angle_speed() -> float:
    # FIXME: ------ Implement this.
    return 0.0


func _get_current_drag_level_position_with_current_camera_pan() -> Vector2:
    return Sc.utils.get_level_position_for_screen_event(_latest_drag_event)


func _get_has_corresponding_touch_down() -> bool:
    return !is_inf(touch_down_time) and \
            (is_inf(release_time) or \
                touch_down_time > release_time)


func get_is_control_pressed() -> bool:
    return Sc.level_button_input.is_key_pressed(KEY_CONTROL) or \
            Sc.level_button_input.is_key_pressed(KEY_META)


func _get_circular_buffer(touch_index: int) -> CircularBuffer:
    if !_touch_index_to_touch_buffer.has(touch_index):
        _touch_index_to_touch_buffer[touch_index] = \
                CircularBuffer.new(_TOUCH_EVENT_CIRCULAR_BUFFER_SIZE, true)
    return _touch_index_to_touch_buffer[touch_index]


func _add_touch_to_buffer(
        touch_index: int,
        pointer_drag_screen_position: Vector2,
        pointer_drag_level_position: Vector2) -> Touch:
    var current_time: float = Sc.time.get_play_time()
    var touch_buffer := _get_circular_buffer(touch_index)
    
    _active_gestures[touch_index] = touch_buffer
    
    # Get the previous drag touch.
    var previous_drag_touch: Touch
    if touch_buffer.empty():
        previous_drag_touch = null
    else:
        previous_drag_touch = touch_buffer.peek()
    
    # Calculate the index of an earlier touch-event, which we'll use to
    # calculate the velocity of this current event.
    var velocity_basis_index: int
    if touch_buffer.empty():
        velocity_basis_index = -1
    elif touch_buffer.size() == 1:
        velocity_basis_index = touch_buffer._previous_index
    else:
        # Find the earliest entry that is more recent than our delta-time for
        # velocity tracking.
        var previous_velocity_basis_index := \
                previous_drag_touch.velocity_basis_index
        var previous_velocity_basis_entry: Touch = \
                touch_buffer._buffer[previous_velocity_basis_index]
        while current_time - previous_velocity_basis_entry.time > \
                _DRAG_DELTA_TIME_FOR_VELOCITY_TRACKING and \
                previous_velocity_basis_entry != previous_drag_touch:
            previous_velocity_basis_index = \
                    (previous_velocity_basis_index + 1) % touch_buffer._capacity
            previous_velocity_basis_entry = \
                    touch_buffer._buffer[previous_velocity_basis_index]
        
        # Now get the entry that's immediately before that (this is the latest
        # entry that is less recent than our delta-time for velocity tracking.
        var earlier_index := \
                (previous_velocity_basis_index - 1 + touch_buffer._capacity) % \
                touch_buffer._capacity
        var earlier_entry = touch_buffer._buffer[earlier_index]
        if !is_instance_valid(earlier_entry):
            earlier_index = previous_velocity_basis_index
            earlier_entry = previous_velocity_basis_entry
        
        velocity_basis_index = earlier_index
    
    # Calculate the velocity.
    var level_velocity: Vector2
    if velocity_basis_index >= 0:
        var velocity_basis_entry: Touch = \
                touch_buffer._buffer[velocity_basis_index]
        var delta_time: float = current_time - velocity_basis_entry.time
        var level_displacement: Vector2 = \
                pointer_drag_level_position - \
                velocity_basis_entry.level_position
        if delta_time > 0.0:
            level_velocity = level_displacement / delta_time
        else:
            level_velocity = Vector2.ZERO
    else:
        level_velocity = Vector2.ZERO
    
    # Calculate pinch distance and angle.
    var other_pinch_touch: Touch
    var pinch_distance: float
    var pinch_angle: float
    var pinch_center_level_position: Vector2
    if touch_index > 0 or _active_gestures.size() > 1:
        for other_touch_index in _active_gestures:
            if other_touch_index != touch_index:
                other_pinch_touch = _active_gestures[other_touch_index].peek()
                break
        assert(is_instance_valid(other_pinch_touch))
        pinch_distance = pointer_drag_screen_position.distance_to(
                other_pinch_touch.screen_position)
        pinch_angle = pointer_drag_screen_position.angle_to_point(
                other_pinch_touch.screen_position)
        pinch_center_level_position = lerp(
                pointer_drag_level_position,
                other_pinch_touch.level_position,
                0.5)
    else:
        other_pinch_touch = null
        pinch_distance = INF
        pinch_angle = INF
        pinch_center_level_position = Vector2.INF
    
    var touch := Touch.new()
    touch.screen_position = pointer_drag_screen_position
    touch.level_position = pointer_drag_level_position
    touch.time = current_time
    touch.level_velocity = level_velocity
    touch.velocity_basis_index = velocity_basis_index
    touch.pinch_distance = pinch_distance
    touch.pinch_angle = pinch_angle
    touch.pinch_center_level_position = pinch_center_level_position
    touch.previous_drag_touch = previous_drag_touch
    touch.other_pinch_touch = other_pinch_touch
    
    touch_buffer.push(touch)
    
    return touch


func _clear_touch_buffer(touch_index: int) -> void:
    var touch_buffer := _get_circular_buffer(touch_index)
    touch_buffer.clear()
    _active_gestures.erase(touch_index)


class Touch extends Object:
    var screen_position := Vector2.INF
    var level_position := Vector2.INF
    
    var time := INF
    
    var velocity_basis_index := -1
    var level_velocity := Vector2.ZERO
    
    var pinch_distance := INF
    var pinch_angle := INF
    var pinch_center_level_position := Vector2.INF
    
    var previous_drag_touch: Touch
    var other_pinch_touch: Touch
    
    
    func get_current_drag_screen_displacement() -> Vector2:
        if is_instance_valid(previous_drag_touch):
            return self.screen_position - previous_drag_touch.screen_position
        else:
            return Vector2.ZERO
    
    
    func get_previous_pinch_distance() -> float:
        var previous_touch_for_pinch := \
                _get_most_recent_previous_touch_for_pinch()
        if is_instance_valid(previous_touch_for_pinch):
            return previous_touch_for_pinch.pinch_distance
        else:
            return INF
    
    
    func get_previous_pinch_angle() -> float:
        var previous_touch_for_pinch := \
                _get_most_recent_previous_touch_for_pinch()
        if is_instance_valid(previous_touch_for_pinch):
            return previous_touch_for_pinch.pinch_angle
        else:
            return INF
    
    
    func _get_most_recent_previous_touch_for_pinch() -> Touch:
        if is_instance_valid(other_pinch_touch):
            if is_instance_valid(previous_drag_touch):
                if is_instance_valid(other_pinch_touch.previous_drag_touch):
                    if previous_drag_touch.time > \
                            other_pinch_touch.previous_drag_touch.time:
                        return previous_drag_touch
                    else:
                        return other_pinch_touch.previous_drag_touch
                else:
                    return previous_drag_touch
            elif is_instance_valid(other_pinch_touch.previous_drag_touch):
                return other_pinch_touch.previous_drag_touch
            else:
                return null
        else:
            return null

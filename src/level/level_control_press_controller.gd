class_name LevelControlPressController
extends Node2D


# TODO: Store controls in an RTree?

# Array<LevelControl>
var _level_controls := []

# Array<[int, Vector2, LevelControl]>
var _events_in_current_frame := []

# Dictinary<LevelControl, bool>
var _hovered_controls := {}

# Dictinary<LevelControl, bool>
var _excluded_controls := {}

# Dictinary<LevelControl, bool>
var _included_exclusively_controls := {}

var are_touches_disabled := false

var _hovered_control: LevelControl

var _is_digest_scheduled := false

var _latest_touch_screen_position := Vector2.INF
var _latest_touch_level_position := Vector2.INF

var _throttled_on_level_touch_moved: FuncRef = Sc.time.throttle(
        self, "_on_level_touch_moved_throttled", 0.1, true)


func _destroy() -> void:
    queue_free()


func _unhandled_input(event: InputEvent) -> void:
    # NOTE: We don't handle mouse button events, since we should be emulating
    #       touch events for those.
    if event is InputEventScreenTouch:
        _latest_touch_screen_position = event.position
        _latest_touch_level_position = Sc.utils.get_level_position_for_screen_event(event)
        if event.pressed:
            _on_level_touch_down()
        else:
            _on_level_touch_up()
    elif event is InputEventScreenDrag or \
            event is InputEventMouseMotion:
        _latest_touch_screen_position = event.position
        _latest_touch_level_position = Sc.utils.get_level_position_for_screen_event(event)
        _throttled_on_level_touch_moved.call_func()


func add_control(control: LevelControl) -> void:
    _level_controls.push_back(control)


func remove_control(control: LevelControl) -> void:
    _level_controls.erase(control)


func exclude_control(control: LevelControl) -> void:
    _included_exclusively_controls.erase(control)
    _excluded_controls[control] = true


func included_exclusively_control(control: LevelControl) -> void:
    _included_exclusively_controls[control] = true
    _excluded_controls.erase(control)


func reset_control_exclusivity(control: LevelControl) -> void:
    _included_exclusively_controls.erase(control)
    _excluded_controls.erase(control)


func _erase_control(control: LevelControl) -> void:
    _level_controls.erase(control)
    _hovered_controls.erase(control)
    _excluded_controls.erase(control)
    _included_exclusively_controls.erase(control)


func _on_level_touch_down() -> void:
    register_touch_event(
            LevelControl.TouchType.TOUCH_DOWN,
            _latest_touch_level_position,
            null)


func _on_level_touch_up() -> void:
    register_touch_event(
            LevelControl.TouchType.TOUCH_UP,
            _latest_touch_level_position,
            null)


func _on_level_touch_moved_throttled() -> void:
    register_touch_event(
            LevelControl.TouchType.TOUCH_MOVE,
            _latest_touch_level_position,
            null)


func register_touch_event(
        touch_type: int,
        level_position: Vector2,
        control: LevelControl) -> void:
    _events_in_current_frame.push_back([
        touch_type,
        level_position,
        control,
    ])
    _trigger_digest()


func register_touch_entered(control: LevelControl) -> void:
    _hovered_controls[control] = true
    _update_cursor()
    _trigger_digest()


func register_touch_exited(control: LevelControl) -> void:
    _hovered_controls.erase(control)
    _update_cursor()
    _trigger_digest()


func _update_cursor() -> void:
    if _hovered_controls.empty() and \
            !is_instance_valid(_hovered_control):
        Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    else:
        Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _trigger_digest() -> void:
    if !_is_digest_scheduled:
        _is_digest_scheduled = true
        call_deferred("_digest_touches")


func _digest_touches() -> void:
    assert(_is_digest_scheduled)
    _is_digest_scheduled = false
    
    if _events_in_current_frame.empty():
        # This happens on control-local touch_enter/touch_exit, since the
        # corresponding level-global event is throttled.
        _update_hovered_control()
        return
    
    # Determine whether the touch event this frame happened within the
    # collision-area of a LevelControl.
    var closest_control: LevelControl
    var closest_distance_squared := INF
    var closest_event: Array
    for event in _events_in_current_frame:
        var current_control: LevelControl = event[2]
        if !is_instance_valid(current_control):
            # This is a level-global event rather than a control-local event.
            continue
        if current_control.mouse_filter == Control.MOUSE_FILTER_IGNORE or \
                are_touches_disabled or \
                _excluded_controls.has(current_control) or \
                !_included_exclusively_controls.empty() and \
                !_included_exclusively_controls.has(current_control):
            continue
        var current_distance_squared: float = event[1].distance_squared_to(
                current_control.get_center_in_level_space()) - \
            current_control.distance_squared_offset_for_selection_priority
        if current_distance_squared < closest_distance_squared:
            closest_control = current_control
            closest_distance_squared = current_distance_squared
            closest_event = event
    
    if is_instance_valid(closest_control):
        # The touch event this frame happened within the collision-area of a
        # LevelControl.
        assert(_events_in_current_frame.size() >= 2,
                "If there was control-local event, then there should have " +
                "also been a level-global event.")
        _set_hovered_control(closest_control)
        match closest_event[0]:
            LevelControl.TouchType.TOUCH_DOWN:
                closest_control._on_touch_down(
                        _latest_touch_level_position,
                        Sc.level.touch_listener \
                            .get_is_current_touch_handled())
            LevelControl.TouchType.TOUCH_UP:
                closest_control._on_touch_up(
                        _latest_touch_level_position,
                        Sc.level.touch_listener \
                            .get_is_current_touch_handled())
            LevelControl.TouchType.TOUCH_MOVE, \
            _:
                Sc.logger.error("LevelControlPressController._digest_touches")
    else:
        # Determine which event we're using.
        var event: Array
        if _events_in_current_frame.size() == 1:
            event = _events_in_current_frame[0]
        else:
            var touch_down_event: Array
            var touch_up_event: Array
            var touch_move_event: Array
            for e in _events_in_current_frame:
                match e[0]:
                    LevelControl.TouchType.TOUCH_DOWN:
                        touch_down_event = e
                    LevelControl.TouchType.TOUCH_UP:
                        touch_up_event = e
                    LevelControl.TouchType.TOUCH_MOVE:
                        touch_move_event = e
                    _:
                        Sc.logger.error(
                                "LevelControlPressController._digest_touches")
            if !touch_up_event.empty():
                event = touch_up_event
            elif !touch_down_event.empty():
                event = touch_down_event
            else:
                event = touch_move_event
        
        match event[0]:
            LevelControl.TouchType.TOUCH_DOWN:
                # The touch-down event didn't happen within the collision-area
                # of a LevelControl, but it might be within the bounds of a
                # control's screen-space radius.
                var control := _get_closest_control_within_screen_space_radius()
                if is_instance_valid(control):
                    control._on_touch_down(
                            _latest_touch_level_position,
                            Sc.level.touch_listener \
                                .get_is_current_touch_handled())
            LevelControl.TouchType.TOUCH_UP:
                # The touch-up event didn't happen within the collision-area
                # of a LevelControl, but it might be within the bounds of a
                # control's screen-space radius.
                var control := _get_closest_control_within_screen_space_radius()
                if is_instance_valid(control):
                    control._on_touch_up(
                            _latest_touch_level_position,
                            Sc.level.touch_listener \
                                .get_is_current_touch_handled())
            LevelControl.TouchType.TOUCH_MOVE:
                _update_hovered_control()
            _:
                Sc.logger.error("LevelControlPressController._digest_touches")
    
    _events_in_current_frame.clear()


func _update_hovered_control() -> void:
    var closest_valid_control: LevelControl
    if !_hovered_controls.empty():
        # The current touch is within the bounds of a control's collision-area.
        var closest_distance_squared := INF
        var controls_to_erase := []
        for control in _hovered_controls:
            if !is_instance_valid(control):
                controls_to_erase.push_back(control)
                continue
            if control.mouse_filter == Control.MOUSE_FILTER_IGNORE or \
                    are_touches_disabled or \
                    _excluded_controls.has(control) or \
                    !_included_exclusively_controls.empty() and \
                    !_included_exclusively_controls.has(control):
                continue
            var current_distance_squared: float = \
                    _latest_touch_level_position.distance_squared_to(
                        control.get_center_in_level_space()) - \
                    control.distance_squared_offset_for_selection_priority
            if current_distance_squared < closest_distance_squared:
                closest_valid_control = control
                closest_distance_squared = current_distance_squared
        # TODO:
        # - This is a hack!
        # - For some reason, attempting to erase a null value (or probably
        #   actually a freed object) from the Dictionary is failing here.
        if controls_to_erase.size() == _hovered_controls.size():
            _hovered_controls.clear()
        for control in controls_to_erase:
            _erase_control(control)
    if _hovered_controls.empty():
        # The current touch isn't within the bounds of any control's
        # collision-area, but it might be within the bounds of a control's
        # screen-space radius.
        closest_valid_control = \
                _get_closest_control_within_screen_space_radius()
    _set_hovered_control(closest_valid_control)


func _set_hovered_control(control: LevelControl) -> void:
    if _hovered_control != control:
        var previous_hovered_control := _hovered_control
        _hovered_control = control
        if is_instance_valid(previous_hovered_control):
            previous_hovered_control._on_touch_exited()
        if is_instance_valid(_hovered_control):
            _hovered_control._on_touch_entered()
    _update_cursor()


func _get_closest_control_within_screen_space_radius() -> LevelControl:
    var closest_valid_control: LevelControl
    var closest_distance_squared := INF
    var controls_to_erase := []
    for control in _level_controls:
        if !is_instance_valid(control):
            controls_to_erase.push_back(control)
            continue
        if control.mouse_filter == Control.MOUSE_FILTER_IGNORE or \
                are_touches_disabled or \
                _excluded_controls.has(control) or \
                !_included_exclusively_controls.empty() and \
                !_included_exclusively_controls.has(control):
            continue
        var current_distance_squared: float = \
                _latest_touch_screen_position.distance_squared_to(
                    control.get_center_in_screen_space()) - \
                control.distance_squared_offset_for_selection_priority
        if current_distance_squared < closest_distance_squared and \
                current_distance_squared < \
                    control.screen_radius * control.screen_radius * \
                    Sc.gui.scale * Sc.gui.scale:
            closest_valid_control = control
            closest_distance_squared = current_distance_squared
    for control in controls_to_erase:
        _erase_control(control)
    return closest_valid_control

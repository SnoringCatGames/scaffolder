class_name SwipeCamera
extends ScaffolderCamera


var _is_pan_continuation_active := false
var _is_zoom_continuation_active := false
var _pan_velocity := Vector2.ZERO
var _zoom_speed := 0.0
var _zoom_target_level_position := Vector2.INF


func _init() -> void:
    Sc.level.touch_listener.connect(
            "single_touch_dragged", self, "_on_single_touch_dragged")
    Sc.level.touch_listener.connect(
            "single_touch_released", self, "_on_single_touch_released")
    Sc.level.touch_listener.connect(
            "pinch_changed", self, "_on_pinch_changed")
    Sc.level.touch_listener.connect(
            "pinch_first_touch_released",
            self,
            "_on_pinch_first_touch_released")


func _validate() -> void:
    assert(Sc.gui.is_player_interaction_enabled)


func reset(emits_signal := true) -> void:
    _is_pan_continuation_active = false
    _is_zoom_continuation_active = false
    _pan_velocity = Vector2.ZERO
    _zoom_speed = 0.0
    _zoom_target_level_position = Vector2.INF
    .reset(emits_signal)


func _set_is_active(value: bool) -> void:
    var previous_camera: ScaffolderCamera = Sc.level.camera
    if value and is_instance_valid(previous_camera):
        _update_controller_offset_and_zoom(
                previous_camera.offset,
                _target_controller_zoom,
                false)
    ._set_is_active(value)
    if !value:
        _is_pan_continuation_active = false
        _is_zoom_continuation_active = false
        _pan_velocity = Vector2.ZERO
        _zoom_speed = 0.0
        _zoom_target_level_position = Vector2.INF


func _physics_process(physics_play_time_delta: float) -> void:
    if !_get_is_active():
        return
    _update_pan_continuation(physics_play_time_delta)
    _update_zoom_continuation(physics_play_time_delta)


func _update_pan_continuation(physics_play_time_delta: float) -> void:
    if !_is_pan_continuation_active:
        return
    
    if Sc.level.touch_listener.is_touch_active:
        # Stopped by a touch.
        _pan_velocity = Vector2.ZERO
        _is_pan_continuation_active = false
        return
    
    if _pan_velocity == Vector2.ZERO:
        # TODO: This shouldn't be possible, but is happening in practice.
        _pan_velocity = Vector2.ZERO
        _is_pan_continuation_active = false
        return
    
    assert(_pan_velocity != Vector2.ZERO and \
            _pan_velocity != Vector2.INF and \
            !is_nan(_pan_velocity.x))
    
    var pan_direction := _pan_velocity.normalized()
    
    var min_velocity_x: float
    var min_velocity_y: float
    var max_velocity_x: float
    var max_velocity_y: float
    if _pan_velocity.x < 0:
        min_velocity_x = _pan_velocity.x
        max_velocity_x = 0.0
    else:
        min_velocity_x = 0.0
        max_velocity_x = _pan_velocity.x
    if _pan_velocity.y < 0:
        min_velocity_y = _pan_velocity.y
        max_velocity_y = 0.0
    else:
        min_velocity_y = 0.0
        max_velocity_y = _pan_velocity.y
    
    var deceleration := \
            Sc.camera.swipe_pan_continuation_deceleration * self.zoom.x
    
    _pan_velocity += pan_direction * deceleration * physics_play_time_delta
    
    _pan_velocity.x = clamp(_pan_velocity.x, min_velocity_x, max_velocity_x)
    _pan_velocity.y = clamp(_pan_velocity.y, min_velocity_y, max_velocity_y)
    
    assert(_pan_velocity != Vector2.INF and \
            !is_nan(_pan_velocity.x))
    
    if _pan_velocity.length_squared() < \
            Sc.camera.swipe_pan_continuation_min_speed * Sc.camera.swipe_pan_continuation_min_speed:
        # Slowed to a stop.
        _pan_velocity = Vector2.ZERO
        _is_pan_continuation_active = false
        return
    
    var delta_offset := \
            _pan_velocity * physics_play_time_delta * \
            Sc.camera.swipe_pan_speed_multiplier
    var offset := _target_controller_offset + delta_offset
    
    _update_controller_offset_and_zoom(offset, _target_controller_zoom, false)


func _update_zoom_continuation(physics_play_time_delta: float) -> void:
    # FIXME: ------
    # - Test/implement this.
    # - Also, LevelTouchListener's
    #   _get_current_pinch_screen_distance_speed and
    #   _get_current_pinch_angle_speed.
    # - Will probably need to do some clever touch pinch-basis logic similar to
    #   Touch.velocity_basis_index.
    
    if !_is_zoom_continuation_active:
        return
    
    if Sc.level.touch_listener.is_multi_touch_active:
        # Stopped by a touch.
        _zoom_speed = 0.0
        _zoom_target_level_position = Vector2.INF
        _is_zoom_continuation_active = false
        return
    
    assert(_zoom_speed != 0.0 and !is_inf(_zoom_speed))
    
    var deceleration := \
            Sc.camera.swipe_zoom_continuation_deceleration if \
            _zoom_speed > 0.0 else \
            -Sc.camera.swipe_zoom_continuation_deceleration
    _zoom_speed += deceleration * physics_play_time_delta
    
    if abs(_zoom_speed) < Sc.camera.swipe_zoom_continuation_min_speed:
        # Slowed to a stop.
        _zoom_speed = 0.0
        _zoom_target_level_position = Vector2.INF
        _is_zoom_continuation_active = false
        return
    
    var zoom_speed_distance_ratio := 1.0 + _zoom_speed
    if zoom_speed_distance_ratio > 1.0:
        zoom_speed_distance_ratio = \
                1.0 + (zoom_speed_distance_ratio - 1.0) * Sc.camera.swipe_pinch_zoom_speed_multiplier
    else:
        zoom_speed_distance_ratio = \
                1.0 - (1.0 - zoom_speed_distance_ratio) * Sc.camera.swipe_pinch_zoom_speed_multiplier
    var zoom: float = _target_controller_zoom / zoom_speed_distance_ratio
    
    _zoom_to_position(zoom, _zoom_target_level_position, false)


func _start_pan_continuation() -> void:
    if _is_pan_continuation_active:
        return
    if _pan_velocity == Vector2.ZERO:
        return
    _is_pan_continuation_active = true


func _start_zoom_continuation() -> void:
    if _is_zoom_continuation_active:
        return
    if _zoom_speed == 0.0:
        return
    _is_zoom_continuation_active = true


func _on_single_touch_dragged(
        pointer_screen_position: Vector2,
        pointer_level_position: Vector2,
        has_corresponding_touch_down: bool) -> void:
    if !_get_is_active() or \
            !has_corresponding_touch_down or \
            Sc.level.touch_listener.get_is_control_pressed():
        return
    self._pan_velocity = Sc.geometry.clamp_vector_length(
            Sc.level.touch_listener.current_drag_level_velocity,
            0.0,
            Sc.camera.swipe_max_pan_speed)
    var offset: Vector2 = \
            _target_controller_offset - \
            Sc.level.touch_listener.current_drag_screen_displacement * \
            Sc.camera.swipe_pan_speed_multiplier * \
            self.zoom.x
    _update_controller_offset_and_zoom(offset, _target_controller_zoom, false)


func _on_single_touch_released(
        pointer_screen_position: Vector2,
        pointer_level_position: Vector2,
        has_corresponding_touch_down: bool) -> void:
    if !_get_is_active() or \
            Sc.level.touch_listener.get_is_control_pressed():
        return
    _start_pan_continuation()


func _on_pinch_changed(
        pinch_distance: float,
        pinch_angle: float) -> void:
    if !_get_is_active():
        return
    self._zoom_target_level_position = \
            Sc.level.touch_listener.current_pinch_center_level_position
    self._zoom_speed = \
            Sc.level.touch_listener.current_pinch_screen_distance_speed / \
            Sc.level.touch_listener.current_pinch_screen_distance
    
    var distance_ratio := \
            Sc.level.touch_listener.current_pinch_screen_distance_ratio_from_previous
    if distance_ratio > 1.0:
        distance_ratio = 1.0 + (distance_ratio - 1.0) * Sc.camera.swipe_pinch_zoom_speed_multiplier
    else:
        distance_ratio = 1.0 - (1.0 - distance_ratio) * Sc.camera.swipe_pinch_zoom_speed_multiplier
    var zoom: float = _target_controller_zoom / distance_ratio
    
    _zoom_to_position(zoom, _zoom_target_level_position, false)


func _on_pinch_first_touch_released() -> void:
    if !_get_is_active():
        return
    _start_zoom_continuation()

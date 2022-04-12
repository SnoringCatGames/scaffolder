tool
class_name CameraController
extends Node2D


signal zoomed
signal panned

const _MANUAL_ZOOM_STEP_RATIO := 0.05
const PAN_STEP := 8.0

const ZOOM_ANIMATION_DURATION := 0.3
const OFFSET_ANIMATION_DURATION := 0.8

var _camera: Camera2D
var _character

var offset: Vector2 setget _set_offset,_get_offset

var _manual_offset := Vector2.ZERO
var _camera_swap_offset := Vector2.ZERO
var _camera_pan_controller_offset := Vector2.ZERO
var _misc_offset := Vector2.ZERO

var _manual_zoom := 1.0
var _camera_pan_controller_zoom := 1.0
var _misc_zoom := 1.0

var _camera_swap_offset_tween: ScaffolderTween


func _init() -> void:
    Sc.logger.on_global_init(self, "CameraController")


func _ready() -> void:
    _camera_swap_offset_tween = ScaffolderTween.new()
    add_child(_camera_swap_offset_tween)


func _process(_delta: float) -> void:
    if Engine.editor_hint:
        return
    
    if !is_instance_valid(_camera):
        return
    
    # Handle zooming.
    if Sc.level_button_input.is_action_pressed("zoom_in"):
        _set_manual_zoom(_manual_zoom * (1 - _MANUAL_ZOOM_STEP_RATIO))
    elif Sc.level_button_input.is_action_pressed("zoom_out"):
        _set_manual_zoom(_manual_zoom * (1 + _MANUAL_ZOOM_STEP_RATIO))
    
    # Handle Panning.
    if Sc.level_button_input.is_action_pressed("pan_up"):
        _set_manual_offset(Vector2(
                _manual_offset.x,
                _manual_offset.y - PAN_STEP))
    elif Sc.level_button_input.is_action_pressed("pan_down"):
        _set_manual_offset(Vector2(
                _manual_offset.x,
                _manual_offset.y + PAN_STEP))
    elif Sc.level_button_input.is_action_pressed("pan_left"):
        _set_manual_offset(Vector2(
                _manual_offset.x - PAN_STEP,
                _manual_offset.y))
    elif Sc.level_button_input.is_action_pressed("pan_right"):
        _set_manual_offset(Vector2(
                _manual_offset.x + PAN_STEP,
                _manual_offset.y))


func _unhandled_input(event: InputEvent) -> void:
    if Engine.editor_hint:
        return
    
    # Mouse wheel events are never considered pressed by Godot--rather they are
    # only ever considered to have just happened.
    if Sc.gui.is_player_interaction_enabled and \
            event is InputEventMouseButton and \
            is_instance_valid(_camera):
        if event.button_index == BUTTON_WHEEL_UP:
            _set_manual_zoom(_manual_zoom * (1 - _MANUAL_ZOOM_STEP_RATIO))
        if event.button_index == BUTTON_WHEEL_DOWN:
            _set_manual_zoom(_manual_zoom * (1 + _MANUAL_ZOOM_STEP_RATIO))


func _on_resized() -> void:
    _update_offset_and_zoom()


func set_current_camera(
        camera: Camera2D,
        character) -> void:
    var old_camera := _camera
    var old_character = _character
    self._camera = camera
    self._character = character
    camera.make_current()
    _update_offset_and_zoom()
    
    # Pan smoothly to the new camera.
    if is_instance_valid(old_camera):
        # NOTE: We have to use camera.get_camera_screen_center, rather than
        #       calculating the position difference ourselves, because
        #       camera.smoothing_enabled is likely true.
        var start_offset := Vector2.ZERO
        start_offset += old_camera.get_camera_screen_center()
        start_offset -= _camera.get_camera_screen_center()
        var end_offset := Vector2.ZERO
        _transition_offset_from_old_camera(
                start_offset,
                end_offset,
                OFFSET_ANIMATION_DURATION)
        old_camera.offset = Vector2.ZERO


func get_camera() -> Camera2D:
    return _camera


func _set_offset(offset: Vector2) -> void:
    if !is_instance_valid(_camera):
        return
    if _camera.offset == offset:
        return
    _camera.offset = offset
    emit_signal("panned")


func _get_offset() -> Vector2:
    if !is_instance_valid(_camera):
        return Vector2.ZERO
    return _camera.offset


func get_visible_region() -> Rect2:
    if !is_instance_valid(_camera):
        return Rect2()
    
    var canvas_transform := _camera.get_canvas_transform()
    var position := \
            -canvas_transform.get_origin() / canvas_transform.get_scale()
    var size := \
            _camera.get_viewport_rect().size / \
            canvas_transform.get_scale()
    
    return Rect2(position, size)


func get_position() -> Vector2:
    if !is_instance_valid(_camera):
        return Vector2.ZERO
    return _camera.get_camera_screen_center()


func get_zoom() -> float:
    if !is_instance_valid(_camera):
        return 1.0
    return _camera.zoom.x


func _set_manual_offset(offset: Vector2) -> void:
    self._manual_offset = offset
    _update_offset_and_zoom()


func _set_camera_swap_offset(offset: Vector2) -> void:
    self._camera_swap_offset = offset
    _update_offset_and_zoom()


func set_camera_pan_controller_offset(offset: Vector2) -> void:
    self._camera_pan_controller_offset = offset
    _update_offset_and_zoom()


func set_misc_offset(offset: Vector2) -> void:
    self._misc_offset = offset
    _update_offset_and_zoom()


func _set_manual_zoom(offset: float) -> void:
    self._manual_zoom = offset
    _update_offset_and_zoom()


func set_camera_pan_controller_zoom(zoom: float) -> void:
    self._camera_pan_controller_zoom = zoom
    _update_offset_and_zoom()


func set_misc_zoom(zoom: float) -> void:
    self._misc_zoom = zoom
    _update_offset_and_zoom()


func _transition_offset_from_old_camera(
        old_offset: Vector2,
        new_offset: Vector2,
        duration: float) -> void:
    var start_offset := \
            _get_offset() if \
            old_offset == Vector2.INF else \
            old_offset
    _set_camera_swap_offset(start_offset)
    _camera_swap_offset_tween.stop_all()
    if new_offset == start_offset:
        return
    _camera_swap_offset_tween.interpolate_method(
            self,
            "_set_camera_swap_offset",
            start_offset,
            new_offset,
            duration,
            "ease_in_out",
            0.0,
            TimeType.PLAY_PHYSICS_SCALED)
    _camera_swap_offset_tween.start()


func _update_offset_and_zoom() -> void:
    if !is_instance_valid(_camera):
        return
    
    var old_offset := _camera.offset
    var old_zoom := _camera.zoom.x
    
    var new_zoom: float = \
            _manual_zoom * \
            _camera_pan_controller_zoom * \
            _misc_zoom * \
            Sc.gui.gui_camera_zoom_factor / Sc.gui.scale
    var new_offset := \
            _manual_offset + \
            _camera_swap_offset + \
            _camera_pan_controller_offset + \
            _misc_offset
    
#    Sc.logger.print((
#        "CameraController._update_offset_and_zoom:" +
#        "\n  offset: %s (ma=%s, cs=%s, pc=%s, mi=%s)" +
#        "\n  zoom: %1.1f (ma=%1.1f, pc=%1.1f, mi=%1.1f, gu=%1.1f)"
#    ) % [
#        Sc.utils.get_vector_string(new_offset, 0),
#        Sc.utils.get_vector_string(_manual_offset, 0),
#        Sc.utils.get_vector_string(_camera_swap_offset, 0),
#        Sc.utils.get_vector_string(_camera_pan_controller_offset, 0),
#        Sc.utils.get_vector_string(_misc_offset, 0),
#        new_zoom,
#        _manual_zoom,
#        _camera_pan_controller_zoom,
#        _misc_zoom,
#        Sc.gui.gui_camera_zoom_factor / Sc.gui.scale,
#    ])
    
    _camera.offset = new_offset
    _camera.zoom = Vector2(new_zoom, new_zoom)
    
    if old_offset != new_offset:
        emit_signal("panned")
    if old_zoom != new_zoom:
        emit_signal("zoomed")

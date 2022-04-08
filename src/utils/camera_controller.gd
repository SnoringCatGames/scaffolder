tool
class_name CameraController
extends Node2D


signal zoomed
signal panned

const ZOOM_FACTOR_STEP_RATIO := 0.05
const PAN_STEP := 8.0

const ZOOM_ANIMATION_DURATION := 0.3
const OFFSET_ANIMATION_DURATION := 0.8

var _camera: Camera2D
var _character

var offset: Vector2 setget _set_offset,_get_offset
var zoom_factor := 1.0 setget _set_zoom_factor

var zoom_tween: ScaffolderTween
var offset_tween: ScaffolderTween


func _init() -> void:
    Sc.logger.on_global_init(self, "CameraController")


func _ready() -> void:
    zoom_tween = ScaffolderTween.new()
    add_child(zoom_tween)
    offset_tween = ScaffolderTween.new()
    add_child(offset_tween)


func _process(_delta: float) -> void:
    if Engine.editor_hint:
        return
    
    if !is_instance_valid(_camera):
        return
    
    # Handle zooming.
    if Sc.level_button_input.is_action_pressed("zoom_in"):
        _set_zoom_factor(zoom_factor * (1 - ZOOM_FACTOR_STEP_RATIO))
    elif Sc.level_button_input.is_action_pressed("zoom_out"):
        _set_zoom_factor(zoom_factor * (1 + ZOOM_FACTOR_STEP_RATIO))
    
    # Handle Panning.
    if Sc.level_button_input.is_action_pressed("pan_up"):
        _camera.offset.y -= PAN_STEP
    elif Sc.level_button_input.is_action_pressed("pan_down"):
        _camera.offset.y += PAN_STEP
    elif Sc.level_button_input.is_action_pressed("pan_left"):
        _camera.offset.x -= PAN_STEP
    elif Sc.level_button_input.is_action_pressed("pan_right"):
        _camera.offset.x += PAN_STEP


func _unhandled_input(event: InputEvent) -> void:
    if Engine.editor_hint:
        return
    
    # Mouse wheel events are never considered pressed by Godot--rather they are
    # only ever considered to have just happened.
    if Sc.gui.is_player_interaction_enabled and \
            event is InputEventMouseButton and \
            is_instance_valid(_camera):
        if event.button_index == BUTTON_WHEEL_UP:
            _set_zoom_factor(zoom_factor * (1 - ZOOM_FACTOR_STEP_RATIO))
        if event.button_index == BUTTON_WHEEL_DOWN:
            _set_zoom_factor(zoom_factor * (1 + ZOOM_FACTOR_STEP_RATIO))


func _on_resized() -> void:
    _update_zoom()


func set_current_camera(
        camera: Camera2D,
        character) -> void:
    var old_camera := _camera
    var old_character = _character
    self._camera = camera
    self._character = character
    camera.make_current()
    _update_zoom()
    
    # Pan smoothly to the new camera.
    if is_instance_valid(old_camera):
        # NOTE: We have to use camera.get_camera_screen_center, rather than
        #       calculating the position difference ourselves, because
        #       camera.smoothing_enabled is likely true.
        var start_offset := Vector2.ZERO
        start_offset += old_camera.get_camera_screen_center()
        start_offset -= _camera.get_camera_screen_center()
        var end_offset := Vector2.ZERO
        animate_to_offset(
                end_offset,
                OFFSET_ANIMATION_DURATION,
                start_offset)
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


func get_bounds() -> Rect2:
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


func get_derived_zoom() -> float:
    return zoom_factor * \
            Sc.gui.default_camera_zoom / \
            Sc.gui.scale


func _set_zoom_factor(value: float) -> void:
    if zoom_factor == value:
        return
    zoom_factor = value
    _update_zoom()
    emit_signal("zoomed")


func animate_to_zoom_factor(
        zoom_factor: float,
        duration := ZOOM_ANIMATION_DURATION) -> void:
    if self.zoom_factor == zoom_factor:
        return
    
    zoom_tween.stop_all()
    zoom_tween.interpolate_property(
            self,
            "zoom_factor",
            self.zoom_factor,
            zoom_factor,
            duration,
            "ease_in_out",
            0.0,
            TimeType.PLAY_PHYSICS_SCALED)
    zoom_tween.start()


func animate_to_offset(
        new_offset: Vector2,
        duration := OFFSET_ANIMATION_DURATION,
        old_offset := Vector2.INF) -> void:
    var start_offset := \
            _get_offset() if \
            old_offset == Vector2.INF else \
            old_offset
    if new_offset == start_offset:
        return
    
    offset_tween.stop_all()
    _set_offset(start_offset)
    offset_tween.interpolate_property(
            self,
            "offset",
            start_offset,
            new_offset,
            duration,
            "ease_in_out",
            0.0,
            TimeType.PLAY_PHYSICS_SCALED)
    offset_tween.start()


func _update_zoom() -> void:
    if !is_instance_valid(_camera):
        return
    var zoom := get_derived_zoom()
    _camera.zoom = Vector2(zoom, zoom)

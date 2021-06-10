class_name CameraController
extends Node2D


const ZOOM_FACTOR_STEP_RATIO := 0.05
const PAN_STEP := 8.0

const ZOOM_ANIMATION_DURATION := 0.3

var _current_camera: Camera2D
var _current_player

var offset: Vector2 setget _set_offset,_get_offset
var zoom_factor := 1.0 setget _set_zoom_factor

var zoom_tween: ScaffolderTween


func _init() -> void:
    name = "CameraController"


func _enter_tree() -> void:
    zoom_tween = ScaffolderTween.new()
    add_child(zoom_tween)


func _process(_delta: float) -> void:
    if is_instance_valid(_current_camera):
        # Handle zooming.
        if Gs.level_input.is_action_pressed("zoom_in"):
            _set_zoom_factor(zoom_factor * (1 - ZOOM_FACTOR_STEP_RATIO))
        elif Gs.level_input.is_action_pressed("zoom_out"):
            _set_zoom_factor(zoom_factor * (1 + ZOOM_FACTOR_STEP_RATIO))
    
        # Handle Panning.
        if Gs.level_input.is_action_pressed("pan_up"):
            _current_camera.offset.y -= PAN_STEP
        elif Gs.level_input.is_action_pressed("pan_down"):
            _current_camera.offset.y += PAN_STEP
        elif Gs.level_input.is_action_pressed("pan_left"):
            _current_camera.offset.x -= PAN_STEP
        elif Gs.level_input.is_action_pressed("pan_right"):
            _current_camera.offset.x += PAN_STEP


func _unhandled_input(event: InputEvent) -> void:
    # Mouse wheel events are never considered pressed by Godot--rather they are
    # only ever considered to have just happened.
    if Gs.is_user_interaction_enabled and \
            event is InputEventMouseButton and \
            is_instance_valid(_current_camera):
        if event.button_index == BUTTON_WHEEL_UP:
            _set_zoom_factor(zoom_factor * (1 - ZOOM_FACTOR_STEP_RATIO))
        if event.button_index == BUTTON_WHEEL_DOWN:
            _set_zoom_factor(zoom_factor * (1 + ZOOM_FACTOR_STEP_RATIO))


func _on_resized() -> void:
    _update_zoom()


func set_current_camera(
        camera: Camera2D,
        player) -> void:
    camera.make_current()
    _current_camera = camera
    _current_player = player
    _set_zoom_factor(zoom_factor)


func get_current_camera() -> Camera2D:
    return _current_camera


func _set_offset(offset: Vector2) -> void:
    if !is_instance_valid(_current_camera):
        return
    _current_camera.offset = offset


func _get_offset() -> Vector2:
    if !is_instance_valid(_current_camera):
        return Vector2.ZERO
    return _current_camera.offset


func get_bounds() -> Rect2:
    if !is_instance_valid(_current_camera):
        return Rect2()
    
    var canvas_transform := _current_camera.get_canvas_transform()
    var position := \
            -canvas_transform.get_origin() / canvas_transform.get_scale()
    var size := \
            _current_camera.get_viewport_rect().size / \
            canvas_transform.get_scale()
    
    return Rect2(position, size)


func get_position() -> Vector2:
    if !is_instance_valid(_current_camera):
        return Vector2.ZERO
    return _current_camera.get_camera_screen_center()


func get_derived_zoom() -> float:
    return zoom_factor * \
            Gs.default_camera_zoom / \
            Gs.gui_scale


func _set_zoom_factor(value: float) -> void:
    zoom_factor = value
    _update_zoom()


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


func _update_zoom() -> void:
    if !is_instance_valid(_current_camera):
        return
    var zoom := get_derived_zoom()
    _current_camera.zoom = Vector2(zoom, zoom)
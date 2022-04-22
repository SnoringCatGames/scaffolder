tool
class_name CameraDetector, \
"res://addons/scaffolder/assets/images/editor_icons/camera_detector.png"
extends ShapedLevelControl
## -   This detects when the viewport, or a part of it, intersects this area.


signal camera_enter
signal camera_exit

export var min_zoom := 0.0 setget _set_min_zoom
export var max_zoom := 100.0 setget _set_max_zoom

var is_camera_intersecting := false

var _throttled_on_panned_or_zoomed: FuncRef = Sc.time.throttle(
        self, "_on_panned_or_zoomed", 0.1)


func _ready() -> void:
    self.input_pickable = false
    Sc.camera.connect("panned", _throttled_on_panned_or_zoomed, "call_func")
    Sc.camera.connect("zoomed", _throttled_on_panned_or_zoomed, "call_func")
    _check_camera_intersection()


func _get_is_viewport_intersecting() -> bool:
    Sc.logger.error(
            "Abstract CameraDetector._get_is_viewport_intersecting " +
            "is not implemented")
    return false


func _check_camera_intersection() -> void:
    var was_camera_intersecting := is_camera_intersecting
    is_camera_intersecting = _get_is_viewport_intersecting()
    if is_camera_intersecting != was_camera_intersecting:
        if is_camera_intersecting:
            emit_signal("camera_enter")
        else:
            emit_signal("camera_exit")


func _on_panned_or_zoomed() -> void:
    _check_camera_intersection()


func _set_shape_is_rectangular(value: bool) -> void:
    ._set_shape_is_rectangular(value)
    _check_camera_intersection()


func _set_shape_rectangle_extents(value: Vector2) -> void:
    ._set_shape_rectangle_extents(value)
    _check_camera_intersection()


func _set_shape_circle_radius(value: float) -> void:
    ._set_shape_shape_circle_radius(value)
    _check_camera_intersection()


func _set_min_zoom(value: float) -> void:
    min_zoom = value
    _check_camera_intersection()


func _set_max_zoom(value: float) -> void:
    max_zoom = value
    _check_camera_intersection()

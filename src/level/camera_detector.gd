tool
class_name CameraDetector, \
"res://addons/scaffolder/assets/images/editor_icons/camera_detector.png"
extends ShapedLevelControl
## -   This detects when the center of the camera intersects this area.


signal camera_center_enter
signal camera_center_exit

signal camera_bounds_enter
signal camera_bounds_exit

export var min_zoom := 0.0 setget _set_min_zoom
export var max_zoom := 100.0 setget _set_max_zoom

var is_camera_center_intersecting := false
var is_camera_bounds_intersecting := false

var _throttled_on_panned_or_zoomed: FuncRef = Sc.time.throttle(
        self, "_on_panned_or_zoomed", 0.1)


func _ready() -> void:
    self.input_pickable = false
    Sc.camera.connect("panned", _throttled_on_panned_or_zoomed, "call_func")
    Sc.camera.connect("zoomed", _throttled_on_panned_or_zoomed, "call_func")


func _check_camera_intersection() -> void:
    var was_camera_center_intersecting := is_camera_center_intersecting
    var was_camera_bounds_intersecting := is_camera_bounds_intersecting
    
    var camera_center: Vector2 = Sc.level.camera.get_center()
    var camera_bounds: Rect2 = Sc.level.camera.get_visible_region()
    
    var shape_position := _shape.global_position
    
    if shape_is_rectangular:
        is_camera_center_intersecting = Sc.geometry.is_point_in_rectangle(
                camera_center,
                shape_position - shape_rectangle_extents,
                shape_position + shape_rectangle_extents)
        is_camera_bounds_intersecting = Sc.geometry.do_rectangles_intersect(
                camera_bounds.position,
                camera_bounds.end,
                shape_position - shape_rectangle_extents,
                shape_position + shape_rectangle_extents)
    else:
        is_camera_center_intersecting = \
                camera_center.distance_squared_to(_shape.global_position) < \
                shape_circle_radius * shape_circle_radius
        is_camera_bounds_intersecting = \
                Sc.geometry.does_rectangle_and_circle_intersect(
                    camera_bounds.position,
                    camera_bounds.end,
                    shape_position,
                    shape_circle_radius)
    
    if is_camera_center_intersecting != was_camera_center_intersecting:
        if is_camera_center_intersecting:
            emit_signal("camera_center_enter")
        else:
            emit_signal("camera_center_exit")
    
    if is_camera_bounds_intersecting != was_camera_bounds_intersecting:
        if is_camera_bounds_intersecting:
            emit_signal("camera_bounds_enter")
        else:
            emit_signal("camera_bounds_exit")


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

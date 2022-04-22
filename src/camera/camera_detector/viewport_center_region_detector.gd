tool
class_name ViewportCenterRegionDetector, \
"res://addons/scaffolder/assets/images/editor_icons/camera_detector.png"
extends CameraDetector


export var viewport_ratio := Vector2(0.5, 0.5) \
        setget _set_viewport_ratio


func _get_is_viewport_intersecting() -> bool:
    if !is_instance_valid(Sc.level.camera):
        return false
    var camera_center: Vector2 = Sc.level.camera.get_center()
    var camera_bounds: Rect2 = Sc.level.camera.get_visible_region()
    var center_region_bounds_size := viewport_ratio * camera_bounds.size
    var center_region_bounds_position := \
            camera_bounds.position + \
            (camera_bounds.size - center_region_bounds_size) / 2.0
    var center_region_bounds := \
            Rect2(center_region_bounds_position, center_region_bounds_size)
    var shape_position := _shape.global_position
    if shape_is_rectangular:
        return Sc.geometry.do_rectangles_intersect(
                center_region_bounds.position,
                center_region_bounds.end,
                shape_position - shape_rectangle_extents,
                shape_position + shape_rectangle_extents)
    else:
        return Sc.geometry.does_rectangle_and_circle_intersect(
                center_region_bounds.position,
                center_region_bounds.end,
                shape_position,
                shape_circle_radius)


func _set_viewport_ratio(value: Vector2) -> void:
    viewport_ratio = value
    _check_camera_intersection()

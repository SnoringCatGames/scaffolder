tool
class_name ViewportCenterDetector, \
"res://addons/scaffolder/assets/images/editor_icons/camera_detector.png"
extends CameraDetector


func _get_is_viewport_intersecting() -> bool:
    var camera_center: Vector2 = Sc.level.camera.get_center()
    var camera_bounds: Rect2 = Sc.level.camera.get_visible_region()
    var shape_position := _shape.global_position
    if shape_is_rectangular:
        return Sc.geometry.is_point_in_rectangle(
                camera_center,
                shape_position - shape_rectangle_extents,
                shape_position + shape_rectangle_extents)
    else:
        return camera_center.distance_squared_to(_shape.global_position) < \
                shape_circle_radius * shape_circle_radius

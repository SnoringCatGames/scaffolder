tool
class_name ViewportBoundsDetector, \
"res://addons/scaffolder/assets/images/editor_icons/camera_detector.png"
extends CameraDetector


func _get_is_viewport_intersecting() -> bool:
    var camera_center: Vector2 = Sc.level.camera.get_center()
    var camera_bounds: Rect2 = Sc.level.camera.get_visible_region()
    var shape_position := _shape.global_position
    if shape_is_rectangular:
        return Sc.geometry.do_rectangles_intersect(
                camera_bounds.position,
                camera_bounds.end,
                shape_position - shape_rectangle_extents,
                shape_position + shape_rectangle_extents)
    else:
        return Sc.geometry.does_rectangle_and_circle_intersect(
                camera_bounds.position,
                camera_bounds.end,
                shape_position,
                shape_circle_radius)

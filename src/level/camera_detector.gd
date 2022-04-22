tool
class_name CameraDetector, \
"res://addons/scaffolder/assets/images/editor_icons/proximity_detector.png"
extends Area2D
## -   This detects when the center of the camera intersects this area.


signal camera_center_enter
signal camera_center_exit

signal camera_bounds_enter
signal camera_bounds_exit

export var is_rectangular := true \
        setget _set_is_rectangular
export var rectangle_extents := Vector2(16.0, 16.0) \
        setget _set_rectangle_extents
export var circle_radius := -1.0 \
        setget _set_circle_radius

export var min_zoom := 0.0 setget _set_min_zoom
export var max_zoom := 100.0 setget _set_max_zoom

var is_camera_center_intersecting := false
var is_camera_bounds_intersecting := false

var _shape: CollisionShape2D

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    
    self.collision_layer = Sc.gui.GUI_COLLISION_LAYER
    self.monitoring = false
    self.monitorable = false
    self.input_pickable = false
    
    var preexisting_shapes := \
            Sc.utils.get_children_by_type(self, CollisionShape2D)
    if !preexisting_shapes.empty():
        _shape = preexisting_shapes[0]
        assert(preexisting_shapes.size() == 1,
                "Don't include an explicit CollisionShape2D as a child of " +
                "CameraDetector.")
        for i in range(1, preexisting_shapes.size()):
            remove_child(preexisting_shapes[i])
    else:
        _shape = CollisionShape2D.new()
        add_child(_shape)
        _shape.owner = self
    
    _update_region()


func _update_region() -> void:
    if !_is_ready:
        return
    
    if is_rectangular:
        if !_shape.shape is RectangleShape2D:
            _shape.shape = RectangleShape2D.new()
        _shape.shape.extents = rectangle_extents
    else:
        if !_shape.shape is CircleShape2D:
            _shape.shape = CircleShape2D.new()
        _shape.shape.radius = circle_radius


func _check_camera_intersection() -> void:
    var was_camera_center_intersecting := is_camera_center_intersecting
    var was_camera_bounds_intersecting := is_camera_bounds_intersecting
    
    var camera_center: Vector2 = Sc.level.camera.get_center()
    var camera_bounds: Rect2 = Sc.level.camera.get_visible_region()
    
    if is_rectangular:
        is_camera_center_intersecting = Sc.geometry.is_point_in_rectangle(
                camera_center,
                position - rectangle_extents,
                position + rectangle_extents)
        is_camera_bounds_intersecting = Sc.geometry.do_rectangles_intersect(
                camera_bounds.position,
                camera_bounds.end,
                position - rectangle_extents,
                position + rectangle_extents)
    else:
        is_camera_center_intersecting = \
                camera_center.distance_squared_to(position) < \
                circle_radius * circle_radius
        is_camera_bounds_intersecting = \
                Sc.geometry.does_rectangle_and_circle_intersect(
                    camera_bounds.position,
                    camera_bounds.end,
                    position,
                    circle_radius)
    
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


func _set_is_rectangular(value: bool) -> void:
    is_rectangular = value
    if is_rectangular:
        circle_radius = -1
        rectangle_extents.x = max(rectangle_extents.x, 1)
        rectangle_extents.y = max(rectangle_extents.y, 1)
    else:
        circle_radius = max(circle_radius, 1)
        rectangle_extents.x = -1
        rectangle_extents.y = -1
    _update_region()
    property_list_changed_notify()


func _set_rectangle_extents(value: Vector2) -> void:
    rectangle_extents = value
    if rectangle_extents.x > 0 and rectangle_extents.y > 0:
        is_rectangular = true
        circle_radius = -1
    _update_region()
    property_list_changed_notify()


func _set_circle_radius(value: float) -> void:
    circle_radius = value
    if circle_radius > 0:
        is_rectangular = false
        rectangle_extents = Vector2(-1, -1)
    _update_region()
    property_list_changed_notify()


func _set_min_zoom(value: float) -> void:
    min_zoom = value


func _set_max_zoom(value: float) -> void:
    max_zoom = value

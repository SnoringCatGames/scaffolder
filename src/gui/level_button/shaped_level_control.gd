tool
class_name ShapedLevelControl, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_node.png"
extends LevelControl


export var shape_is_rectangular := true \
        setget _set_shape_is_rectangular
export var shape_rectangle_extents := Vector2(8.0, 8.0) \
        setget _set_shape_rectangle_extents
export var shape_circle_radius := -1.0 \
        setget _set_shape_circle_radius
export var shape_offset := Vector2.ZERO \
        setget _set_shape_offset

var _shape: CollisionShape2D

var half_width_height: Vector2


func _ready() -> void:
    _set_up_shape()


func _set_up_shape() -> void:
    var preexisting_shapes: Array = \
            Sc.utils.get_children_by_type(self, CollisionShape2D)
    for shape in preexisting_shapes:
        remove_child(shape)
    _shape = CollisionShape2D.new()
    add_child(_shape)
    _update_shape()


func _update_shape() -> void:
    if !_is_ready:
        return
    
    if shape_is_rectangular:
        if !_shape.shape is RectangleShape2D:
            _shape.shape = RectangleShape2D.new()
        _shape.shape.extents = shape_rectangle_extents
    else:
        if !_shape.shape is CircleShape2D:
            _shape.shape = CircleShape2D.new()
        _shape.shape.radius = shape_circle_radius
    
    _shape.position = shape_offset
    
    half_width_height = \
        Sc.geometry.calculate_half_width_height(_shape.shape, false)


func _set_shape_is_rectangular(value: bool) -> void:
    shape_is_rectangular = value
    if shape_is_rectangular:
        shape_circle_radius = -1
        shape_rectangle_extents.x = max(shape_rectangle_extents.x, 1)
        shape_rectangle_extents.y = max(shape_rectangle_extents.y, 1)
    else:
        shape_circle_radius = max(shape_circle_radius, 1)
        shape_rectangle_extents.x = -1
        shape_rectangle_extents.y = -1
    _update_shape()
    property_list_changed_notify()


func _set_shape_rectangle_extents(value: Vector2) -> void:
    shape_rectangle_extents = value
    if shape_rectangle_extents.x > 0 and shape_rectangle_extents.y > 0:
        shape_is_rectangular = true
        shape_circle_radius = -1
    _update_shape()
    property_list_changed_notify()


func _set_shape_circle_radius(value: float) -> void:
    shape_circle_radius = value
    if shape_circle_radius > 0:
        shape_is_rectangular = false
        shape_rectangle_extents = Vector2(-1, -1)
    _update_shape()
    property_list_changed_notify()


func _set_shape_offset(value: Vector2) -> void:
    shape_offset = value
    _update_shape()
    property_list_changed_notify()


func get_center_in_screen_space() -> Vector2:
    return Sc.utils.get_screen_position_of_node_in_level(_shape)


func get_bounds() -> Rect2:
    return Rect2(position - half_width_height, half_width_height * 2.0)

tool
class_name LevelOverlayButton, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_button.png"
extends LevelOverlayControl
## -   This button bypasses Godot's normal Control logic, and re-implements
##     button behavior from scratch.
## -   This is needed, because Godot's normal Button behavior captures scroll
##     events, and prevents the level from processing them.
##     -   This capturing is not disablable in the normal way with mouse_filter.


signal pressed

export var is_rectangular := true \
        setget _set_is_rectangular
export var rectangle_extents := Vector2(16.0, 16.0) \
        setget _set_rectangle_extents
export var circle_radius := -1.0 \
        setget _set_circle_radius

var _shape: CollisionShape2D


func _ready() -> void:
    var preexisting_shapes := \
            Sc.utils.get_children_by_type(self, CollisionShape2D)
    if !preexisting_shapes.empty():
        _shape = preexisting_shapes[0]
        for i in range(1, preexisting_shapes.size()):
            remove_child(preexisting_shapes[i])
    else:
        _shape = CollisionShape2D.new()
        add_child(_shape)
        _shape.owner = self
    _update()


func _update() -> void:
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


func _on_full_press(
        level_position: Vector2,
        screen_position: Vector2) -> void:
    emit_signal("pressed")


func _on_interaction_mode_changed(interaction_mode: int) -> void:
    Sc.logger.error(
            "Abstract LevelOverlayButton._on_interaction_mode_changed " +
            "is not implemented")


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
    _update()
    property_list_changed_notify()


func _set_rectangle_extents(value: Vector2) -> void:
    rectangle_extents = value
    if rectangle_extents.x > 0 and rectangle_extents.y > 0:
        is_rectangular = true
        circle_radius = -1
    _update()
    property_list_changed_notify()


func _set_circle_radius(value: float) -> void:
    circle_radius = value
    if circle_radius > 0:
        is_rectangular = false
        rectangle_extents = Vector2(-1, -1)
    _update()
    property_list_changed_notify()

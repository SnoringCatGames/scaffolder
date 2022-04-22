tool
class_name LevelButton, \
"res://addons/scaffolder/assets/images/editor_icons/generic_button.png"
extends ShapedLevelControl
## -   This button bypasses Godot's normal Control logic, and re-implements
##     button behavior from scratch.
## -   This is needed, because Godot's normal Button behavior captures scroll
##     events, and prevents the level from processing them.
##     -   This capturing is not disablable in the normal way with mouse_filter.


signal pressed


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
            "Abstract LevelButton._on_interaction_mode_changed " +
            "is not implemented")

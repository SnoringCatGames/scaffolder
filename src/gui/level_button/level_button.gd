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


func _on_full_press(level_position: Vector2) -> void:
#    Sc.logger.print("LevelButton._on_full_press")
    emit_signal("pressed")

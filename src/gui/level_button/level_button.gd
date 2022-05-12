tool
class_name LevelButton, \
"res://addons/scaffolder/assets/images/editor_icons/level_button.png"
extends ShapedLevelControl
## -   This button bypasses Godot's normal Control logic, and re-implements
##     button behavior from scratch.
## -   This is needed, because Godot's normal Button behavior captures scroll
##     events, and prevents the level from processing them.
##     -   This capturing is not disablable in the normal way with mouse_filter.

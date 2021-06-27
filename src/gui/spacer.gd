tool
class_name Spacer
extends Control


export var size := Vector2.ZERO setget _set_size


func _set_size(value: Vector2) -> void:
    size = value
    set_meta("gs_rect_min_size", size)
    Gs.utils._scale_gui_recursively(self)

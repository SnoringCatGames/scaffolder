tool
class_name Spacer
extends Control


export var size := Vector2.ZERO setget _set_size


func update_gui_scale() -> void:
    # FIXME: -----------------------------
    # - Account for in-editor use
    rect_min_size = size * Gs.gui.scale


func _set_size(value: Vector2) -> void:
    size = value
    update_gui_scale()

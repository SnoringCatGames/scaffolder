tool
class_name Spacer, \
"res://addons/scaffolder/assets/images/editor_icons/spacer.png"
extends Control


export var size := Vector2.ZERO setget _set_size


func _on_gui_scale_changed() -> bool:
    rect_min_size = size * Sc.gui.scale
    rect_size = size * Sc.gui.scale
    return true


func _set_size(value: Vector2) -> void:
    size = value
    _on_gui_scale_changed()

tool
class_name Spacer, "res://addons/scaffolder/assets/images/editor_icons/spacer.png"
extends Control


export var size := Vector2.ZERO setget _set_size


func update_gui_scale() -> bool:
    rect_min_size = size * Gs.gui.scale
    rect_size = size * Gs.gui.scale
    return true


func _set_size(value: Vector2) -> void:
    size = value
    
    if Engine.editor_hint:
        return
    
    update_gui_scale()

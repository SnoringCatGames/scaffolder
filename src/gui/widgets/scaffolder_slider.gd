tool
class_name ScaffolderSlider, "res://addons/scaffolder/assets/images/editor_icons/slider.png"
extends HSlider


export var size_override := Vector2.ZERO setget _set_size_override


func _set_size_override(value: Vector2) -> void:
    size_override = value
    
    if Engine.editor_hint:
        return
    
    set_meta("gs_rect_min_size", size_override)
    Gs.utils.scale_gui_recursively(self)

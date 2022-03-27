tool
class_name ScaffolderHSeparator, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_h_separator.png"
extends HSeparator


export var size_override := Vector2.ZERO setget _set_size_override


func _on_gui_scale_changed() -> bool:
    rect_min_size = size_override * Sc.gui.scale
    rect_size = size_override * Sc.gui.scale
    
    var separator_stylebox: StyleBoxLine = get_stylebox("separator")
    separator_stylebox.color = Sc.palette.get_color("overlay_panel_border")
    separator_stylebox.thickness = \
            Sc.styles.overlay_panel_border_width * Sc.gui.scale
    
    return true


func _set_size_override(value: Vector2) -> void:
    size_override = value
    size_override.y = \
            min(size_override.y, Sc.styles.overlay_panel_border_width)
    _on_gui_scale_changed()

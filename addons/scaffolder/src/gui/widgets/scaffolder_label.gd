tool
class_name ScaffolderLabel, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_label.png"
extends Label


export(String, "Xs", "S", "M", "L", "Xl") var font_size := "M" \
        setget _set_font_size
export var is_header := false setget _set_is_header
export var is_bold := false setget _set_is_bold
export var is_italic := false setget _set_is_italic
export var size_override := Vector2.ZERO setget _set_size_override
export var font_override: Font setget _set_font_override

var _is_ready := false


func _ready() -> void:
    _is_ready = true
    _update()


func _on_gui_scale_changed() -> bool:
    _update()
    return true


func _update() -> void:
    if !_is_ready:
        return
    
    rect_min_size = size_override * Sc.gui.scale
    rect_size = rect_min_size
    
    if font_override != null:
        add_font_override("font", font_override)
    else:
        var font: Font = Sc.gui.get_font(
                font_size,
                is_header,
                is_bold,
                is_italic)
        add_font_override("font", font)


func _set_font_size(value: String) -> void:
    font_size = value
    _update()


func _set_is_header(value: bool) -> void:
    is_header = value
    _update()


func _set_is_bold(value: bool) -> void:
    is_bold = value
    _update()


func _set_is_italic(value: bool) -> void:
    is_italic = value
    _update()


func _set_size_override(value: Vector2) -> void:
    size_override = value
    _update()


func _set_font_override(value: Font) -> void:
    font_override = value
    _update()

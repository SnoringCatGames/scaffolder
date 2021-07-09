tool
class_name ScaffolderOptionButton, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_option_button.png"
extends OptionButton


export(String, "Xs", "S", "M", "L", "Xl") var font_size := "M" \
        setget _set_font_size
export var size_override := Vector2.ZERO setget _set_size_override
export var font_override: Font setget _set_font_override
export var hseparation := 2.0 setget _set_hseparation
export var arrow_margin := 2.0 setget _set_arrow_margin

var _is_ready := false


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    _is_ready = true
    _update()


func _on_gui_scale_changed() -> bool:
    _update()
    return true


func _update() -> void:
    if !_is_ready:
        return
    
    rect_min_size.x = \
            (size_override.x if \
            size_override.x != 0.0 else \
            Gs.gui.button_width) * Gs.gui.scale
    rect_min_size.y = \
            (size_override.y if \
            size_override.y != 0.0 else \
            Gs.gui.button_height) * Gs.gui.scale
    rect_size = rect_min_size
    
    add_constant_override("hseparation", hseparation * Gs.gui.scale)
    add_constant_override("arrow_margin", arrow_margin * Gs.gui.scale)
    
    if font_override != null:
        add_font_override("font", font_override)
    else:
        var font: Font = Gs.gui.get_font(
                font_size,
                false,
                false,
                false)
        add_font_override("font", font)


func _set_font_size(value: String) -> void:
    font_size = value
    _update()


func _set_size_override(value: Vector2) -> void:
    size_override = value
    if Engine.editor_hint:
        rect_size = size_override
    _update()


func _set_font_override(value: Font) -> void:
    font_override = value
    if Engine.editor_hint:
        add_font_override("font", font_override)
    _update()


func _set_hseparation(value: float) -> void:
    hseparation = value
    _update()


func _set_arrow_margin(value: float) -> void:
    arrow_margin = value
    _update()

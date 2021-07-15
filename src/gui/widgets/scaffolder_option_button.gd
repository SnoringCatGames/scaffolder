tool
class_name ScaffolderOptionButton, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_option_button.png"
extends OptionButton


export(String, "Xs", "S", "M", "L", "Xl") var font_size := "M" \
        setget _set_font_size
export var size_override := Vector2.ZERO setget _set_size_override
export var font_override: Font setget _set_font_override
export var hseparation_override := -1.0 setget _set_hseparation_override
export var arrow_margin_override := -1.0 setget _set_arrow_margin_override

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
    
    rect_min_size.x = \
            (size_override.x if \
            size_override.x != 0.0 else \
            Sc.gui.button_width) * Sc.gui.scale
    rect_min_size.y = \
            (size_override.y if \
            size_override.y != 0.0 else \
            Sc.gui.button_height) * Sc.gui.scale
    rect_size = rect_min_size
    
    var hseparation: float = \
            hseparation_override if \
            hseparation_override != -1.0 else \
            Sc.styles.button_content_margin_left
    add_constant_override("hseparation", hseparation * Sc.gui.scale)
    
    var arrow_margin: float = \
            arrow_margin_override if \
            arrow_margin_override != -1.0 else \
            Sc.styles.button_content_margin_right
    add_constant_override("arrow_margin", arrow_margin * Sc.gui.scale)
    
    if font_override != null:
        add_font_override("font", font_override)
    else:
        var font: Font = Sc.gui.get_font(
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


func _set_font_override(value: Font) -> void:
    font_override = value
    _update()


func _set_hseparation_override(value: float) -> void:
    hseparation_override = value
    _update()


func _set_arrow_margin_override(value: float) -> void:
    arrow_margin_override = value
    _update()

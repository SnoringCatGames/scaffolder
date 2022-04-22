tool
class_name ScaffolderButton, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_button.png"
extends Button


const SHINE_DURATION := 0.4
const SHINE_INTERVAL := 3.5
const SHINE_SCALE := Vector2(1.0, 1.0)
const COLOR_PULSE_DURATION := 1.2
const COLOR_PULSE_INTERVAL := 2.4
const MIN_PADDING := 8.0

export(String, MULTILINE) var label: String setget _set_label,_get_label
export var texture: Texture setget _set_texture
export var texture_key: String setget _set_texture_key
export var texture_scale := Vector2(1.0, 1.0) setget _set_texture_scale
export var is_shiny := false setget _set_is_shiny
export var includes_color_pulse := false setget _set_includes_color_pulse
export(String, "Xs", "S", "M", "L", "Xl") var font_size := "M" \
        setget _set_font_size
export var size_override := Vector2.ZERO setget _set_size_override

var shine_interval_id := -1
var color_pulse_interval_id := -1

var shine_start_x: float
var shine_end_x: float

var button_style_pulse: StyleBox

var shine_tween := ScaffolderTween.new(self)
var color_pulse_tween := ScaffolderTween.new(self)

var _is_ready := false


func _enter_tree() -> void:
    _on_gui_scale_changed()


func _ready() -> void:
    _is_ready = true
    
    Sc.device.connect(
            "display_resized", self, "_update")
    
    _on_gui_scale_changed()


func _exit_tree() -> void:
    _destroy()


func _destroy() -> void:
    shine_tween.stop_all()
    color_pulse_tween.stop_all()
    if is_instance_valid(button_style_pulse):
        button_style_pulse._destroy()
    Sc.time.clear_interval(shine_interval_id)
    Sc.time.clear_interval(color_pulse_interval_id)


func _on_gui_scale_changed() -> bool:
    _update()
    return true


func _update() -> void:
    _destroy()
    
    rect_min_size.x = \
            (size_override.x if \
            size_override.x != 0.0 else \
            Sc.gui.button_width) * Sc.gui.scale
    rect_min_size.y = \
            (size_override.y if \
            size_override.y != 0.0 else \
            Sc.gui.button_height) * Sc.gui.scale
    rect_size = rect_min_size
    
    $MarginContainer/MarginContainer/ShineLineWrapper/ShineLine.scale = \
            SHINE_SCALE * Sc.gui.scale
    $MarginContainer/ScaffolderTextureRect._on_gui_scale_changed()
    
    var half_size := rect_size / 2.0
    var shine_base_position: Vector2 = half_size
    shine_start_x = shine_base_position.x - rect_size.x
    shine_end_x = shine_base_position.x + rect_size.x
    
    button_style_pulse = \
            Sc.gui.theme.get_stylebox("normal", "Button").duplicate()
    
    $MarginContainer/MarginContainer.add_constant_override(
            "margin_left",
            Sc.styles.button_shine_margin_left * Sc.gui.scale)
    $MarginContainer/MarginContainer.add_constant_override(
            "margin_top",
            Sc.styles.button_shine_margin_top * Sc.gui.scale)
    $MarginContainer/MarginContainer.add_constant_override(
            "margin_right",
            Sc.styles.button_shine_margin_right * Sc.gui.scale)
    $MarginContainer/MarginContainer.add_constant_override(
            "margin_bottom",
            Sc.styles.button_shine_margin_bottom * Sc.gui.scale)
    
    $MarginContainer.call_deferred("set", "rect_size", rect_size)
    $MarginContainer/MarginContainer.visible = \
            is_shiny and Sc.gui.is_suggested_button_shine_line_shown
    $MarginContainer/MarginContainer/ShineLineWrapper/ShineLine.position = \
            Vector2(shine_start_x, shine_base_position.y)
    
    $MarginContainer/ScaffolderTextureRect.visible = \
            is_instance_valid(texture) or texture_key != ""
    if is_instance_valid(texture):
        $MarginContainer/ScaffolderTextureRect.texture = texture
    else:
        $MarginContainer/ScaffolderTextureRect.texture_key = texture_key
    $MarginContainer/ScaffolderTextureRect.texture_scale = texture_scale
    
    var font: Font = Sc.gui.get_font(font_size)
    $MarginContainer/Label.add_font_override("font", font)
    
    $MarginContainer/BottomButton.add_stylebox_override(
            "normal",
            Sc.gui.theme.get_stylebox("normal", "Button"))
    
    if is_shiny and \
            Sc.gui.is_suggested_button_shine_line_shown:
        _trigger_shine()
        shine_interval_id = Sc.time.set_interval(
                self, "_trigger_shine", SHINE_INTERVAL)
    
    if includes_color_pulse and \
            Sc.gui.is_suggested_button_color_pulse_shown:
        _trigger_color_pulse()
        color_pulse_interval_id = Sc.time.set_interval(
                self, "_trigger_color_pulse", COLOR_PULSE_INTERVAL)


func _trigger_shine() -> void:
    shine_tween.interpolate_property(
            $MarginContainer/MarginContainer/ShineLineWrapper/ShineLine,
            "position:x",
            shine_start_x,
            shine_end_x,
            SHINE_DURATION,
            "linear")
    shine_tween.start()


func _trigger_color_pulse() -> void:
    # Give priority to normal button state styling.
    if $MarginContainer/TopButton.is_hovered() or \
            $MarginContainer/TopButton.is_pressed():
        return
    
    var color_original := Color(1.0, 1.0, 1.0, 1.0)
    var color_pulse: Color = Sc.palette.get_color("button_pulse_modulate")
    var pulse_half_duration := COLOR_PULSE_DURATION / 2.0
    
    button_style_pulse.set("modulate_color", color_original)
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_pulse)
    
    color_pulse_tween.interpolate_property(
            button_style_pulse,
            "modulate_color",
            color_original,
            color_pulse,
            pulse_half_duration,
            "ease_in_out_weak")
    color_pulse_tween.interpolate_property(
            button_style_pulse,
            "modulate_color",
            color_pulse,
            color_original,
            pulse_half_duration,
            "ease_in_out_weak",
            pulse_half_duration)
    color_pulse_tween.start()


func _set_label(value: String) -> void:
    $MarginContainer/Label.text = value


func _get_label() -> String:
    return $MarginContainer/Label.text


func _set_texture(value: Texture) -> void:
    texture = value
    if _is_ready:
        _update()


func _set_texture_key(value: String) -> void:
    texture_key = value
    assert(texture_key == "" or \
            Sc.images.get(texture_key) is Texture)
    if _is_ready:
        _update()


func _set_texture_scale(value: Vector2) -> void:
    texture_scale = value
    if _is_ready:
        _update()


func _set_is_shiny(value: bool) -> void:
    is_shiny = value
    if _is_ready:
        _update()


func _set_includes_color_pulse(value: bool) -> void:
    includes_color_pulse = value
    if _is_ready:
        _update()


func _set_font_size(value: String) -> void:
    font_size = value
    if _is_ready:
        _update()


func _set_size_override(value: Vector2) -> void:
    size_override = value
    if _is_ready:
        _update()


func press() -> void:
    Sc.utils.give_button_press_feedback()
    emit_signal("pressed")


func _on_TopButton_pressed() -> void:
    press()


func _on_TopButton_mouse_entered() -> void:
    $MarginContainer/BottomButton.add_stylebox_override(
            "normal",
            Sc.gui.theme.get_stylebox("hover", "Button"))


func _on_TopButton_mouse_exited() -> void:
    $MarginContainer/BottomButton.add_stylebox_override(
            "normal",
            Sc.gui.theme.get_stylebox("normal", "Button"))


func _on_TopButton_button_down() -> void:
    $MarginContainer/BottomButton.add_stylebox_override(
            "normal",
            Sc.gui.theme.get_stylebox("pressed", "Button"))


func _on_TopButton_button_up() -> void:
    $MarginContainer/BottomButton.add_stylebox_override(
            "normal",
            Sc.gui.theme.get_stylebox("hover", "Button"))

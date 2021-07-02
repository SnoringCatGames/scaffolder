tool
class_name ScaffolderButton, "res://addons/scaffolder/assets/images/editor_icons/scaffolder_button.png"
extends Button


const SHINE_DURATION := 0.35
const SHINE_INTERVAL := 3.5
const SHINE_SCALE := Vector2(1.0, 1.0)
const COLOR_PULSE_DURATION := 1.2
const COLOR_PULSE_INTERVAL := 2.4
const MIN_PADDING := 8.0

export(String, MULTILINE) var label: String setget _set_label,_get_label
export var texture: Texture setget _set_texture
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

var button_style_normal: StyleBox
var button_style_hover: StyleBox
var button_style_pressed: StyleBox
var button_style_pulse: StyleBoxFlat

var shine_tween := ScaffolderTween.new()
var color_pulse_tween := ScaffolderTween.new()

var _is_ready := false


func _enter_tree() -> void:
    if Engine.editor_hint:
        return
    
    add_child(shine_tween)
    add_child(color_pulse_tween)


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    _is_ready = true
    
    button_style_normal = $MarginContainer/BottomButton.get_stylebox("normal")
    button_style_hover = $MarginContainer/BottomButton.get_stylebox("hover")
    button_style_pressed = \
            $MarginContainer/BottomButton.get_stylebox("pressed")
    
    Gs.utils.connect(
            "display_resized", self, "_update")
    
    update_gui_scale()


func _exit_tree() -> void:
    if Engine.editor_hint:
        return
    
    if is_instance_valid(button_style_pulse):
        button_style_pulse.destroy()
    Gs.time.clear_interval(shine_interval_id)
    Gs.time.clear_interval(color_pulse_interval_id)


func update_gui_scale() -> bool:
    _update()
    return true


func _update() -> void:
    rect_min_size.x = \
            (size_override.x if \
            size_override.x != 0.0 else \
            Gs.gui.button_width) * Gs.gui.scale
    rect_min_size.y = \
            (size_override.y if \
            size_override.y != 0.0 else \
            Gs.gui.button_height) * Gs.gui.scale
    rect_size = rect_min_size

    $MarginContainer/ShineLineWrapper/ShineLine.scale = \
            SHINE_SCALE * Gs.gui.scale
    $MarginContainer/ScaffolderTextureRect.update_gui_scale()
    
    var half_size := rect_size / 2.0
    var shine_base_position: Vector2 = half_size
    shine_start_x = shine_base_position.x - rect_size.x
    shine_end_x = shine_base_position.x + rect_size.x
    
    if is_instance_valid(button_style_pulse):
        button_style_pulse.destroy()
    button_style_pulse = Gs.utils.create_stylebox_flat_scalable({
        bg_color = Gs.colors.button_normal,
        corner_radius = Gs.styles.button_corner_radius,
        corner_detail = Gs.styles.button_corner_detail,
        shadow_size = Gs.styles.button_shadow_size,
    })
    
    $MarginContainer.call_deferred("set", "rect_size", rect_size)
    $MarginContainer/ShineLineWrapper/ShineLine.visible = is_shiny
    $MarginContainer/ShineLineWrapper/ShineLine.position = \
            Vector2(shine_start_x, shine_base_position.y)
    $MarginContainer/ScaffolderTextureRect.visible = texture != null
    $MarginContainer/ScaffolderTextureRect.texture = texture
    $MarginContainer/ScaffolderTextureRect.texture_scale = texture_scale
    var font: Font = Gs.gui.get_font(font_size)
    $MarginContainer/Label.add_font_override("font", font)
    
    shine_tween.stop_all()
    Gs.time.clear_interval(shine_interval_id)
    
    color_pulse_tween.stop_all()
    Gs.time.clear_interval(color_pulse_interval_id)
    $MarginContainer/BottomButton.add_stylebox_override(
            "normal",
            button_style_normal)
    
    if is_shiny:
        _trigger_shine()
        shine_interval_id = Gs.time.set_interval(
                funcref(self, "_trigger_shine"),
                SHINE_INTERVAL)
    
    if includes_color_pulse:
        _trigger_color_pulse()
        color_pulse_interval_id = Gs.time.set_interval(
                funcref(self, "_trigger_color_pulse"),
                COLOR_PULSE_INTERVAL)


func _trigger_shine() -> void:
    shine_tween.interpolate_property(
            $MarginContainer/ShineLineWrapper/ShineLine,
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
    
    var color_original: Color = \
            button_style_normal.bg_color if \
            button_style_normal is StyleBoxFlat else \
            Gs.colors.button_normal
    var color_pulse: Color = Gs.colors.scaffolder_button_highlight
    var pulse_half_duration := COLOR_PULSE_DURATION / 2.0
    
    button_style_pulse.bg_color = color_original
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_pulse)
    
    color_pulse_tween.interpolate_property(
            button_style_pulse,
            "bg_color",
            color_original,
            color_pulse,
            pulse_half_duration,
            "ease_in_out_weak")
    color_pulse_tween.interpolate_property(
            button_style_pulse,
            "bg_color",
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
    if Engine.editor_hint:
        rect_size = size_override
    if _is_ready:
        _update()


func press() -> void:
    _on_TopButton_pressed()


func _on_TopButton_pressed() -> void:
    Gs.utils.give_button_press_feedback()
    emit_signal("pressed")


func _on_TopButton_mouse_entered() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_hover)


func _on_TopButton_mouse_exited() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_normal)


func _on_TopButton_button_down() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_pressed)


func _on_TopButton_button_up() -> void:
    $MarginContainer/BottomButton \
            .add_stylebox_override("normal", button_style_hover)

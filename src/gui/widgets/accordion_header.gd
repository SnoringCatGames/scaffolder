tool
class_name AccordionHeader, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_header.png"
extends Button


signal caret_rotated(rotation)

const CARET_SIZE_DEFAULT := Vector2(23.0, 32.0)
const CARET_SCALE := Vector2(3.0, 3.0)
const CARET_ROTATION_CLOSED := 270.0
const CARET_ROTATION_OPEN := 90.0

const CARET_ROTATION_TWEEN_DURATION := 0.2

export var header_text := "" setget _set_header_text
export(String, "Xs", "S", "M", "L", "Xl") var font_size := "M" \
        setget _set_font_size
export var uses_header_color := false setget _set_uses_header_color
export var is_text_centered := false setget _set_is_text_centered
export var is_caret_on_left := false setget _set_is_caret_on_left
export var padding := Vector2(16.0, 8.0) setget _set_padding
export var size_override := Vector2.ZERO setget _set_size_override
export var toggles_on_click := true

var _configuration_warning := ""

var _is_ready := false

var _panel
var _projected_header: Control

var _debounced_update_children: FuncRef = Sc.time.debounce(
        self, "_update_children_debounced", 0.02, true)


func _ready() -> void:
    _is_ready = true
    _initialize_default_header()
    _update_children()


func _on_gui_scale_changed() -> bool:
    _update_children_debounced()
    return true


func _on_gui_scale_changed_debounced() -> void:
    rect_min_size.x = \
            (size_override.x if \
            size_override.x != 0.0 else \
            Sc.gui.screen_body_width) * Sc.gui.scale
    rect_min_size.y = \
            (size_override.y if \
            size_override.y != 0.0 else \
            Sc.gui.button_height) * Sc.gui.scale
    rect_size = rect_min_size
    
    $HBoxContainer.add_constant_override(
            "separation",
            padding.x * Sc.gui.scale)
    
    $HBoxContainer/ScaffolderTextureRect.texture_scale = CARET_SCALE
    
    $HBoxContainer.rect_size = self.rect_size
    
    for child in get_children():
        if child == _projected_header:
            continue
        Sc.gui.scale_gui_recursively(child)


func _initialize_default_header() -> void:
    self.add_stylebox_override(
            "normal",
            Sc.gui.theme.get_stylebox("normal", "OptionButton"))
    self.add_stylebox_override(
            "hover",
            Sc.gui.theme.get_stylebox("hover", "OptionButton"))
    self.add_stylebox_override(
            "pressed",
            Sc.gui.theme.get_stylebox("pressed", "OptionButton"))
    self.add_stylebox_override(
            "disabled",
            Sc.gui.theme.get_stylebox("disabled", "OptionButton"))
    self.add_stylebox_override(
            "focus",
            Sc.gui.theme.get_stylebox("focus", "OptionButton"))
    
    var inner_texture_rect := \
            $HBoxContainer/ScaffolderTextureRect.get_node("TextureRect")
    inner_texture_rect.rect_pivot_offset = CARET_SIZE_DEFAULT / 2.0
    inner_texture_rect.rect_rotation = CARET_ROTATION_CLOSED


func _update_default_header() -> void:
    var label_index := \
            2 if \
            is_caret_on_left else \
            1
    var label_align := \
            Label.ALIGN_RIGHT if \
            is_caret_on_left else \
            Label.ALIGN_LEFT
    var label := $HBoxContainer/ScaffolderLabel
    $HBoxContainer.move_child(label, label_index)
    label.align = label_align
    
    if is_text_centered:
        label.text = ""
        self.text = header_text
    else:
        label.text = header_text
        self.text = ""
    
    var header_font: Font = Sc.gui.get_font(font_size)
    self.add_font_override("font", header_font)
    $HBoxContainer/ScaffolderLabel.font_size = font_size
    
    $HBoxContainer.visible = !is_instance_valid(_projected_header)
    
    if uses_header_color:
        self.add_color_override("font_color", Sc.palette.get_color("header"))
        label.add_color_override("font_color", Sc.palette.get_color("header"))


func add_child(child: Node, legible_unique_name := false) -> void:
    .add_child(child, legible_unique_name)
    _update_children()


func remove_child(child: Node) -> void:
    .remove_child(child)
    _update_children()


func _update_children() -> void:
    _debounced_update_children.call_func()


func _update_children_debounced() -> void:
    if !_is_ready:
        return
    
    var children := get_children()
    if children.size() > 2:
        _configuration_warning = "Must define 0 or 1 children."
        update_configuration_warning()
        return
    
    if children.size() == 2:
        var projected_node: Node = children[1]
        if !(projected_node is Control):
            _configuration_warning = "Child node must be of type 'Control'."
            update_configuration_warning()
            return
        
        _projected_header = projected_node
    
    _configuration_warning = ""
    update_configuration_warning()
    
    _update_default_header()
    _on_gui_scale_changed_debounced()


func _tween_caret_rotation(
        tween: ScaffolderTween,
        is_open: bool) -> void:
    var caret_rotation_start: float
    var caret_rotation_end: float
    if is_open:
        caret_rotation_start = CARET_ROTATION_CLOSED
        caret_rotation_end = CARET_ROTATION_OPEN
    else:
        caret_rotation_start = CARET_ROTATION_OPEN
        caret_rotation_end = CARET_ROTATION_CLOSED
    
    tween.interpolate_method(
            self,
            "_interpolate_caret_rotation",
            caret_rotation_start,
            caret_rotation_end,
            CARET_ROTATION_TWEEN_DURATION,
            "ease_in_out")


func _interpolate_caret_rotation(rotation: float) -> void:
    $HBoxContainer/ScaffolderTextureRect.get_node("TextureRect") \
            .rect_rotation = rotation
    emit_signal("caret_rotated", rotation)


func _on_is_open_tween_completed(is_open: bool) -> void:
    var caret_rotation := \
            CARET_ROTATION_OPEN if is_open else CARET_ROTATION_CLOSED
    _interpolate_caret_rotation(caret_rotation)


func _on_AccordionHeader_pressed() -> void:
    Sc.utils.give_button_press_feedback()
    if toggles_on_click:
        _panel.toggle()


func _set_header_text(value: String) -> void:
    header_text = value
    _update_children()


func _set_font_size(value: String) -> void:
    font_size = value
    _update_children()


func _set_uses_header_color(value: bool) -> void:
    uses_header_color = value
    _update_children()


func _set_is_text_centered(value: bool) -> void:
    is_text_centered = value
    _update_children()


func _set_is_caret_on_left(value: bool) -> void:
    is_caret_on_left = value
    _update_children()


func _set_padding(value: Vector2) -> void:
    padding = value
    _update_children()


func _set_size_override(value: Vector2) -> void:
    size_override = value
    _update_children()


func _get_configuration_warning() -> String:
    return _configuration_warning

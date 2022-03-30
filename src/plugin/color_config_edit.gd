tool
class_name ColorConfigEdit
extends PluginAccordionPanel


signal changed(color_config)

const _POPUP_ITEMS := {
    0: [null, "Reset"],
    1: [StaticColorConfig, "New static color", "StaticColorConfig"],
    2: [HsvRangeColorConfig, "New hsv-range color", "HsvRangeColorConfig"],
    3: [PaletteColorConfig, "New palette color", "PaletteColorConfig"],
}

const _MENU_BUTTON_EMPTY_TEXT := "[empty]"

# TODO: Find a better way to configure this.
const _ROW_HEIGHT := 24.0

var color_config: ColorConfig setget _set_color_config

var _are_controls_referenced := false
var _is_updating := false


var _menu_button: MenuButton
var _color_rect: ColorRect
var _color_rect_backing_texture_rect: TextureRect
var _color_rect_container: Control
var _main_header: PluginAccordionHeader
var _overrides_header: PluginAccordionHeader
var _deltas_header: PluginAccordionHeader
var _main_caret: PluginAccordionHeaderCaret
var _overrides_caret: PluginAccordionHeaderCaret
var _deltas_caret: PluginAccordionHeaderCaret
var _static_section: VBoxContainer
var _hsv_range_section: VBoxContainer
var _palette_section: VBoxContainer
var _static_color_picker: ColorPickerButton
var _min_color_picker: ColorPickerButton
var _max_color_picker: ColorPickerButton
var _keys_option_button: OptionButton
var _override_h_spin_box: SpinBox
var _override_s_spin_box: SpinBox
var _override_v_spin_box: SpinBox
var _override_a_spin_box: SpinBox
var _delta_h_spin_box: SpinBox
var _delta_v_spin_box: SpinBox
var _delta_s_spin_box: SpinBox
var _delta_a_spin_box: SpinBox


func _enter_tree() -> void:
    _get_control_references()


func _ready() -> void:
    _is_updating = true
    _set_dimensions()
    _update_editor_icons()
    _populate_popup_items()
    _populate_palette_options()
    _update_controls()
    var style := StyleBoxFlat.new()
    style.bg_color = MultiNumberEditor._CONTROL_BACKGROUND_COLOR
    $PluginAccordionHeader/MarginContainer/HBoxContainer/PanelContainer \
            .add_stylebox_override("panel", style)
    _is_updating = false


func _get_control_references() -> void:
    if _are_controls_referenced:
        return
    _are_controls_referenced = true
    _menu_button = $PluginAccordionHeader/MarginContainer/HBoxContainer/ \
        PanelContainer/HBoxContainer/MenuButton
    _color_rect = $PluginAccordionHeader/MarginContainer/HBoxContainer/ \
        PanelContainer/HBoxContainer/Control/ColorRect
    _color_rect_backing_texture_rect = \
        $PluginAccordionHeader/MarginContainer/HBoxContainer/PanelContainer/ \
        HBoxContainer/Control/TextureRect
    _color_rect_container = \
        $PluginAccordionHeader/MarginContainer/HBoxContainer/PanelContainer/ \
        HBoxContainer/Control
    _main_header = $PluginAccordionHeader
    _overrides_header = $PluginAccordionBody/VBoxContainer/PaletteColorConfig/ \
        Overrides/PluginAccordionHeader
    _deltas_header = $PluginAccordionBody/VBoxContainer/PaletteColorConfig/ \
        Deltas/PluginAccordionHeader
    _main_caret = $PluginAccordionHeader/MarginContainer/HBoxContainer/ \
        PluginAccordionHeaderCaret
    _overrides_caret = $PluginAccordionBody/VBoxContainer/PaletteColorConfig/ \
        Overrides/PluginAccordionHeader/MarginContainer/HBoxContainer/ \
        PluginAccordionHeaderCaret
    _deltas_caret = $PluginAccordionBody/VBoxContainer/PaletteColorConfig/ \
        Deltas/PluginAccordionHeader/MarginContainer/HBoxContainer/ \
        PluginAccordionHeaderCaret
    _static_section = $PluginAccordionBody/VBoxContainer/StaticColorConfig
    _hsv_range_section = $PluginAccordionBody/VBoxContainer/HsvRangeColorConfig
    _palette_section = $PluginAccordionBody/VBoxContainer/PaletteColorConfig
    _static_color_picker = $PluginAccordionBody/VBoxContainer/ \
        StaticColorConfig/Color/ColorPickerButton
    _min_color_picker = $PluginAccordionBody/VBoxContainer/ \
        HsvRangeColorConfig/MinColor/ColorPickerButton
    _max_color_picker = $PluginAccordionBody/VBoxContainer/ \
        HsvRangeColorConfig/MaxColor/ColorPickerButton
    _keys_option_button = $PluginAccordionBody/VBoxContainer/ \
        PaletteColorConfig/Key/OptionButton
    _override_h_spin_box = $PluginAccordionBody/VBoxContainer/ \
        PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/H/SpinBox
    _override_s_spin_box = $PluginAccordionBody/VBoxContainer/ \
        PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/S/SpinBox
    _override_v_spin_box = $PluginAccordionBody/VBoxContainer/ \
        PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/V/SpinBox
    _override_a_spin_box = $PluginAccordionBody/VBoxContainer/ \
        PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/A/SpinBox
    _delta_h_spin_box = $PluginAccordionBody/VBoxContainer/ \
        PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/H/SpinBox
    _delta_s_spin_box = $PluginAccordionBody/VBoxContainer/ \
        PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/S/SpinBox
    _delta_v_spin_box = $PluginAccordionBody/VBoxContainer/ \
        PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/V/SpinBox
    _delta_a_spin_box = $PluginAccordionBody/VBoxContainer/ \
        PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/A/SpinBox


func _set_dimensions() -> void:
    var row_height: float = Pl.scale_dimension(_ROW_HEIGHT)
    var headers := [
        _main_header,
        _overrides_header,
        _deltas_header,
    ]
    for header in headers:
        header.size_override = Vector2(0.0, row_height)
    var carets := [
        _main_caret,
        _overrides_caret,
        _deltas_caret,
    ]
    for header in carets:
        header.rect_min_size.x = row_height
    _menu_button.rect_min_size.y = row_height
    var color_rect_size := row_height * Vector2.ONE
    _color_rect_container.rect_size = color_rect_size
    _color_rect.rect_size = color_rect_size
    _color_rect_backing_texture_rect.rect_size = color_rect_size


func _update_editor_icons() -> void:
    _color_rect_backing_texture_rect.texture = \
        Pl.get_editor_icon("GuiMiniCheckerboard")


func _populate_popup_items() -> void:
    var popup_menu: PopupMenu = _menu_button.get_popup()
    popup_menu.clear()
    for id in _POPUP_ITEMS:
        var label: String = _POPUP_ITEMS[id][1]
        popup_menu.add_item(label, id)
    popup_menu.connect("id_pressed", self, "_on_popup_menu_id_pressed")


func _populate_palette_options() -> void:
    _keys_option_button.clear()
    for key in Sc.palette._colors:
        _keys_option_button.add_item(key)
    _keys_option_button.get_popup().allow_search = true


func _get_option_button_index_from_label(
        label: String,
        option_button: OptionButton) -> int:
    for i in option_button.get_item_count():
        if option_button.get_item_text(i) == label:
            return i
    return -1


func _hide_component_editors() -> void:
    _static_section.visible = false
    _hsv_range_section.visible = false
    _palette_section.visible = false


func _show_component_editor(id: int) -> void:
    _hide_component_editors()
    var color_config_script: Script = _POPUP_ITEMS[id][0]
    if is_instance_valid(color_config_script):
        if !is_instance_valid(color_config) or \
                color_config.get_script() != color_config_script:
            color_config = color_config_script.new()
        var color_config_class_name: String = _POPUP_ITEMS[id][2]
        self.get_node(
                "PluginAccordionBody/VBoxContainer/" +
                color_config_class_name).visible = true
        _menu_button.text = color_config_class_name
    else:
        color_config = null
        _menu_button.text = _MENU_BUTTON_EMPTY_TEXT


func add_focusables(editor: EditorProperty) -> void:
    var focusables := [
        _menu_button,
        _static_color_picker,
        _min_color_picker,
        _max_color_picker,
        _keys_option_button,
        _override_h_spin_box,
        _override_s_spin_box,
        _override_v_spin_box,
        _override_a_spin_box,
        _delta_h_spin_box,
        _delta_v_spin_box,
        _delta_s_spin_box,
        _delta_a_spin_box,
    ]
    for control in focusables:
        editor.add_focusable(control)


func _update_controls() -> void:
    _reset_controls()
    if color_config is StaticColorConfig:
        _static_color_picker.color = color_config.sample()
    elif color_config is HsvRangeColorConfig:
        _min_color_picker.color = Color.from_hsv(
            color_config.h_min,
            color_config.s_min,
            color_config.v_min,
            color_config.a_min)
        _max_color_picker.color = Color.from_hsv(
            color_config.h_max,
            color_config.s_max,
            color_config.v_max,
            color_config.a_max)
    elif color_config is PaletteColorConfig:
        var key_option_index := _get_option_button_index_from_label(
            color_config.key, _keys_option_button)
        _keys_option_button.select(key_option_index)
        _override_h_spin_box.value = color_config._h_override
        _override_s_spin_box.value = color_config._s_override
        _override_v_spin_box.value = color_config._v_override
        _override_a_spin_box.value = color_config._a_override
        _delta_h_spin_box.value = color_config.h_delta
        _delta_s_spin_box.value = color_config.s_delta
        _delta_v_spin_box.value = color_config.v_delta
        _delta_a_spin_box.value = color_config.a_delta
    else:
        pass
    _update_color_rect()


func _reset_controls() -> void:
    _static_color_picker.color = Color.black
    _min_color_picker.color = \
        Color(0.0, 0.0, 0.0, 0.0)
    _max_color_picker.color = \
        Color(1.0, 1.0, 1.0, 1.0)
    _keys_option_button.select(-1)
    _override_h_spin_box.value = -1.0
    _override_s_spin_box.value = -1.0
    _override_v_spin_box.value = -1.0
    _override_a_spin_box.value = -1.0
    _delta_h_spin_box.value = 0.0
    _delta_s_spin_box.value = 0.0
    _delta_v_spin_box.value = 0.0
    _delta_a_spin_box.value = 0.0


func _set_color_config(value: ColorConfig) -> void:
    # The ColorConfig was changed externally.
    
    if value == color_config:
        return
    
    _get_control_references()
    
    _is_updating = true
    color_config = value
    _update_controls()
    _show_component_editor(
        _get_popup_id_from_color_config_script(value.get_script()))
    _is_updating = false


func _on_changed() -> void:
    _get_control_references()
    _update_color_rect()
    if _is_updating:
        return
    emit_signal("changed", color_config)


func _update_color_rect() -> void:
    if is_instance_valid(color_config):
        _color_rect.visible = true
        _color_rect.color = color_config.sample()
    else:
        _color_rect.visible = false


func _get_popup_id_from_color_config_script(script: Script) -> int:
    for id in _POPUP_ITEMS:
        if _POPUP_ITEMS[id][0] == script:
            return id
    return -1


func _on_popup_menu_id_pressed(id: int) -> void:
    _show_component_editor(id)
    self.is_open = is_instance_valid(color_config)
    _on_changed()


func _on_static_color_changed(color: Color) -> void:
    if _is_updating:
        return
    _get_control_references()
    color_config.color = color
    _on_changed()


func _on_min_hsv_color_changed(color: Color) -> void:
    if _is_updating:
        return
    color_config.min_color = color
    _on_changed()


func _on_max_hsv_color_changed(color: Color) -> void:
    if _is_updating:
        return
    color_config.max_color = color
    _on_changed()


func _on_key_item_selected(index: int) -> void:
    if _is_updating:
        return
    color_config.key = _keys_option_button.get_item_text(index)
    _on_changed()


func _on_h_override_changed(value: float) -> void:
    if _is_updating:
        return
    color_config._h_override = value
    _on_changed()


func _on_s_override_changed(value: float) -> void:
    if _is_updating:
        return
    color_config._s_override = value
    _on_changed()


func _on_v_override_changed(value: float) -> void:
    if _is_updating:
        return
    color_config._v_override = value
    _on_changed()


func _on_a_override_changed(value: float) -> void:
    if _is_updating:
        return
    color_config._a_override = value
    _on_changed()


func _on_h_delta_changed(value: float) -> void:
    if _is_updating:
        return
    color_config.h_delta = value
    _on_changed()


func _on_s_delta_changed(value: float) -> void:
    if _is_updating:
        return
    color_config.s_delta = value
    _on_changed()


func _on_v_delta_changed(value: float) -> void:
    if _is_updating:
        return
    color_config.v_delta = value
    _on_changed()


func _on_a_delta_changed(value: float) -> void:
    if _is_updating:
        return
    color_config.a_delta = value
    _on_changed()

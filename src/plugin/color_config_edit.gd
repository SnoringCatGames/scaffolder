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

var _is_updating := false


func _ready() -> void:
    _is_updating = true
    _set_dimensions()
    _populate_popup_items()
    _populate_palette_options()
    _update_controls()
    _is_updating = false


func _set_dimensions() -> void:
    var headers := [
        $PluginAccordionHeader,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionHeader,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionHeader,
    ]
    var carets := [
        $PluginAccordionHeader/MarginContainer/ \
            HBoxContainer/PluginAccordionHeaderCaret,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionHeader/ \
            MarginContainer/HBoxContainer/PluginAccordionHeaderCaret,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionHeader/ \
            MarginContainer/HBoxContainer/PluginAccordionHeaderCaret,
    ]
    var row_height: float = Pl.scale_dimension(_ROW_HEIGHT)
    for header in headers:
        header.size_override = Vector2(0.0, row_height)
    for header in carets:
        header.rect_min_size.x = row_height
    $PluginAccordionHeader/MarginContainer/HBoxContainer/ \
        PanelContainer/MenuButton.rect_min_size.y = row_height


func _populate_popup_items() -> void:
    var popup_menu: PopupMenu = \
        $PluginAccordionHeader/MarginContainer/ \
        HBoxContainer/PanelContainer/MenuButton.get_popup()
    popup_menu.clear()
    for id in _POPUP_ITEMS:
        var label: String = _POPUP_ITEMS[id][1]
        popup_menu.add_item(label, id)
    popup_menu.connect("id_pressed", self, "_on_popup_menu_id_pressed")


func _populate_palette_options() -> void:
    var option_button := $PluginAccordionBody/ \
        VBoxContainer/PaletteColorConfig/Key/OptionButton
    option_button.clear()
    for key in Sc.palette._colors:
        option_button.add_item(key)
    option_button.get_popup().allow_search = true


func _get_option_button_index_from_label(
        label: String,
        option_button: OptionButton) -> int:
    for i in option_button.get_item_count():
        if option_button.get_item_text(i) == label:
            return i
    return -1


func _hide_component_editors() -> void:
    $PluginAccordionBody/VBoxContainer/StaticColorConfig \
        .visible = false
    $PluginAccordionBody/VBoxContainer/HsvRangeColorConfig \
        .visible = false
    $PluginAccordionBody/VBoxContainer/PaletteColorConfig \
        .visible = false


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
        $PluginAccordionHeader/MarginContainer/ \
            HBoxContainer/PanelContainer/MenuButton \
            .text = color_config_class_name
    else:
        color_config = null
        $PluginAccordionHeader/MarginContainer/ \
            HBoxContainer/PanelContainer/MenuButton \
            .text = _MENU_BUTTON_EMPTY_TEXT


func add_focusables(editor: EditorProperty) -> void:
    var focusables := [
        $PluginAccordionHeader/MarginContainer/ \
            HBoxContainer/PanelContainer/MenuButton,
        $PluginAccordionBody/VBoxContainer/ \
            StaticColorConfig/Color/ColorPickerButton,
        $PluginAccordionBody/VBoxContainer/ \
            HsvRangeColorConfig/MinColor/ColorPickerButton,
        $PluginAccordionBody/VBoxContainer/ \
            HsvRangeColorConfig/MaxColor/ColorPickerButton,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Key/OptionButton,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/H/ \
            SpinBox,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/S/ \
            SpinBox,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/V/ \
            SpinBox,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/A/ \
            SpinBox,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/H/ \
            SpinBox,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/S/ \
            SpinBox,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/V/ \
            SpinBox,
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/A/ \
            SpinBox,
    ]
    for control in focusables:
        editor.add_focusable(control)


func _update_controls() -> void:
    _reset_controls()
    if color_config is StaticColorConfig:
        $PluginAccordionBody/VBoxContainer/ \
            StaticColorConfig/Color/ColorPickerButton.color = \
            color_config.sample()
    elif color_config is HsvRangeColorConfig:
        $PluginAccordionBody/VBoxContainer/ \
            HsvRangeColorConfig/MinColor/ColorPickerButton.color = \
            Color.from_hsv(
                color_config.h_min,
                color_config.s_min,
                color_config.v_min,
                color_config.a_min)
        $PluginAccordionBody/VBoxContainer/ \
            HsvRangeColorConfig/MaxColor/ColorPickerButton.color = \
            Color.from_hsv(
                color_config.h_max,
                color_config.s_max,
                color_config.v_max,
                color_config.a_max)
    elif color_config is PaletteColorConfig:
        var key_option_index := _get_option_button_index_from_label(
            color_config.key,
            $PluginAccordionBody/VBoxContainer/ \
                PaletteColorConfig/Key/OptionButton)
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Key/OptionButton.select(key_option_index)
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/H/ \
            SpinBox.value = color_config._h_override
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/S/ \
            SpinBox.value = color_config._s_override
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/V/ \
            SpinBox.value = color_config._v_override
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/A/ \
            SpinBox.value = color_config._a_override
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/H/ \
            SpinBox.value = color_config.h_delta
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/S/ \
            SpinBox.value = color_config.s_delta
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/V/ \
            SpinBox.value = color_config.v_delta
        $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/A/ \
            SpinBox.value = color_config.a_delta
    else:
        pass


func _reset_controls() -> void:
    $PluginAccordionBody/VBoxContainer/StaticColorConfig/ \
        Color/ColorPickerButton.color = Color.black
    $PluginAccordionBody/VBoxContainer/ \
        HsvRangeColorConfig/MinColor/ColorPickerButton.color = \
        Color(0.0, 0.0, 0.0, 0.0)
    $PluginAccordionBody/VBoxContainer/ \
        HsvRangeColorConfig/MaxColor/ColorPickerButton.color = \
        Color(1.0, 1.0, 1.0, 1.0)
    $PluginAccordionBody/VBoxContainer/ \
        PaletteColorConfig/Key/OptionButton.select(-1)
    $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/H/ \
            SpinBox.value = -1.0
    $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/S/ \
            SpinBox.value = -1.0
    $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/V/ \
            SpinBox.value = -1.0
    $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Overrides/PluginAccordionBody/VBoxContainer/A/ \
            SpinBox.value = -1.0
    $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/H/ \
            SpinBox.value = 0.0
    $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/S/ \
            SpinBox.value = 0.0
    $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/V/ \
            SpinBox.value = 0.0
    $PluginAccordionBody/VBoxContainer/ \
            PaletteColorConfig/Deltas/PluginAccordionBody/VBoxContainer/A/ \
            SpinBox.value = 0.0


func _set_color_config(value: ColorConfig) -> void:
    # The ColorConfig was changed externally.
    
    if value == color_config:
        return
    
    _is_updating = true
    color_config = value
    _update_controls()
    _show_component_editor(
        _get_popup_id_from_color_config_script(value.get_script()))
    _is_updating = false


func _on_changed() -> void:
    if _is_updating:
        return
    emit_signal("changed", color_config)


func _get_popup_id_from_color_config_script(script: Script) -> int:
    for id in _POPUP_ITEMS:
        if _POPUP_ITEMS[id][0] == script:
            return id
    return -1


func _on_popup_menu_id_pressed(id: int) -> void:
    _show_component_editor(id)
    $PluginAccordionPanel.is_open = is_instance_valid(color_config)
    _on_changed()


func _on_static_color_changed(color: Color) -> void:
    if _is_updating:
        return
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
    color_config.key = $PluginAccordionBody/ \
        VBoxContainer/PaletteColorConfig/Key/OptionButton.get_item_text(index)
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

tool
class_name ColorConfigEditorProperty
extends EditorProperty


# FIXME: LEFT OFF HERE: -------------------------


const _POPUP_ITEMS := {
    0: [null, "Reset"],
    1: [StaticColorConfig, "New static color", "StaticColorConfig"],
    2: [HsvRangeColorConfig, "New HSV-range color", "HsvRangeColorConfig"],
    3: [PaletteColorConfig, "New palette color", "PaletteColorConfig"],
}

const _MENU_BUTTON_EMPTY_TEXT := "[empty]"

var color_config: ColorConfig

var _is_updating := false


func _ready() -> void:
    _populate_popup_items()
    _update_controls()
    _hide_component_editors()
    _add_focusables()


func _populate_popup_items() -> void:
    var popup_menu: PopupMenu = $VBoxContainer/MenuButton.get_popup()
    for id in _POPUP_ITEMS:
        var label: String = _POPUP_ITEMS[id][1]
        popup_menu.add_item(label, id)
    popup_menu.connect("id_pressed", self, "_on_popup_menu_id_pressed")


func _hide_component_editors() -> void:
    $VBoxContainer/StaticColorConfig.visible = false
    $VBoxContainer/HsvRangeColorConfig.visible = false
    $VBoxContainer/PaletteColorConfig.visible = false


func _add_focusables() -> void:
    var focusables := [
        $VBoxContainer/MenuButton,
        $VBoxContainer/StaticColorConfig/Color/ColorPickerButton,
        $VBoxContainer/HsvRangeColorConfig/MinColor/ColorPickerButton,
        $VBoxContainer/HsvRangeColorConfig/MaxColor/ColorPickerButton,
        $VBoxContainer/PaletteColorConfig/Key/LineEdit,
        $VBoxContainer/PaletteColorConfig/Overrides/H/SpinBox,
        $VBoxContainer/PaletteColorConfig/Overrides/S/SpinBox,
        $VBoxContainer/PaletteColorConfig/Overrides/V/SpinBox,
        $VBoxContainer/PaletteColorConfig/Overrides/A/SpinBox,
        $VBoxContainer/PaletteColorConfig/Deltas/H/SpinBox,
        $VBoxContainer/PaletteColorConfig/Deltas/S/SpinBox,
        $VBoxContainer/PaletteColorConfig/Deltas/V/SpinBox,
        $VBoxContainer/PaletteColorConfig/Deltas/A/SpinBox,
    ]
    for control in focusables:
        add_focusable(control)


func _update_controls() -> void:
    _reset_controls()
    if color_config is StaticColorConfig:
        $VBoxContainer/StaticColorConfig/Color/ColorPickerButton \
            .color = color_config.sample()
    elif color_config is HsvRangeColorConfig:
        $VBoxContainer/HsvRangeColorConfig/MinColor/ColorPickerButton \
            .color = Color.from_hsv(
                color_config.h_min,
                color_config.s_min,
                color_config.v_min,
                color_config.a_min)
        $VBoxContainer/HsvRangeColorConfig/MaxColor/ColorPickerButton \
            .color = Color.from_hsv(
                color_config.h_max,
                color_config.s_max,
                color_config.v_max,
                color_config.a_max)
    elif color_config is PaletteColorConfig:
        $VBoxContainer/PaletteColorConfig/Key/LineEdit \
            .text = color_config.key
        $VBoxContainer/PaletteColorConfig/Overrides/H/SpinBox \
            .value = color_config._h_override
        $VBoxContainer/PaletteColorConfig/Overrides/S/SpinBox \
            .value = color_config._s_override
        $VBoxContainer/PaletteColorConfig/Overrides/V/SpinBox \
            .value = color_config._v_override
        $VBoxContainer/PaletteColorConfig/Overrides/A/SpinBox \
            .value = color_config._a_override
        $VBoxContainer/PaletteColorConfig/Deltas/H/SpinBox \
            .value = color_config.h_delta
        $VBoxContainer/PaletteColorConfig/Deltas/S/SpinBox \
            .value = color_config.s_delta
        $VBoxContainer/PaletteColorConfig/Deltas/V/SpinBox \
            .value = color_config.v_delta
        $VBoxContainer/PaletteColorConfig/Deltas/A/SpinBox \
            .value = color_config.a_delta
    else:
        pass


func _reset_controls() -> void:
    $VBoxContainer/StaticColorConfig/Color/ColorPickerButton.color = Color.black
    $VBoxContainer/HsvRangeColorConfig/MinColor/ColorPickerButton \
            .color = Color(0.0, 0.0, 0.0, 0.0)
    $VBoxContainer/HsvRangeColorConfig/MaxColor/ColorPickerButton \
            .color = Color(1.0, 1.0, 1.0, 1.0)
    $VBoxContainer/PaletteColorConfig/Key/LineEdit.text = ""
    $VBoxContainer/PaletteColorConfig/Overrides/H/SpinBox.value = -1.0
    $VBoxContainer/PaletteColorConfig/Overrides/S/SpinBox.value = -1.0
    $VBoxContainer/PaletteColorConfig/Overrides/V/SpinBox.value = -1.0
    $VBoxContainer/PaletteColorConfig/Overrides/A/SpinBox.value = -1.0
    $VBoxContainer/PaletteColorConfig/Deltas/H/SpinBox.value = 0.0
    $VBoxContainer/PaletteColorConfig/Deltas/S/SpinBox.value = 0.0
    $VBoxContainer/PaletteColorConfig/Deltas/V/SpinBox.value = 0.0
    $VBoxContainer/PaletteColorConfig/Deltas/A/SpinBox.value = 0.0

func update_property() -> void:
    # The property was changed externally.
    
    var new_value: ColorConfig = get_edited_object()[get_edited_property()]
    if new_value == color_config:
        return
    
    _is_updating = true
    color_config = new_value
    _update_controls()
    _is_updating = false


func _on_changed() -> void:
    if _is_updating:
        return
    emit_changed(get_edited_property(), color_config)


func _on_popup_menu_id_pressed(id: int) -> void:
    _hide_component_editors()
    
    var color_config_script: Script = _POPUP_ITEMS[id][0]
    if is_instance_valid(color_config_script):
        self.color_config = color_config_script.new()
        var color_config_class_name: String = _POPUP_ITEMS[id][2]
        self.get_node("VBoxContainer/" + color_config_class_name).visible = true
        $VBoxContainer/MenuButton.text = color_config_class_name
    else:
        self.color_config = null
        $VBoxContainer/MenuButton.text = _MENU_BUTTON_EMPTY_TEXT
    
    _on_changed()


func _on_static_color_changed(color: Color) -> void:
    # FIXME: -----------------------
    _on_changed()


func _on_min_hsv_color_changed(color: Color) -> void:
    # FIXME: -----------------------
    _on_changed()


func _on_max_hsv_color_changed(color: Color) -> void:
    # FIXME: -----------------------
    _on_changed()


func _on_key_text_changed(new_text: String) -> void:
    # FIXME: -----------------------
    _on_changed()


func _on_h_override_changed() -> void:
    # FIXME: -----------------------
    _on_changed()


func _on_s_override_changed() -> void:
    # FIXME: -----------------------
    _on_changed()


func _on_v_override_changed() -> void:
    # FIXME: -----------------------
    _on_changed()


func _on_a_override_changed() -> void:
    # FIXME: -----------------------
    _on_changed()


func _on_h_delta_changed() -> void:
    # FIXME: -----------------------
    _on_changed()


func _on_s_delta_changed() -> void:
    # FIXME: -----------------------
    _on_changed()


func _on_v_delta_changed() -> void:
    # FIXME: -----------------------
    _on_changed()


func _on_a_delta_changed() -> void:
    # FIXME: -----------------------
    _on_changed()

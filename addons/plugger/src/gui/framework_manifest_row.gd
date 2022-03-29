tool
class_name FrameworkManifestRow, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
extends PanelContainer


signal changed
signal reset_pressed

const _COLOR_CONFIG_EDIT_SCENE := preload(
    "res://addons/scaffolder/src/plugin/color_config_edit.tscn")

var _ZEBRA_STRIPE_COLOR := Color.from_hsv(0.0, 0.0, 0.7, 0.1)
var _OVERRIDE_HIGHLIGHT_COLOR := Color("22ff2a00")
var _OVERRIDE_HIGHLIGHT_ZEBRA_STRIPE_COLOR := Color.from_hsv(
        _OVERRIDE_HIGHLIGHT_COLOR.h,
        _OVERRIDE_HIGHLIGHT_COLOR.s - 0.13,
        _OVERRIDE_HIGHLIGHT_COLOR.v,
        _OVERRIDE_HIGHLIGHT_COLOR.a + 0.025)
const _OVERRIDE_INDICATOR_WIDTH := 4.0

var group
var value_editor: Control
var node: FrameworkManifestEditorNode
var custom_property: FrameworkManifestCustomProperty
var indent_level: int


func set_up(
        node: FrameworkManifestEditorNode,
        indent_level: int,
        row_height: float,
        indent_width: float,
        label_width: float,
        control_width: float,
        padding: float) -> void:
    self.node = node
    self.indent_level = indent_level
    
    node.connect("is_changed_changed", self, "_on_is_changed_changed")
    
    $MarginContainer.add_constant_override("margin_top", 0.0)
    $MarginContainer.add_constant_override("margin_bottom", 0.0)
    $MarginContainer.add_constant_override("margin_left", 0.0)
    $MarginContainer.add_constant_override("margin_right", 0.0)
    
    $MarginContainer/HBoxContainer.add_constant_override("separation", 0)
    $MarginContainer/HBoxContainer/Spacer.rect_min_size.x = padding
    
    $MarginContainer/HBoxContainer/HBoxContainer/Label.rect_min_size.y = row_height
    
    $MarginContainer/HBoxContainer/OverrideIndicator.rect_min_size.x = \
            Pl.scale_dimension(_OVERRIDE_INDICATOR_WIDTH)
    
    $MarginContainer/HBoxContainer/HBoxContainer/ResetButton \
            .button_size = row_height * Vector2.ONE
    $MarginContainer/HBoxContainer/HBoxContainer/ResetButton \
            .texture_size = row_height * Vector2.ONE * 0.5
    $MarginContainer/HBoxContainer/HBoxContainer/ResetButton \
            .visible = node.is_changed
    
    if node.type == FrameworkSchema.TYPE_CUSTOM:
        $MarginContainer/HBoxContainer/HBoxContainer/Label.queue_free()
        
        assert(node.value is Script and \
                node.value.get_base_script() == FrameworkManifestCustomProperty)
        custom_property = node.value.new()
        custom_property.connect("changed", self, "emit_signal", ["changed"])
        custom_property.set_up(
                node,
                self,
                $MarginContainer/HBoxContainer,
                row_height,
                label_width,
                control_width,
                padding)
    else:
        var text: String
        if node.key is int:
            text = "[%d]" % node.key
        else:
            text = node.key.capitalize()
        
        $MarginContainer/HBoxContainer/HBoxContainer/Label.text = text
        $MarginContainer/HBoxContainer/HBoxContainer/Label.hint_tooltip = text
        
        value_editor = _create_value_editor()
        _update_control_value()
        value_editor.size_flags_horizontal = SIZE_EXPAND_FILL
        value_editor.rect_clip_content = true
        value_editor.rect_min_size.x = \
                0.0 if \
                node.type == TYPE_DICTIONARY or \
                    node.type == TYPE_ARRAY else \
                control_width
        value_editor.mouse_filter = MOUSE_FILTER_PASS
        $MarginContainer/HBoxContainer.add_child(value_editor)
        
        if node.is_overridden:
            if node.override_source != "":
                var color: Color = Sc.modes.colors[node.override_source]
                $MarginContainer/HBoxContainer/OverrideIndicator.color = color
            
            var style := StyleBoxFlat.new()
            style.bg_color = _OVERRIDE_HIGHLIGHT_COLOR
            self.add_stylebox_override("panel", style)
            
            var source_string := \
                    "" if \
                    node.override_source == "" else \
                    ("Overriding mode: %s\n" % node.override_source)
            $MarginContainer/HBoxContainer/HBoxContainer/Label.hint_tooltip = (
                "%s\n" +
                "**This property is overridden by FrameworkGlobal logic.**\n" +
                "%s" +
                "Override value: %s"
            ) % [
                text,
                source_string,
                str(node.override_value),
            ]


func open_recursively() -> void:
    # Do nothing.
    pass


func update_zebra_stripes(index: int) -> int:
    var style: StyleBox
    if node.is_overridden:
        style = self.get_stylebox("panel")
        if index % 2 == 1:
            style.bg_color = _OVERRIDE_HIGHLIGHT_COLOR
        else:
            style.bg_color = _OVERRIDE_HIGHLIGHT_ZEBRA_STRIPE_COLOR
    else:
        if index % 2 == 1:
            style = StyleBoxEmpty.new()
        else:
            style = StyleBoxFlat.new()
            style.bg_color = _ZEBRA_STRIPE_COLOR
    self.add_stylebox_override("panel", style)
    
    return index + 1


func _create_value_editor() -> Control:
    match node.type:
        TYPE_BOOL:
            return _create_bool_editor()
        TYPE_INT:
            return _create_int_editor()
        TYPE_REAL:
            return _create_float_editor()
        TYPE_STRING:
            return _create_string_editor()
        TYPE_COLOR:
            return _create_color_editor()
        TYPE_VECTOR2:
            return _create_vector2_editor()
        TYPE_RECT2:
            return _create_rect2_editor()
        TYPE_VECTOR3:
            return _create_vector3_editor()
        FrameworkSchema.TYPE_COLOR_CONFIG:
            return _create_color_config_editor()
        FrameworkSchema.TYPE_SCRIPT, \
        FrameworkSchema.TYPE_TILESET, \
        FrameworkSchema.TYPE_FONT, \
        FrameworkSchema.TYPE_RESOURCE:
            return _create_resource_editor()
        TYPE_DICTIONARY, \
        TYPE_ARRAY:
            # Use an empty placeholder control.
            return Control.new()
        _:
            Sc.logger.error(
                    "FrameworkManifestPanel._create_property_control_from_value")
            return null


func _update_control_value() -> void:
    match node.type:
        TYPE_BOOL:
            value_editor.pressed = node.value
        TYPE_INT, \
        TYPE_REAL:
            value_editor.value = node.value
        TYPE_STRING:
            value_editor.text = node.value
            value_editor.hint_tooltip = node.value
        TYPE_COLOR:
            value_editor.color = node.value
        TYPE_VECTOR2, \
        TYPE_RECT2, \
        TYPE_VECTOR3:
            value_editor.value = node.value
        FrameworkSchema.TYPE_COLOR_CONFIG:
            value_editor.color_config = node.value
        FrameworkSchema.TYPE_SCRIPT, \
        FrameworkSchema.TYPE_TILESET, \
        FrameworkSchema.TYPE_FONT, \
        FrameworkSchema.TYPE_RESOURCE:
            value_editor.edited_resource = node.value
        TYPE_DICTIONARY, \
        TYPE_ARRAY:
            # Do nothing.
            pass
        _:
            Sc.logger.error("FrameworkManifestPanel._update_control_value")


func _create_bool_editor() -> CheckBox:
    var control := CheckBox.new()
    control.connect("toggled", self, "_on_value_changed")
    return control


func _create_int_editor() -> SpinBox:
    var control := SpinBox.new()
    control.step = 1.0
    control.rounded = true
    control.connect("value_changed", self, "_on_value_changed")
    return control


func _create_float_editor() -> SpinBox:
    var control := SpinBox.new()
    control.step = 0.0
    control.rounded = false
    control.connect("value_changed", self, "_on_value_changed")
    return control


func _create_string_editor() -> LineEdit:
    var control := LineEdit.new()
    control.connect("text_changed", self, "_on_string_changed", [control])
    return control


func _create_color_editor() -> ColorPickerButton:
    var control := ColorPickerButton.new()
    control.connect("color_changed", self, "_on_value_changed")
    return control


func _create_vector2_editor() -> Vector2Editor:
    var control := Vector2Editor.new()
    control.connect("value_changed", self, "_on_value_changed")
    control.set_up()
    return control


func _create_rect2_editor() -> Rect2Editor:
    var control := Rect2Editor.new()
    control.connect("value_changed", self, "_on_value_changed")
    control.set_up()
    return control


func _create_vector3_editor() -> Vector3Editor:
    var control := Vector3Editor.new()
    control.connect("value_changed", self, "_on_value_changed")
    control.set_up()
    return control


func _create_color_config_editor() -> ColorConfigEdit:
    var control: ColorConfigEdit = _COLOR_CONFIG_EDIT_SCENE.instance()
    control.connect("changed", self, "_on_value_changed_or_mutated")
    return control


func _create_resource_editor() -> EditorResourcePicker:
    var control := EditorResourcePicker.new()
    control.base_type = FrameworkSchema.get_resource_class_name(node.type)
    control.connect("resource_changed", self, "_on_value_changed")
    return control


func _on_value_changed_or_mutated(new_value) -> void:
    node.value = new_value
    emit_signal("changed")


func _on_value_changed(new_value) -> void:
    var old_value = node.value
    if old_value != new_value:
        node.value = new_value
        emit_signal("changed")


func _on_string_changed(
        new_value: String,
        control: LineEdit) -> void:
    var old_value: String = node.value
    if old_value != new_value:
        node.value = new_value
        control.hint_tooltip = control.text
        emit_signal("changed")


func _on_is_changed_changed(is_changed: bool) -> void:
    _update_control_value()
    $MarginContainer/HBoxContainer/HBoxContainer/ResetButton \
            .visible = is_changed
    emit_signal("changed")


func _on_reset_changes_pressed() -> void:
    node.reset_changes()
    _update_control_value()
    $MarginContainer/HBoxContainer/HBoxContainer/ResetButton.visible = false
    emit_signal("changed")
    emit_signal("reset_pressed")

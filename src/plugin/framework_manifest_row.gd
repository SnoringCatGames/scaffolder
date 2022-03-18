tool
class_name FrameworkManifestRow
extends PanelContainer


signal changed

const _HIDE_SCROLL_BARS_THEME := \
        preload("res://addons/scaffolder/src/plugin/hide_scroll_bars.tres")

var node: FrameworkManifestEditorNode
var custom_property: FrameworkManifestCustomProperty


func set_up(
        node: FrameworkManifestEditorNode,
        label_width: float,
        control_width: float,
        padding: float) -> void:
    self.node = node
    
    $MarginContainer.add_constant_override("margin_top", padding)
    $MarginContainer.add_constant_override("margin_bottom", padding)
    $MarginContainer.add_constant_override("margin_left", padding)
    $MarginContainer.add_constant_override("margin_right", padding)
    
    $MarginContainer/HBoxContainer \
            .add_constant_override("separation", padding)
    
    if node.type == FrameworkManifestSchema.TYPE_CUSTOM:
        $MarginContainer/HBoxContainer/Label.queue_free()
        
        assert(node.value is Script and \
                node.value.get_base_script() == FrameworkManifestCustomProperty)
        custom_property = node.value.new()
        custom_property.connect("changed", self, "emit_signal", ["changed"])
        custom_property.set_up(
                node,
                self,
                $MarginContainer/HBoxContainer,
                label_width,
                control_width,
                padding)
    else:
        var text: String
        if node.key is int:
            text = "[%d]" % node.key
        else:
            text = node.key.capitalize()
        
        $MarginContainer/HBoxContainer/Label.text = text
        $MarginContainer/HBoxContainer/Label.hint_tooltip = text
        
        var value_editor := _create_value_editor()
        value_editor.size_flags_horizontal = SIZE_EXPAND_FILL
        value_editor.rect_clip_content = true
        value_editor.rect_min_size.x = control_width
        $MarginContainer/HBoxContainer.add_child(value_editor)


func update_zebra_stripes(index: int) -> int:
    var style: StyleBox
    if index % 2 == 1:
        style = StyleBoxEmpty.new()
    else:
        style = StyleBoxFlat.new()
        style.bg_color = Color.from_hsv(0.0, 0.0, 0.7, 0.1)
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
        FrameworkManifestSchema.TYPE_SCRIPT, \
        FrameworkManifestSchema.TYPE_TILESET, \
        FrameworkManifestSchema.TYPE_RESOURCE:
            return _create_resource_editor()
        TYPE_DICTIONARY, \
        TYPE_ARRAY:
            # Use an empty placeholder control.
            return Control.new()
        _:
            Sc.logger.error(
                    "FrameworkManifestPanel._create_property_control_from_value")
            return null


func _create_bool_editor() -> CheckBox:
    var control := CheckBox.new()
    control.pressed = node.value
    control.connect(
            "toggled",
            self,
            "_on_value_changed")
    return control


func _create_int_editor() -> SpinBox:
    var control := SpinBox.new()
    control.step = 1.0
    control.rounded = true
    control.value = node.value
    control.connect(
            "value_changed",
            self,
            "_on_value_changed")
    return control


func _create_float_editor() -> SpinBox:
    var control := SpinBox.new()
    control.step = 0.0
    control.rounded = false
    control.value = node.value
    control.connect(
            "value_changed",
            self,
            "_on_value_changed")
    return control


func _create_string_editor() -> TextEdit:
    var control := TextEdit.new()
    control.text = node.value
    control.theme = _HIDE_SCROLL_BARS_THEME
    control.hint_tooltip = node.value
    control.connect(
            "text_changed",
            self,
            "_on_string_changed",
            [control])
    return control


func _create_color_editor() -> ColorPickerButton:
    var control := ColorPickerButton.new()
    control.color = node.value
    control.connect(
            "color_changed",
            self,
            "_on_value_changed")
    return control


func _create_resource_editor() -> EditorResourcePicker:
    var control := EditorResourcePicker.new()
    control.edited_resource = node.value
    control.base_type = \
            FrameworkManifestSchema.get_resource_class_name(node.type)
    control.connect(
            "resource_changed",
            self,
            "_on_value_changed")
    return control


func _on_value_changed(value) -> void:
    node.value = value
    emit_signal("changed")


func _on_string_changed(control: TextEdit) -> void:
    node.value = control.text
    control.hint_tooltip = control.text
    emit_signal("changed")

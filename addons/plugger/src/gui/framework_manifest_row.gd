tool
class_name FrameworkManifestRow, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
extends PanelContainer


signal changed

var group
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
    
    $MarginContainer.add_constant_override("margin_top", 0.0)
    $MarginContainer.add_constant_override("margin_bottom", 0.0)
    $MarginContainer.add_constant_override("margin_left", padding)
    $MarginContainer.add_constant_override("margin_right", 0.0)
    
    $MarginContainer/HBoxContainer \
            .add_constant_override("separation", padding)
    
    $MarginContainer/HBoxContainer/Label.rect_min_size.y = row_height
    
    if node.type == FrameworkSchema.TYPE_CUSTOM:
        $MarginContainer/HBoxContainer/Label.queue_free()
        
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
        
        $MarginContainer/HBoxContainer/Label.text = text
        $MarginContainer/HBoxContainer/Label.hint_tooltip = text
        
        var value_editor := _create_value_editor()
        value_editor.size_flags_horizontal = SIZE_EXPAND_FILL
        value_editor.rect_clip_content = true
        value_editor.rect_min_size.x = \
                0.0 if \
                node.type == TYPE_DICTIONARY or \
                    node.type == TYPE_ARRAY else \
                control_width
        value_editor.mouse_filter = MOUSE_FILTER_PASS
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
        TYPE_VECTOR2:
            return _create_vector2_editor()
        TYPE_RECT2:
            return _create_rect2_editor()
        TYPE_VECTOR3:
            return _create_vector3_editor()
        FrameworkSchema.TYPE_SCRIPT, \
        FrameworkSchema.TYPE_TILESET, \
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


func _create_bool_editor() -> CheckBox:
    var control := CheckBox.new()
    control.pressed = node.value
    control.connect("toggled", self, "_on_value_changed")
    return control


func _create_int_editor() -> SpinBox:
    var control := SpinBox.new()
    control.step = 1.0
    control.rounded = true
    control.value = node.value
    control.connect("value_changed", self, "_on_value_changed")
    return control


func _create_float_editor() -> SpinBox:
    var control := SpinBox.new()
    control.step = 0.0
    control.rounded = false
    control.value = node.value
    control.connect("value_changed", self, "_on_value_changed")
    return control


func _create_string_editor() -> LineEdit:
    var control := LineEdit.new()
    control.text = node.value
    control.hint_tooltip = node.value
    control.connect("text_changed", self, "_on_string_changed", [control])
    return control


func _create_color_editor() -> ColorPickerButton:
    var control := ColorPickerButton.new()
    control.color = node.value
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


func _create_resource_editor() -> EditorResourcePicker:
    var control := EditorResourcePicker.new()
    control.edited_resource = node.value
    control.base_type = \
            FrameworkSchema.get_resource_class_name(node.type)
    control.connect("resource_changed", self, "_on_value_changed")
    return control


func _on_value_changed(new_value) -> void:
    var old_value = node.value
    if old_value != new_value:
        node.value = new_value
        emit_signal("changed")


func _on_string_changed(control: LineEdit) -> void:
    var old_value: String = node.value
    var new_value := control.text
    if old_value != new_value:
        node.value = new_value
        control.hint_tooltip = control.text
        emit_signal("changed")

tool
class_name FrameworkManifestPanel, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_panel.png"
extends PluginAccordionPanel


signal descendant_toggled

const _ROW_SCENE := \
        preload("res://addons/scaffolder/addons/plugger/src/gui/framework_manifest_row.tscn")
const _ROW_GROUP_SCENE := \
        preload("res://addons/scaffolder/addons/plugger/src/gui/framework_manifest_row_group.tscn")
const _ARRAY_BUTTONS_SCENE := \
        preload("res://addons/scaffolder/addons/plugger/src/gui/framework_manifest_array_buttons.tscn")

const _ROW_HEIGHT := 24.0
const _PANEL_WIDTH := 600.0
const _CONTROL_WIDTH := 320.0
const _PADDING := 4.0
const _INDENT_WIDTH := 16.0
const _LABEL_WIDTH := _PANEL_WIDTH - _CONTROL_WIDTH - _PADDING * 3.0

var manifest_controller: FrameworkManifestController

var _debounced_save_manifest = Sc.time.debounce(
        funcref(self, "_save_manifest_debounced"),
        0.01,
        false)
var _debounced_update_zebra_stripes = Sc.time.debounce(
        funcref(self, "_update_zebra_stripes_debounced"),
        0.001,
        false)


func _ready() -> void:
    self.connect("toggled", self, "emit_signal", ["descendant_toggled"])


func set_up(manifest_controller: FrameworkManifestController) -> void:
    self.manifest_controller = manifest_controller
    
    $AccordionHeader/MarginContainer/HBoxContainer/Label.text = \
            manifest_controller.schema.display_name
    $AccordionHeader/MarginContainer/HBoxContainer/TextureRect.texture = \
            Pl.get_icon(manifest_controller.schema.plugin_icon_path_prefix)
    
    $AccordionHeader.size_override = \
            Vector2(0.0, Pl.scale_dimension(_ROW_HEIGHT))
    $AccordionHeader/MarginContainer/HBoxContainer/Label.rect_min_size.y = \
            Pl.scale_dimension(_ROW_HEIGHT)
    $AccordionBody/HBoxContainer/Indent.rect_min_size.x = \
            Pl.scale_dimension(_INDENT_WIDTH)
    
    self.is_open = false
    
    Sc.utils.clear_children($AccordionBody/HBoxContainer/VBoxContainer)
    
    _create_property_controls(
            manifest_controller.root,
            0,
            $AccordionBody/HBoxContainer/VBoxContainer)
    
    update_zebra_stripes()


func _create_property_controls(
        node: FrameworkManifestEditorNode,
        indent_level: int,
        control_parent: Container) -> void:
    match node.type:
        TYPE_DICTIONARY:
            _create_property_controls_from_dictionary(
                    node, indent_level, control_parent)
        TYPE_ARRAY:
            _create_property_controls_from_array(
                    node, indent_level, control_parent)
        _:
            _create_property_control_from_value(
                    node, indent_level, control_parent)


func _create_property_controls_from_dictionary(
        node: FrameworkManifestEditorNode,
        indent_level: int,
        control_parent: Container) -> FrameworkManifestRowGroup:
    # Create the Dictionary row / label.
    var row: FrameworkManifestRowGroup
    if is_instance_valid(node.parent):
        row = _create_group_control(node, indent_level, control_parent)
        control_parent = row.group_body
    
    for key in node.children:
        _create_property_controls(
                node.children[key], indent_level + 1, control_parent)
    
    return row


func _create_property_controls_from_array(
        node: FrameworkManifestEditorNode,
        indent_level: int,
        control_parent: Container) -> FrameworkManifestRowGroup:
    # Create the Array row / label
    var row: FrameworkManifestRowGroup
    if is_instance_valid(node.parent):
        row = _create_group_control(node, indent_level, control_parent)
        control_parent = row.group_body
    
    for child in node.children:
        _create_property_controls(
                child, indent_level + 1, control_parent)
    
    return row


func _create_property_control_from_value(
        node: FrameworkManifestEditorNode,
        indent_level: int,
        control_parent: Container) -> FrameworkManifestRow:
    var row: FrameworkManifestRow = \
            Sc.utils.add_scene(control_parent, _ROW_SCENE)
    row.set_up(
            node,
            indent_level,
            Pl.scale_dimension(_ROW_HEIGHT),
            Pl.scale_dimension(_INDENT_WIDTH),
            Pl.scale_dimension(_LABEL_WIDTH),
            Pl.scale_dimension(_CONTROL_WIDTH),
            Pl.scale_dimension(_PADDING))
    row.connect("changed", self, "_on_value_changed")
    return row


func _create_group_control(
        node: FrameworkManifestEditorNode,
        indent_level: int,
        control_parent: Container) -> FrameworkManifestRowGroup:
    var row: FrameworkManifestRowGroup = \
            Sc.utils.add_scene(control_parent, _ROW_GROUP_SCENE)
    row.set_up(
            node,
            indent_level,
            Pl.scale_dimension(_ROW_HEIGHT),
            Pl.scale_dimension(_INDENT_WIDTH),
            Pl.scale_dimension(_LABEL_WIDTH),
            Pl.scale_dimension(_CONTROL_WIDTH),
            Pl.scale_dimension(_PADDING))
    if node.type == TYPE_ARRAY:
        row.group_buttons.connect(
                "added", self, "_on_array_item_added", [row.group_buttons])
        row.group_buttons.connect(
                "deleted", self, "_on_array_item_deleted", [row.group_buttons])
    row.connect("toggled", self, "_on_row_group_toggled", [row])
    return row


func _on_value_changed() -> void:
    _debounced_save_manifest.call_func()


func _save_manifest_debounced() -> void:
    manifest_controller.save_manifest()


func _on_array_item_added(buttons: FrameworkManifestArrayButtons) -> void:
    # Create the data field.
    var new_item = buttons.node.add_array_element()
    # Create the UI.
    _create_property_controls(
            new_item, buttons.group.indent_level + 1, buttons.group.group_body)
    buttons.group.is_open = true
    buttons.group.group_body.get_children().back().open_recursively()
    update_zebra_stripes()
    _on_value_changed()


func _on_array_item_deleted(buttons: FrameworkManifestArrayButtons) -> void:
    buttons.node.children.pop_back()
    buttons.group.group_body.get_children().back().queue_free()
    buttons.group.is_open = true
    update_zebra_stripes()
    _on_value_changed()


func _on_row_group_toggled(row: FrameworkManifestRowGroup) -> void:
    update_zebra_stripes()
    emit_signal("descendant_toggled")


func update_zebra_stripes() -> void:
    _debounced_update_zebra_stripes.call_func()


func _update_zebra_stripes_debounced() -> void:
    var row_count := 0
    for row in $AccordionBody/HBoxContainer/VBoxContainer.get_children():
        if is_instance_valid(row):
            row_count = row.update_zebra_stripes(row_count)


func load_open_rows(open_rows: Dictionary) -> void:
    for open_row_key in open_rows:
        var row = _get_row_with_key(open_row_key)
        if is_instance_valid(row) and \
                row is FrameworkManifestRowGroup:
            row.is_open = true
            row.load_open_rows(open_rows[open_row_key])
    update_zebra_stripes()


func get_open_rows() -> Dictionary:
    var open_rows := {}
    for row in $AccordionBody/HBoxContainer/VBoxContainer.get_children():
        if is_instance_valid(row) and \
                row is FrameworkManifestRowGroup and \
                row.is_open:
            open_rows[row.node.key] = row.get_open_rows()
    return open_rows


func _get_row_with_key(key):
    for row in $AccordionBody/HBoxContainer/VBoxContainer.get_children():
        if is_instance_valid(row) and \
                row.node.key == key:
            return row
    return null

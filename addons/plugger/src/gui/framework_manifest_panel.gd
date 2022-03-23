tool
class_name FrameworkManifestPanel, \
"res://addons/scaffolder/assets/images/editor_icons/control_row_list.png"
extends FrameworkManifestAccordionPanel


const _ROW_SCENE := \
        preload("res://addons/scaffolder/addons/plugger/src/gui/framework_manifest_row.tscn")
const _ROW_GROUP_SCENE := \
        preload("res://addons/scaffolder/addons/plugger/src/gui/framework_manifest_row_group.tscn")
const _ARRAY_BUTTONS_SCENE := \
        preload("res://addons/scaffolder/addons/plugger/src/gui/framework_manifest_array_buttons.tscn")

const _PANEL_WIDTH := 600.0
const _CONTROL_WIDTH := 320.0
const _PADDING := 4.0
const _INDENT_WIDTH := 32.0
const _LABEL_WIDTH := _PANEL_WIDTH - _CONTROL_WIDTH - _PADDING * 3.0

var _manifest_controller: FrameworkManifestController


func set_up(manifest_controller: FrameworkManifestController) -> void:
    self._manifest_controller = manifest_controller
    
    $AccordionHeader/HBoxContainer/Label.text = \
            _manifest_controller.schema.display_name
    $AccordionHeader/HBoxContainer/TextureRect.texture = \
            load(_manifest_controller.schema.get_editor_icon_path())
    
    Sc.utils.clear_children($AccordionBody/VBoxContainer)
    
    _create_property_controls(
            _manifest_controller.root,
            0,
            $AccordionBody/VBoxContainer)
    
    _update_zebra_stripes()


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
            _INDENT_WIDTH,
            _LABEL_WIDTH,
            _CONTROL_WIDTH,
            _PADDING)
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
            _INDENT_WIDTH,
            _LABEL_WIDTH,
            _CONTROL_WIDTH,
            _PADDING)
    if node.type == TYPE_ARRAY:
        row.group_buttons.connect(
                "added", self, "_on_array_item_added", [row.group_buttons])
        row.group_buttons.connect(
                "deleted", self, "_on_array_item_deleted", [row.group_buttons])
    return row


func _on_value_changed() -> void:
    _manifest_controller.save_manifest()


func _on_array_item_added(buttons: FrameworkManifestArrayButtons) -> void:
    # Create the data field.
    var new_item = buttons.node.add_array_element()
    # Create the UI.
    _create_property_controls(
            new_item, buttons.group.indent_level + 1, buttons.group.group_body)
    _update_zebra_stripes()
    _on_value_changed()


func _on_array_item_deleted(buttons: FrameworkManifestArrayButtons) -> void:
    buttons.node.children.pop_back()
    buttons.group.group_body.get_children().back().queue_free()
    _update_zebra_stripes()
    _on_value_changed()


func _update_zebra_stripes() -> void:
    var row_count := 0
    for row in $AccordionBody/VBoxContainer.get_children():
        if is_instance_valid(row):
            row_count = row.update_zebra_stripes(row_count)

tool
class_name FrameworkManifestRowGroup, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
extends FrameworkManifestAccordionPanel


var node: FrameworkManifestEditorNode
var indent_level: int
var indent_width: float

var group_header: FrameworkManifestRow
var group_body: Container
var group_buttons: FrameworkManifestArrayButtons


func set_up(
        node: FrameworkManifestEditorNode,
        indent_level: int,
        indent_width: float,
        label_width: float,
        control_width: float,
        padding: float) -> void:
    self.node = node
    self.indent_level = indent_level
    self.indent_width = indent_width
    
    group_header = $AccordionHeader/HBoxContainer2/Header
    group_buttons = $AccordionHeader/HBoxContainer2/Buttons
    group_body = $AccordionBody/HBoxContainer/Body
    
    $AccordionBody/HBoxContainer/Indent.rect_min_size.x = indent_width
    
    group_header.set_up(
            node,
            indent_level,
            indent_width,
            label_width,
            control_width,
            padding)
    
    if node.type == TYPE_ARRAY:
        group_buttons.set_up(
                node,
                self,
                label_width,
                control_width,
                padding)
    else:
        group_buttons.queue_free()


# FIXME: LEFT OFF HERE: --------------------------------------- Remove?
func adjust_width(screen_width: float) -> void:
    var self_width := screen_width - indent_width * indent_level
#    self.update_size_override(Vector2(self_width, 0.0))
    for row in group_body.get_children():
        if is_instance_valid(row):
            row.adjust_width(screen_width)


func update_zebra_stripes(index: int) -> int:
    if is_instance_valid(group_header):
        group_header.update_zebra_stripes(index)
    if is_instance_valid(group_buttons):
        group_buttons.update_zebra_stripes(index)
    
    index += 1
    
    for row in group_body.get_children():
        if is_instance_valid(row):
            index = row.update_zebra_stripes(index)
    
    return index


# FIXME: LEFT OFF HERE: --------------------------------------- Remove?
func update_height() -> void:
    # FIXME: --------------------- REMOVE?
    # Force Godot to update it's height calculation.
    $AccordionBody/HBoxContainer.rect_size.y = 0.0
    $AccordionBody/HBoxContainer/Indent.rect_size.y = 0.0
    $AccordionBody/HBoxContainer/Body.rect_size.y = 0.0
    .update_height()

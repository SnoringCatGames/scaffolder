tool
class_name FrameworkManifestRowGroup, \
"res://addons/scaffolder/assets/images/editor_icons/accordion_panel.png"
extends FrameworkManifestAccordionPanel


var node: FrameworkManifestEditorNode
var indent_level: int
var indent_width: float

var group_body: Container
var group_buttons: FrameworkManifestArrayButtons


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
    self.indent_width = indent_width
    
    
    group_buttons = $AccordionHeader/MarginContainer/HBoxContainer/Buttons
    group_body = $AccordionBody/HBoxContainer/Body
    
    $AccordionBody/HBoxContainer/Indent.rect_min_size.x = indent_width
    $AccordionHeader.size_override = Vector2(0.0, row_height)
    
    var text: String
    if node.key is int:
        text = "[%d]" % node.key
    else:
        text = node.key.capitalize()
    $AccordionHeader/MarginContainer/HBoxContainer/Label.text = text
    $AccordionHeader/MarginContainer/HBoxContainer/Label.hint_tooltip = text
    $AccordionHeader/MarginContainer/HBoxContainer/Label \
            .rect_min_size.y = row_height
    
    self.is_open = false
    
    if node.type == TYPE_ARRAY:
        group_buttons.set_up(
                node,
                self,
                label_width,
                control_width,
                padding)
    else:
        group_buttons.queue_free()


func update_zebra_stripes(index: int) -> int:
    index += 1
    
    for row in group_body.get_children():
        if is_instance_valid(row):
            index = row.update_zebra_stripes(index)
    
    return index

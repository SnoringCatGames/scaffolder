tool
class_name FrameworkManifestRowGroup
extends VBoxContainer


var node: FrameworkManifestEditorNode

var header: FrameworkManifestRow
var body: Container
var buttons: FrameworkManifestArrayButtons


func set_up(
        node: FrameworkManifestEditorNode,
        label_width: float,
        control_width: float,
        padding: float) -> void:
    self.node = node
    
    header = $HBoxContainer2/Header
    body = $HBoxContainer/Body
    buttons = $HBoxContainer2/Buttons
    
    header.set_up(
            node,
            label_width,
            control_width,
            padding)
    
    if node.type == TYPE_ARRAY:
        buttons.set_up(
                node,
                self,
                label_width,
                control_width,
                padding)
    else:
        buttons.queue_free()


func update_zebra_stripes(index: int) -> int:
    if is_instance_valid(header):
        header.update_zebra_stripes(index)
    if is_instance_valid(buttons):
        buttons.update_zebra_stripes(index)
    
    index += 1
    
    for row in body.get_children():
        if is_instance_valid(row):
            index = row.update_zebra_stripes(index)
    
    return index

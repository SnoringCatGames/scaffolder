tool
class_name FrameworkManifestArrayButtons
extends PanelContainer


signal added
signal deleted

var node: FrameworkManifestEditorNode
var group


func set_up(
        node: FrameworkManifestEditorNode,
        group,
        label_width: float,
        control_width: float,
        padding: float) -> void:
    self.node = node
    self.group = group
    
    $MarginContainer.add_constant_override("margin_top", padding)
    $MarginContainer.add_constant_override("margin_bottom", padding)
    $MarginContainer.add_constant_override("margin_left", padding)
    $MarginContainer.add_constant_override("margin_right", padding)
    
    $MarginContainer/HBoxContainer.add_constant_override("separation", padding)


func update_zebra_stripes(index: int) -> int:
    var style: StyleBox
    if index % 2 == 1:
        style = StyleBoxEmpty.new()
    else:
        style = StyleBoxFlat.new()
        style.bg_color = Color.from_hsv(0.0, 0.0, 0.7, 0.1)
    self.add_stylebox_override("panel", style)
    
    return index + 1


func _on_DeleteButton_pressed():
    emit_signal("deleted")


func _on_AddButton_pressed():
    emit_signal("added")

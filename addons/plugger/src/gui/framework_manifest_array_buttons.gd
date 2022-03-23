tool
class_name FrameworkManifestArrayButtons, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
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


func _on_DeleteButton_pressed():
    emit_signal("deleted")


func _on_AddButton_pressed():
    emit_signal("added")

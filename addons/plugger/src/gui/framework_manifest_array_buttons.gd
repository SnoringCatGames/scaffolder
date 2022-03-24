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
    
    $MarginContainer.add_constant_override("margin_top", 0.0)
    $MarginContainer.add_constant_override("margin_bottom", 0.0)
    $MarginContainer.add_constant_override("margin_left", 0.0)
    $MarginContainer.add_constant_override("margin_right", 0.0)
    
    $MarginContainer/HBoxContainer.add_constant_override("separation", padding)


func _on_DeleteButton_pressed():
    emit_signal("deleted")


func _on_AddButton_pressed():
    emit_signal("added")

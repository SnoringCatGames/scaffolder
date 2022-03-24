tool
class_name FrameworkManifestCustomProperty
extends Reference


signal changed

var node
var row
var parent_control: Control


func set_up(
        node,
        row,
        parent_control: Control,
        row_height: float,
        label_width: float,
        control_width: float,
        padding: float) -> void:
    push_error(
            "Abstract FrameworkManifestCustomProperty.get_ui " +
            "is not implemented")

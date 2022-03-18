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
        label_width: float,
        control_width: float,
        padding: float) -> void:
    Sc.logger.error(
            "Abstract FrameworkManifestCustomProperty.get_ui " +
            "is not implemented")

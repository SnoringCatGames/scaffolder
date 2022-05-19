tool
class_name HudCustomValueBox
extends HudKeyValueBox


func _ready() -> void:
    var control := item.create_control()
    $HBoxContainer/HBoxContainer.add_child(control)


func _on_gui_scale_changed() -> bool:
    ._on_gui_scale_changed()
    return false


func _update_display() -> void:
    item.update_item()

tool
class_name HudCustomValueBox
extends HudKeyValueBox


func _ready() -> void:
    $HBoxContainer/HBoxContainer.add_child(item.create_control())


func _on_gui_scale_changed() -> bool:
    ._on_gui_scale_changed()
    return false


func _update_display() -> void:
    item.update_item()

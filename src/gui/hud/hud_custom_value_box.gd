tool
class_name HudCustomValueBox
extends HudKeyValueBox


func _ready() -> void:
    $HBoxContainer/HBoxContainer.add_child(item.create_control())


func _update_display() -> void:
    item.update_item()

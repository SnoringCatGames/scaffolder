class_name HudKeyValueBox
extends ScaffolderPanelContainer


const SEPARATION := 12.0

var item: TextLabeledControlItem


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    _on_gui_scale_changed()


func _on_gui_scale_changed() -> bool:
    var size: Vector2 = \
            Gs.gui.hud_manifest.hud_key_value_box_size * Gs.gui.scale
    var spacer_size: float = SEPARATION * Gs.gui.scale
    rect_min_size = size
    rect_size = size
    $HBoxContainer.rect_min_size = size
    $HBoxContainer.rect_size = size
    $HBoxContainer/Spacer.rect_size.x = spacer_size
    $HBoxContainer/Spacer.rect_min_size.x = spacer_size
    $HBoxContainer/Spacer2.rect_size.x = spacer_size
    $HBoxContainer/Spacer2.rect_min_size.x = spacer_size
    return true


func _process(_delta: float) -> void:
    if !is_instance_valid(Gs.level):
        return
    _update_display()


func _update_display() -> void:
    item.update_item()
    $HBoxContainer/Key.text = item.label
    $HBoxContainer/Value.text = item.text

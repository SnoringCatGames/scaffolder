class_name HudKeyValueBox
extends Control


const SEPARATION := 12.0

var item: TextLabeledControlItem

var nine_patch_rect: NinePatchRect

func _ready() -> void:
    nine_patch_rect = Gs.utils.add_scene(
            self,
            Gs.hud_key_value_box_nine_patch_rect_path,
            true,
            true,
            0)
    update_gui_scale(1.0)


func update_gui_scale(gui_scale: float) -> bool:
    var size: Vector2 = Gs.hud_key_value_box_size * Gs.gui_scale
    var spacer_size: float = SEPARATION * Gs.gui_scale
    rect_min_size = size
    rect_size = size
    nine_patch_rect.rect_min_size = Gs.hud_key_value_box_size
    nine_patch_rect.rect_size = Gs.hud_key_value_box_size
    nine_patch_rect.rect_scale = Vector2(Gs.gui_scale, Gs.gui_scale)
    $HBoxContainer.rect_min_size = size
    $HBoxContainer.rect_size = size
    $HBoxContainer/Spacer.rect_size.x = spacer_size
    $HBoxContainer/Spacer.rect_min_size.x = spacer_size
    $HBoxContainer/Spacer2.rect_size.x = spacer_size
    $HBoxContainer/Spacer2.rect_min_size.x = spacer_size
    return true


func _process(_delta: float) -> void:
    _update_display()


func _update_display() -> void:
    item.update_item()
    $HBoxContainer/Key.text = item.label
    $HBoxContainer/Value.text = item.text

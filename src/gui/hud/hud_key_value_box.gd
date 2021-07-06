class_name HudKeyValueBox
extends Control


const SEPARATION := 12.0

var item: TextLabeledControlItem

var nine_patch_rect: NinePatchRect

func _ready() -> void:
    if Engine.editor_hint:
        return
    
    nine_patch_rect = Gs.utils.add_scene(
            self,
            Gs.gui.hud_manifest.hud_key_value_box_nine_patch_rect_scene,
            true,
            true,
            0)
    _on_gui_scale_changed()


func _on_gui_scale_changed() -> bool:
    var size: Vector2 = \
            Gs.gui.hud_manifest.hud_key_value_box_size * Gs.gui.scale
    var spacer_size: float = SEPARATION * Gs.gui.scale
    rect_min_size = size
    rect_size = size
    nine_patch_rect.rect_min_size = Gs.gui.hud_manifest.hud_key_value_box_size
    nine_patch_rect.rect_size = Gs.gui.hud_manifest.hud_key_value_box_size
    nine_patch_rect.rect_scale = Vector2(Gs.gui.scale, Gs.gui.scale)
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

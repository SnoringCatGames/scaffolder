class_name ScaffolderHud
extends Node2D


var hud_key_value_list: HudKeyValueList


func _ready() -> void:
    assert(Gs.gui.hud_manifest.has("hud_key_value_box_size"))
    assert(Gs.gui.hud_manifest.has("hud_key_value_list_item_manifest"))
    assert(Gs.gui.hud_manifest.has("hud_key_value_box_scene"))
    assert(Gs.gui.hud_manifest.has("hud_key_value_list_scene"))
    assert(Gs.gui.hud_manifest.has("hud_key_value_box_nine_patch_rect_scene"))
    
    var is_hud_key_value_list_shown: bool = false
    for item_config in Gs.gui.hud_manifest.hud_key_value_list_item_manifest:
        if item_config.enabled:
            is_hud_key_value_list_shown = true
            break
    
    if is_hud_key_value_list_shown:
        hud_key_value_list = Gs.utils.add_scene(
                self,
                Gs.gui.hud_manifest.hud_key_value_list_scene,
                true,
                true)


func _destroy() -> void:
    hud_key_value_list._destroy()
    queue_free()

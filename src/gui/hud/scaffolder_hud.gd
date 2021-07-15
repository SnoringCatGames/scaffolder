class_name ScaffolderHud
extends Node2D


var hud_key_value_list: HudKeyValueList


func _ready() -> void:
    assert(Sc.gui.hud_manifest.has("hud_key_value_box_size"))
    assert(Sc.gui.hud_manifest.has("hud_key_value_list_item_manifest"))
    assert(Sc.gui.hud_manifest.has("hud_key_value_box_scene"))
    assert(Sc.gui.hud_manifest.has("hud_key_value_list_scene"))
    
    var is_hud_key_value_list_shown: bool = false
    for item_config in Sc.gui.hud_manifest.hud_key_value_list_item_manifest:
        if item_config.enabled:
            is_hud_key_value_list_shown = true
            break
    
    if is_hud_key_value_list_shown:
        hud_key_value_list = Sc.utils.add_scene(
                self,
                Sc.gui.hud_manifest.hud_key_value_list_scene,
                true,
                true)


func _destroy() -> void:
    hud_key_value_list._destroy()
    if !is_queued_for_deletion():
        queue_free()

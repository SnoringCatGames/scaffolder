class_name ScaffolderHud
extends Node2D


const HUD_KEY_VALUE_LIST_PATH := \
        "res://addons/scaffolder/src/gui/hud/hud_key_value_list.tscn"

var hud_key_value_list: HudKeyValueList


func _ready() -> void:
    assert(Gs.gui.hud_manifest.has("hud_key_value_box_size"))
    assert(Gs.gui.hud_manifest.has("hud_key_value_list_item_manifest"))
    assert(Gs.gui.hud_manifest.has("hud_key_value_box_nine_patch_rect_path"))
    
    var is_hud_key_value_list_shown: bool = \
            !Gs.gui.hud_manifest.hud_key_value_list_item_manifest.empty()
    if is_hud_key_value_list_shown:
        hud_key_value_list = Gs.utils.add_scene(
                self,
                HUD_KEY_VALUE_LIST_PATH,
                true,
                true)


func _destroy() -> void:
    if is_instance_valid(hud_key_value_list):
        Gs.canvas_layers.layers.hud.remove_child(hud_key_value_list)
    queue_free()

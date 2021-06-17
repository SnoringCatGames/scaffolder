class_name HudKeyValueList
extends VBoxContainer


const HUD_KEY_VALUE_BOX_RESOURCE_PATH := \
        "res://addons/scaffolder/src/gui/hud/hud_key_value_box.tscn"
const DEFAULT_GUI_SCALE := 1.0

var boxes := []


func _ready() -> void:
    for item_config in Gs.hud_manifest.hud_key_value_list_item_manifest:
        var box: HudKeyValueBox = Gs.utils.add_scene(
                self,
                HUD_KEY_VALUE_BOX_RESOURCE_PATH,
                false,
                true)
        box.item = item_config.item_class.new(Gs.level)
        add_child(box)
        boxes.push_back(box)
    
    Gs.add_gui_to_scale(self, DEFAULT_GUI_SCALE)
    
    update_gui_scale(1.0)


func update_gui_scale(gui_scale: float) -> bool:
    var separation: float = HudKeyValueBox.SEPARATION * Gs.gui_scale
    
    rect_position = Vector2(separation, separation)
    
    return false

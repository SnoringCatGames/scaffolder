class_name HudKeyValueList
extends VBoxContainer


const HUD_KEY_VALUE_BOX_PATH := \
        "res://addons/scaffolder/src/gui/hud/hud_key_value_box.tscn"
const DEFAULT_GUI_SCALE := 1.0

var boxes := []


func _ready() -> void:
    update_list()
    
    Gs.gui.add_gui_to_scale(self, DEFAULT_GUI_SCALE)
    
    update_gui_scale(1.0)


func update_gui_scale(gui_scale: float) -> bool:
    var separation: float = HudKeyValueBox.SEPARATION * Gs.gui.scale
    
    rect_position = Vector2(separation, separation)
    
    return false


func update_list() -> void:
    for box in boxes:
        box.queue_free()
    boxes.clear()
    
    for item_config in Gs.gui.hud_manifest.hud_key_value_list_item_manifest:
        if !item_config.enabled:
            continue
        
        var box: HudKeyValueBox = Gs.utils.add_scene(
                self,
                HUD_KEY_VALUE_BOX_PATH,
                false,
                true)
        box.item = item_config.item_class.new(Gs.level_session)
        add_child(box)
        boxes.push_back(box)

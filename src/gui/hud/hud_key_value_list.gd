tool
class_name HudKeyValueList
extends VBoxContainer


var boxes := []


func _ready() -> void:
    update_list()
    
    Sc.gui.add_gui_to_scale(self)
    
    _on_gui_scale_changed()


func _destroy() -> void:
    Sc.gui.remove_gui_to_scale(self)
    if !is_queued_for_deletion():
        queue_free()


func _on_gui_scale_changed() -> bool:
    var separation: float = HudKeyValueBox.SEPARATION * Sc.gui.scale
    
    rect_position = Vector2(separation, separation)
    
    return false


func update_list() -> void:
    for box in boxes:
        box.queue_free()
    boxes.clear()
    
    for item_config in Sc.gui.hud_manifest.hud_key_value_list_item_manifest:
        if !item_config.enabled:
            continue
        
        var box: HudKeyValueBox = Sc.utils.add_scene(
                self,
                Sc.gui.hud_manifest.hud_key_value_box_scene,
                false,
                true)
        box.item = item_config.item_class.new(Sc.level_session)
        add_child(box)
        boxes.push_back(box)

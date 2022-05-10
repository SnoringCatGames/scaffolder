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


func get_bottom_coordinate() -> float:
    var row_count := boxes.size()
    var separation: float = HudKeyValueBox.SEPARATION * Sc.gui.scale
    var box_height: float = \
            boxes[0].rect_size.y if \
            !boxes.empty() else \
            0.0
    return (box_height + separation) * row_count


func update_list() -> void:
    for box in boxes:
        box.queue_free()
    boxes.clear()
    
    for item_config in Sc.gui.hud_manifest.hud_key_value_list_item_manifest:
        if !item_config.enabled:
            continue
        
        var item: ControlRow = item_config.item_class.new(Sc.levels.session)
        var hud_key_value_box_scene: PackedScene = \
                Sc.gui.hud_manifest.hud_key_value_box_scene if \
                item is TextControlRow else \
                Sc.gui.hud_manifest.hud_custom_value_box_scene
        var box: HudKeyValueBox = Sc.utils.add_scene(
                self,
                hud_key_value_box_scene,
                false,
                true)
        if item_config.has("animation"):
            box.animation_config = item_config.animation
        box.item = item_config.item_class.new(Sc.levels.session)
        add_child(box)
        boxes.push_back(box)

tool
class_name HudKeyValueList
extends ScaffolderPanelContainer


var boxes := []

var font_size := "Xs"


func _ready() -> void:
    update_list()
    
    if Sc.gui.hud.is_key_value_list_consolidated:
        self.style = ScaffolderPanelContainer.PanelStyle.HUD
    else:
        self.style = ScaffolderPanelContainer.PanelStyle.TRANSPARENT
    
    Sc.gui.add_gui_to_scale(self)


func _destroy() -> void:
    Sc.gui.remove_gui_to_scale(self)
    if !is_queued_for_deletion():
        queue_free()


func _on_gui_scale_changed() -> bool:
    call_deferred("_deferred_on_gui_scale_changed")
    return false


func _deferred_on_gui_scale_changed() -> bool:
    self.visible = !boxes.empty()
    
    var separation: float = HudKeyValueBox.get_separation() * Sc.gui.scale
    
    $VBoxContainer.add_constant_override("separation", separation)
    
    if Sc.gui.hud.is_key_value_list_consolidated:
        rect_position = Vector2(8.0, 8.0) * Sc.gui.scale
        self.content_margin_top_override = 4.0
        self.content_margin_bottom_override = 4.0
    else:
        rect_position = Vector2(separation, separation)
    
    if !boxes.empty():
        $VBoxContainer.rect_size = boxes[0].rect_size
    
    rect_size = $VBoxContainer.rect_size
    
    return false


func get_bottom_coordinate() -> float:
    var row_count := boxes.size()
    var separation: float = HudKeyValueBox.get_separation() * Sc.gui.scale
    var box_height: float = \
            boxes[0].rect_size.y if \
            !boxes.empty() else \
            0.0
    return (box_height + separation) * row_count


func update_list() -> void:
    for box in boxes:
        box.queue_free()
    boxes.clear()
    
    for i in Sc.gui.hud_manifest.hud_key_value_list_item_manifest.size():
        var item_config: Dictionary = \
            Sc.gui.hud_manifest.hud_key_value_list_item_manifest[i]
        if !item_config.enabled:
            continue
        
        var item: ControlRow = item_config.item_class.new(Sc.levels.session)
        item.is_in_hud = true
        item.font_size = font_size
        var hud_key_value_box_scene: PackedScene = \
                Sc.gui.hud_manifest.hud_key_value_box_scene if \
                item is TextControlRow else \
                Sc.gui.hud_manifest.hud_custom_value_box_scene
        var box: HudKeyValueBox = Sc.utils.add_scene(
                $VBoxContainer,
                hud_key_value_box_scene,
                false,
                true)
        if item_config.has("animation"):
            box.animation_config = item_config.animation
        box.item = item
        $VBoxContainer.add_child(box)
        boxes.push_back(box)
        
        if Sc.gui.hud.is_key_value_list_consolidated and \
                i < Sc.gui.hud_manifest.hud_key_value_list_item_manifest.size() - 1:
            var separator: ScaffolderHSeparator = Sc.utils.add_scene(
                $VBoxContainer, Sc.gui.SCAFFOLDER_H_SEPARATOR)
            separator.size_override = Vector2(0.0, 0.2)
            separator.modulate = Sc.palette.get_color("separator")
    
    Sc.utils.set_mouse_filter_recursively(
        self,
        Control.MOUSE_FILTER_IGNORE)
    
    _on_gui_scale_changed()

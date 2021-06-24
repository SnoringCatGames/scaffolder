class_name SettingsGroup
extends VBoxContainer


var group_name: String


func _ready() -> void:
    var group_config: Dictionary = \
            Gs.gui.settings_item_manifest.groups[group_name]
    
    var items: Array
    for item_class in group_config.item_classes:
        var item: LabeledControlItem = item_class.new()
        items.push_back(item)
    
    if group_config.has("hud_enablement_items"):
        for item_config in group_config.hud_enablement_items:
            var item := \
                    HudKeyValueItemSettingsLabeledControlItem.new(item_config)
            items.push_back(item)
    
    var list: LabeledControlList
    if group_config.is_collapsible:
        $LabeledControlList.queue_free()
        list = $AccordionPanel/VBoxContainer/LabeledControlList
        
        $AccordionPanel.header_text = group_config.label
        $AccordionPanel.header_min_height = 32.0
    else:
        $AccordionPanel.queue_free()
        list = $LabeledControlList
    
    list.items = items

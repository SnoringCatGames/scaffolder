tool
class_name SettingsGroup, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_placeholder.png"
extends VBoxContainer


var group_name: String


func _ready() -> void:
    if Engine.editor_hint and \
            group_name == "":
        return
    
    var group_config: Dictionary = \
            Sc.gui.settings_item_manifest.groups[group_name]
    
    var items: Array
    for item_class in group_config.item_classes:
        var item: ControlRow = item_class.new()
        items.push_back(item)
    
    if group_config.has("hud_enablement_items"):
        for item_config in group_config.hud_enablement_items:
            var item := \
                    HudKeyValueItemControlRow.new(item_config)
            items.push_back(item)
    
    var list: LabeledControlList
    if group_config.is_collapsible:
        $LabeledControlList.queue_free()
        list = $AccordionPanel/AccordionBody/VBoxContainer/LabeledControlList
        
        $AccordionPanel/AccordionHeader.header_text = group_config.label
    else:
        $AccordionPanel.queue_free()
        list = $LabeledControlList
    
    list.items = items

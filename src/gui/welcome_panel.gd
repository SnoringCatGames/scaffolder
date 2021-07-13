tool
class_name WelcomePanel
extends ScaffolderPanelContainer


const _OPACITY := 0.9
const _FADE_IN_DURATION := 0.2

export var size_override := Vector2.ZERO


func _init() -> void:
    modulate.a = 0.0


func _enter_tree() -> void:
    if Engine.editor_hint:
        return
    
    Gs.time.tween_property(
            self,
            "modulate:a",
            0.0,
            _OPACITY,
            _FADE_IN_DURATION)


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    Gs.gui.record_gui_original_size_recursively(self)
    
    theme = Gs.gui.theme
    
    Gs.gui.add_gui_to_scale(self)
    
    var faded_color: Color = Gs.colors.zebra_stripe_even_row
    faded_color.a *= 0.3
    
    var items := []
    for item in Gs.gui.welcome_panel_manifest.items:
        if item.size() == 1:
            items.push_back(HeaderLabeledControlItem.new(item[0]))
        else:
            assert(item.size() == 2)
            items.push_back(StaticTextLabeledControlItem.new(item[0], item[1]))
    
    var list := $VBoxContainer/LabeledControlList
    var header := $VBoxContainer/ScaffolderPanelContainer/VBoxContainer/Header
    var subheader := \
            $VBoxContainer/ScaffolderPanelContainer/VBoxContainer/Subheader
    
    list.even_row_color_override = faded_color
    list.items = items
    
    if Gs.gui.welcome_panel_manifest.has("header") and \
            !Gs.gui.welcome_panel_manifest.header.empty():
        header.text = Gs.gui.welcome_panel_manifest.header
    else:
        header.text = Gs.app_metadata.app_name
    
    if Gs.gui.welcome_panel_manifest.has("subheader") and \
            !Gs.gui.welcome_panel_manifest.subheader.empty():
        subheader.text = Gs.gui.welcome_panel_manifest.subheader
    
    if Gs.gui.welcome_panel_manifest.has("is_subheader_shown") and \
            !Gs.gui.welcome_panel_manifest.is_subheader_shown:
        subheader.visible = false
    
    _on_gui_scale_changed()


func _on_gui_scale_changed() -> bool:
    for child in .get_children():
        if child is Control:
            Gs.gui.scale_gui_recursively(child)
    
    rect_min_size = size_override * Gs.gui.scale
    rect_size.x = rect_min_size.x
    rect_size.y = \
            $VBoxContainer/ScaffolderPanelContainer/VBoxContainer/Header \
                    .rect_size.y + \
            $VBoxContainer/ScaffolderPanelContainer/VBoxContainer/Subheader \
                    .rect_size.y + \
            $VBoxContainer/LabeledControlList.rect_size.y
    rect_position = (get_viewport().size - rect_size) / 2.0
    
    return true


func _exit_tree() -> void:
    Gs.gui.remove_gui_to_scale(self)

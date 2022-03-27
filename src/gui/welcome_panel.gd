tool
class_name WelcomePanel
extends ScaffolderPanelContainer


const _OPACITY := 0.9
const _FADE_IN_DURATION := 0.2

export var size_override := Vector2.ZERO


func _init() -> void:
    modulate.a = 0.0


func _ready() -> void:
    Sc.gui.record_gui_original_size_recursively(self)
    
    theme = Sc.gui.theme
    
    Sc.gui.add_gui_to_scale(self)
    
    Sc.time.tween_property(
            self,
            "modulate:a",
            0.0,
            _OPACITY,
            _FADE_IN_DURATION)
    
    var faded_color: Color = Sc.palette.get_color("zebra_stripe_even_row")
    faded_color.a *= 0.3
    
    var items := []
    for item in Sc.gui.welcome_panel_manifest.items:
        if item.size() == 1:
            items.push_back(HeaderControlRow.new(item[0]))
        else:
            assert(item.size() == 2)
            items.push_back(StaticTextControlRow.new(item[0], item[1]))
    
    var list := $VBoxContainer/LabeledControlList
    var header := $VBoxContainer/ScaffolderPanelContainer/VBoxContainer/Header
    var subheader := \
            $VBoxContainer/ScaffolderPanelContainer/VBoxContainer/Subheader
    
    list.even_row_color_override = faded_color
    list.items = items
    
    if Sc.gui.welcome_panel_manifest.has("header") and \
            !Sc.gui.welcome_panel_manifest.header.empty():
        header.text = Sc.gui.welcome_panel_manifest.header
    else:
        header.text = Sc.metadata.app_name
    
    if Sc.gui.welcome_panel_manifest.has("subheader") and \
            !Sc.gui.welcome_panel_manifest.subheader.empty():
        subheader.text = Sc.gui.welcome_panel_manifest.subheader
    
    if Sc.gui.welcome_panel_manifest.has("is_subheader_shown") and \
            !Sc.gui.welcome_panel_manifest.is_subheader_shown:
        subheader.visible = false
    
    _on_gui_scale_changed()


func _destroy() -> void:
    Sc.gui.remove_gui_to_scale(self)
    if !is_queued_for_deletion():
        queue_free()


func _on_gui_scale_changed() -> bool:
    for child in Sc.utils.get_children_by_type(self, Control):
        Sc.gui.scale_gui_recursively(child)
    
    rect_min_size = size_override * Sc.gui.scale
    rect_size.x = rect_min_size.x
    rect_size.y = \
            $VBoxContainer/ScaffolderPanelContainer/VBoxContainer/Header \
                    .rect_size.y + \
            $VBoxContainer/ScaffolderPanelContainer/VBoxContainer/Subheader \
                    .rect_size.y + \
            $VBoxContainer/LabeledControlList.rect_size.y
    rect_position = (Sc.device.get_viewport_size() - rect_size) / 2.0
    
    return true

tool
class_name FullScreenPanel, \
"res://addons/scaffolder/assets/images/editor_icons/full_screen_panel.png"
extends PanelContainer


func _init() -> void:
    if Engine.editor_hint:
        return
    
    theme = Gs.gui.theme
    add_font_override("font", Gs.gui.fonts.main_m)


func _enter_tree() -> void:
    if Engine.editor_hint:
        rect_size = Vector2(1024, 768)
        return
    
    Gs.utils.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _on_resized() -> void:
    rect_size = get_viewport().size

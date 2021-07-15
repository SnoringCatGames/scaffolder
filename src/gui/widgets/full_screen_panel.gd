tool
class_name FullScreenPanel, \
"res://addons/scaffolder/assets/images/editor_icons/full_screen_panel.png"
extends PanelContainer


func _init() -> void:
    theme = Sc.gui.theme
    add_font_override("font", Sc.gui.fonts.main_m)


func _ready() -> void:
    Sc.device.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _on_resized() -> void:
    rect_size = Sc.device.get_viewport_size()

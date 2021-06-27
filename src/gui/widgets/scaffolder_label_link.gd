tool
class_name ScaffolderLabelLink, "res://addons/scaffolder/assets/images/editor_icons/scaffolder_label_link.png"
extends LinkButton


export var url: String


func _ready() -> void:
    add_color_override("font_color", Gs.colors.link_normal)
    add_color_override("font_color_hover", Gs.colors.link_hover)
    add_color_override("font_color_pressed", Gs.colors.link_pressed)


func _on_ScaffolderLabelLink_pressed():
    assert(!url.empty())
    Gs.utils.give_button_press_feedback()
    OS.shell_open(url)

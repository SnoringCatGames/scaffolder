tool
class_name ScaffolderLabelLink, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_label_link.png"
extends LinkButton


export var url: String


func _ready() -> void:
    add_color_override("font_color", Sc.palette.get_color("link_normal"))
    add_color_override("font_color_hover", Sc.palette.get_color("link_hover"))
    add_color_override("font_color_pressed", Sc.palette.get_color("link_pressed"))


func _on_ScaffolderLabelLink_pressed() -> void:
    assert(!url.empty())
    Sc.utils.give_button_press_feedback()
    OS.shell_open(url)

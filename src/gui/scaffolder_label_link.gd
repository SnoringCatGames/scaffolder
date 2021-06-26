tool
class_name ScaffolderLabelLink
extends LinkButton


export var url: String


func _on_ScaffolderLabelLink_pressed():
    assert(!url.empty())
    Gs.utils.give_button_press_feedback()
    OS.shell_open(url)

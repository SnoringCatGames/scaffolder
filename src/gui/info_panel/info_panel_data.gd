class_name InfoPanelData
extends Reference


var header_text := ""
var contents: Control
var includes_close_button := true
var meta


func _init(
        header_text := "",
        contents: Control = null,
        includes_close_button := true) -> void:
    self.header_text = header_text
    self.contents = contents
    self.includes_close_button = includes_close_button

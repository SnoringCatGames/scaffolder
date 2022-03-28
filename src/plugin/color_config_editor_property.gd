tool
class_name ColorConfigEditorProperty
extends EditorProperty


const _COLOR_CONFIG_EDIT_SCENE := preload(
    "res://addons/scaffolder/src/plugin/color_config_edit.tscn")

var _color_config_edit: ColorConfigEdit

var _is_updating := false


func _init() -> void:
    _color_config_edit = Sc.utils.add_scene(self, _COLOR_CONFIG_EDIT_SCENE)
    _color_config_edit.connect("changed", self, "_on_changed")


func _ready() -> void:
    _color_config_edit.add_focusables(self)


func update_property() -> void:
    # The property was changed externally.
    
    var new_value: ColorConfig = get_edited_object()[get_edited_property()]
    if new_value == _color_config_edit.color_config:
        return
    
    _is_updating = true
    _color_config_edit.color_config = new_value
    _is_updating = false


func _on_changed(value: ColorConfig) -> void:
    if _is_updating:
        return
    emit_changed(get_edited_property(), value)

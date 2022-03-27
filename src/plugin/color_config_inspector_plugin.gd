tool
class_name ColorConfigInspectorPlugin
extends EditorInspectorPlugin


const _COLOR_CONFIG_EDITOR_SCENE := preload(
    "res://addons/scaffolder/src/plugin/color_config_editor_property.tscn")


func can_handle(object: Object) -> bool:
    return true


func parse_property(
        object: Object,
        type: int,
        path: String,
        hint: int,
        hint_text: String,
        usage: int) -> bool:
    if hint == ScaffolderPropertyHint.PROPERTY_HINT_COLOR_CONFIG:
        add_property_editor(path, _COLOR_CONFIG_EDITOR_SCENE.instance())
        # Remove the default editor for this property.
        return true
    else:
        # Use the default editor for this property.
        return false

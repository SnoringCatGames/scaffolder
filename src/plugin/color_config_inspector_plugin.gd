tool
class_name ColorConfigInspectorPlugin
extends EditorInspectorPlugin


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
        add_property_editor(path, ColorConfigEditorProperty.new())
        # Remove the default editor for this property.
        return true
    else:
        # Use the default editor for this property.
        return false

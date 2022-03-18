tool
class_name FrameworkManifestSchema
extends Reference


const TYPE_SCRIPT := 1001
const TYPE_TILESET := 1002
const TYPE_RESOURCE := 1003
const TYPE_CUSTOM := 1004

const VALID_TYPES := {
    TYPE_BOOL: true,
    TYPE_STRING: true,
    TYPE_INT: true,
    TYPE_REAL: true,
    TYPE_COLOR: true,
    TYPE_SCRIPT: true,
    TYPE_TILESET: true,
    TYPE_RESOURCE: true,
    TYPE_CUSTOM: true,
}


func get_framework_display_name() -> String:
    Sc.logger.error(
            "Abstract FrameworkManifestSchema.get_framework_display_name " +
            "is not implemented")
    return ""


func get_framework_folder_name() -> String:
    Sc.logger.error(
            "Abstract FrameworkManifestSchema.get_framework_folder_name " +
            "is not implemented")
    return ""


func get_properties() -> Dictionary:
    Sc.logger.error(
            "Abstract FrameworkManifestSchema.get_properties " +
            "is not implemented")
    return {}


func get_manifest_path() -> String:
    var folder_name := get_framework_folder_name()
    return "res://addons/%s/manifest.json" % folder_name


static func get_default_value(schema):
    if schema is Dictionary:
        return {}
    elif schema is Array:
        if schema.size() == 1:
            return []
        else:
            return schema[1]
    else:
        Sc.logger.error("FrameworkManifestSchema.get_default_value")


static func get_is_expected_type(
        value,
        expected_type) -> bool:
    if expected_type is int:
        var actual_type := get_type(value)
        match expected_type:
            actual_type:
                return true
            TYPE_SCRIPT, \
            TYPE_TILESET, \
            TYPE_RESOURCE:
                return value == null
            TYPE_INT, \
            TYPE_REAL:
                return actual_type == TYPE_INT or actual_type == TYPE_REAL
            _:
                return false
    elif expected_type is Dictionary:
        return value is Dictionary
    elif expected_type is Array:
        return value is Array
    else:
        return false


static func get_matches_schema(
        value,
        schema) -> bool:
    if schema is Dictionary:
        return value is Dictionary
    elif schema is Array:
        if schema.size() == 1:
            return value is Array
        else:
            return get_is_expected_type(value, schema[0])
    else:
        Sc.logger.error("FrameworkManifestSchema.get_matches_schema")
        return false


static func get_type(value) -> int:
    if value is Script:
        if value.get_base_script() == FrameworkManifestCustomProperty:
            return TYPE_CUSTOM
        else:
            return TYPE_SCRIPT
    elif value is TileSet:
        return TYPE_TILESET
    elif value is Resource:
        return TYPE_RESOURCE
    else:
        return typeof(value)


static func get_type_string(type) -> String:
    if type is int:
        pass
    elif type is Dictionary:
        type = TYPE_DICTIONARY
    elif type is Array:
        type = TYPE_ARRAY
    elif type is Script:
        return "TYPE_CUSTOM"
    else:
        Sc.logger.error("FrameworkManifestSchema.get_type_string")
        return ""
    
    match type:
        TYPE_SCRIPT:
            return "TYPE_SCRIPT"
        TYPE_TILESET:
            return "TYPE_TILESET"
        TYPE_RESOURCE:
            return "TYPE_RESOURCE"
        TYPE_CUSTOM:
            return "TYPE_CUSTOM"
        _:
            return Sc.utils.get_type_string(type)


static func get_resource_class_name(type: int) -> String:
    match type:
        TYPE_SCRIPT:
            return "Script"
        TYPE_TILESET:
            return "TileSet"
        TYPE_RESOURCE:
            return "Resource"
        TYPE_CUSTOM:
            return "Script"
        _:
            Sc.logger.error("FrameworkManifestSchema.get_resource_class_name")
            return ""

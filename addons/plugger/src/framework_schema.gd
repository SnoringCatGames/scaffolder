tool
class_name FrameworkSchema
extends Reference


const TYPE_SCRIPT := 1001
const TYPE_TILESET := 1002
const TYPE_RESOURCE := 1003
const TYPE_CUSTOM := 1004

const _VALID_TYPES := {
    TYPE_BOOL: true,
    TYPE_STRING: true,
    TYPE_INT: true,
    TYPE_REAL: true,
    TYPE_COLOR: true,
    TYPE_VECTOR2: true,
    TYPE_RECT2: true,
    TYPE_VECTOR3: true,
    TYPE_SCRIPT: true,
    TYPE_TILESET: true,
    TYPE_RESOURCE: true,
    TYPE_CUSTOM: true,
    TYPE_DICTIONARY: true,
    TYPE_ARRAY: true,
}

var display_name: String
var folder_name: String
var auto_load_name: String
var auto_load_deps: Array
var auto_load_path: String
var manifest_path: String
var plugin_icon_path_prefix: String
var properties: Dictionary


func _init(
        framework_metadata_script: Script,
        properties: Dictionary) -> void:
    var metadata = framework_metadata_script.new()
    assert(metadata is PluginMetadata)
    self.display_name = metadata.display_name
    self.folder_name = metadata.folder_name
    self.auto_load_name = metadata.auto_load_name
    self.auto_load_deps = metadata.auto_load_deps
    self.auto_load_path = metadata.auto_load_path
    self.plugin_icon_path_prefix = metadata.plugin_icon_path_prefix
    self.manifest_path = metadata.manifest_path
    self.properties = properties


static func get_default_value(schema):
    if schema is Dictionary:
        return {}
    elif schema is Array:
        if get_is_explicit_type_entry(schema):
            # Explicit-type value definition.
            if schema[0] == TYPE_DICTIONARY:
                return {}
            elif schema[0] == TYPE_ARRAY:
                return []
            else:
                return schema[1]
        else:
            return []
    else:
        # Inferred-type value definition.
        return schema


static func get_is_explicit_type_entry(entry) -> bool:
    if !entry is Array:
        return false
    if entry.size() != 2:
        return false
    if !entry[0] is int:
        return false
    if (entry[0] == TYPE_INT or entry[0] == TYPE_REAL) != \
            (entry[1] is int or entry[1] is float):
        return false
    # NOTE: This can produce false-positives for arrays of integers of size 2.
    return true


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
        if get_is_explicit_type_entry(schema):
            # Explicit-type value definition.
            return get_is_expected_type(value, schema[0])
        else:
            return value is Array
    else:
        # Inferred-type value definition.
        var type := get_type(schema)
        if get_is_valid_type(type):
            return get_is_expected_type(value, type)
        else:
            push_error("FrameworkSchema.get_matches_schema")
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
        push_error("FrameworkSchema.get_type_string")
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
        
        TYPE_NIL:
            return "TYPE_NIL"
        TYPE_BOOL:
            return "TYPE_BOOL"
        TYPE_INT:
            return "TYPE_INT"
        TYPE_REAL:
            return "TYPE_REAL"
        TYPE_STRING:
            return "TYPE_STRING"
        TYPE_VECTOR2:
            return "TYPE_VECTOR2"
        TYPE_RECT2:
            return "TYPE_RECT2"
        TYPE_VECTOR3:
            return "TYPE_VECTOR3"
        TYPE_TRANSFORM2D:
            return "TYPE_TRANSFORM2D"
        TYPE_PLANE:
            return "TYPE_PLANE"
        TYPE_QUAT:
            return "TYPE_QUAT"
        TYPE_AABB:
            return "TYPE_AABB"
        TYPE_BASIS:
            return "TYPE_BASIS"
        TYPE_TRANSFORM:
            return "TYPE_TRANSFORM"
        TYPE_COLOR:
            return "TYPE_COLOR"
        TYPE_NODE_PATH:
            return "TYPE_NODE_PATH"
        TYPE_RID:
            return "TYPE_RID"
        TYPE_OBJECT:
            return "TYPE_OBJECT"
        TYPE_DICTIONARY:
            return "TYPE_DICTIONARY"
        TYPE_ARRAY:
            return "TYPE_ARRAY"
        TYPE_RAW_ARRAY:
            return "TYPE_RAW_ARRAY"
        TYPE_INT_ARRAY:
            return "TYPE_INT_ARRAY"
        TYPE_REAL_ARRAY:
            return "TYPE_REAL_ARRAY"
        TYPE_STRING_ARRAY:
            return "TYPE_STRING_ARRAY"
        TYPE_VECTOR2_ARRAY:
            return "TYPE_VECTOR2_ARRAY"
        TYPE_VECTOR3_ARRAY:
            return "TYPE_VECTOR3_ARRAY"
        TYPE_COLOR_ARRAY:
            return "TYPE_COLOR_ARRAY"
        TYPE_MAX:
            return "TYPE_MAX"
        
        _:
            push_error("FrameworkSchema.get_type_string")
            return ""


static func get_is_valid_type(type: int) -> bool:
    return _VALID_TYPES.has(type)


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
            push_error("FrameworkSchema.get_resource_class_name")
            return ""
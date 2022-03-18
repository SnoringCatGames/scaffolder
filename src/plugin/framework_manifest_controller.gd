tool
class_name FrameworkManifestController
extends Reference


var schema: FrameworkManifestSchema

var root: FrameworkManifestEditorNode


func _init(schema: FrameworkManifestSchema) -> void:
    self.schema = schema
    _validate_schema_recursively(schema.properties)
    _load()
    save()


func _validate_schema_recursively(
        schema_value,
        prefix := "") -> void:
    assert(schema_value is Dictionary or \
            schema_value is Array,
            "Invalid manifest schema structure: %s" % prefix)
    
    if schema_value is Dictionary:
        for key in schema_value:
            var value = schema_value[key]
            _validate_schema_recursively(
                    value,
                    prefix + key + ">")
    elif schema_value is Array:
        if schema_value.size() == 1:
            _validate_schema_recursively(
                    schema_value[0],
                    prefix + "[0]>")
        else:
            assert(schema_value.size() == 2,
                    ("Manifest schema value definitions must be of size 2: " +
                    "%s, %s") % [prefix, str(schema_value)])
            var type = schema_value[0]
            assert(type is int and \
                    FrameworkManifestSchema.VALID_TYPES.has(type),
                    ("Manifest schema value definitions must start with a " +
                    "TYPE enum: %s, %s") % [prefix, str(type)])
            var value = schema_value[1]
            assert(FrameworkManifestSchema.get_is_expected_type(value, type),
                    ("Manifest schema value definitions must include a " +
                    "default value that matches the TYPE enum: %s, %s, %s") % [
                        prefix,
                        FrameworkManifestSchema.get_type_string(type),
                        str(value),
                    ])


func _load() -> void:
    var manifest_properties: Dictionary = \
            Sc.json.load_file(schema.get_manifest_path(), true, true)
    root = FrameworkManifestEditorNode.new(null, "", schema.properties)
    root.load_from_manifest(manifest_properties)


func save() -> void:
    St.manifest = root.get_manifest_value()
    Sc.json.save_file(
            St.manifest,
            schema.get_manifest_path(),
            true,
            true)

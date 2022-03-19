tool
class_name FrameworkManifestController
extends Reference


signal manifest_changed(manifest)

var schema: FrameworkSchema

var root: FrameworkManifestEditorNode


func _init(schema: FrameworkSchema) -> void:
    self.schema = schema
    _validate_schema_recursively(schema.properties)


func _validate_schema_recursively(
        schema_value,
        prefix := "") -> void:
    assert(schema_value is Dictionary or \
            schema_value is Array,
            "Invalid schema structure: %s" % prefix)
    
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
                    ("Schema value definitions must be of size 2: " +
                    "%s, %s") % [prefix, str(schema_value)])
            var type = schema_value[0]
            assert(type is int and \
                    FrameworkSchema.VALID_TYPES.has(type),
                    ("Schema value definitions must start with a " +
                    "TYPE enum: %s, %s") % [prefix, str(type)])
            var value = schema_value[1]
            assert(FrameworkSchema.get_is_expected_type(value, type),
                    ("Schema value definitions must include a " +
                    "default value that matches the TYPE enum: %s, %s, %s") % [
                        prefix,
                        FrameworkSchema.get_type_string(type),
                        str(value),
                    ])


func load_manifest() -> Dictionary:
    var manifest_properties: Dictionary = \
            Sc.json.load_file(schema.get_manifest_path(), true, true)
    root = FrameworkManifestEditorNode.new(null, "", schema.properties)
    root.load_from_manifest(manifest_properties)
    if Engine.editor_hint:
        # In case the schema has changed since we last saved the manifest, save
        # the up-to-date version of the manifest.
        save_manifest(false)
    return root.get_manifest_value()


func save_manifest(is_changed := true) -> void:
    var manifest: Dictionary = root.get_manifest_value()
    Sc.json.save_file(
            manifest,
            schema.get_manifest_path(),
            true,
            true)
    if is_changed:
        emit_signal("manifest_changed")

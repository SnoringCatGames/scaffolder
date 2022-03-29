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
    if schema_value is Dictionary:
        for key in schema_value:
            var value = schema_value[key]
            _validate_schema_recursively(
                    value,
                    prefix + key + ">")
    elif schema_value is Array:
        assert(!schema_value.empty(),
                ("Schema arrays must not be empty: %s") % [prefix])
        if FrameworkSchema.get_is_explicit_type_entry(schema_value):
            # Explicit-type value definition.
            var type = schema_value[0]
            assert(type is int and \
                    FrameworkSchema.get_is_valid_type(type),
                    ("Schema explicit-type value definitions must start " +
                    "with a TYPE enum: %s, %s") % [prefix, str(type)])
            var value = schema_value[1]
            assert(FrameworkSchema.get_is_expected_type(value, type),
                    ("Schema explicit-type value definitions must include a " +
                    "default value that matches the TYPE enum: %s, %s, %s") % [
                        prefix,
                        FrameworkSchema.get_type_string(type),
                        str(value),
                    ])
        else:
            var first_element = schema_value[0]
            if first_element is Dictionary:
                for i in schema_value.size():
                    var element = schema_value[i]
                    assert(element.size() == first_element.size())
                    for key in first_element:
                        assert(element.has(key) and \
                                FrameworkSchema.get_type(element[key]) == \
                                FrameworkSchema.get_type(first_element[key]),
                                "All Dictionary entries in a schema array " +
                                "must have the same structure: %s[%s].%s" % [
                                    prefix,
                                    str(i),
                                    key,
                                ])
            else:
                for value in schema_value:
                    assert(FrameworkSchema.get_type(value) == \
                            FrameworkSchema.get_type(first_element),
                            ("All entries in a schema array must be of the " +
                            "same type: %s, %s, %s") % [
                                prefix,
                                str(value),
                                str(first_element),
                            ])
            _validate_schema_recursively(
                    first_element,
                    prefix + "[0]>")
    else:
        # Inferred-type value definition.
        var type := FrameworkSchema.get_type(schema_value)
        assert(type != null,
                ("The type cannot be inferred for a null type " +
                "in the framework schema: %s") % prefix)
        assert(FrameworkSchema.get_is_valid_type(type),
                ("Schema inferred-type value definitions must use a " +
                "default value that is a valid TYPE: %s, %s, %s") % [
                    prefix,
                    FrameworkSchema.get_type_string(type),
                    str(schema_value),
                ])


func load_manifest() -> Dictionary:
    var manifest_properties: Dictionary = \
            Sc.json.load_file(schema.manifest_path, true, true)
    root = FrameworkManifestEditorNode.new(null, "", schema.properties)
    root.load_from_manifest(manifest_properties)
    if Engine.editor_hint:
        # In case the schema has changed since we last saved the manifest, save
        # the up-to-date version of the manifest.
        save_manifest(false)
    return root.get_manifest_value()


func save_manifest(is_changed := true) -> void:
    Sc.json.save_file(
            root.get_manifest_value(),
            schema.manifest_path,
            true,
            true)
    if is_changed:
        emit_signal("manifest_changed")

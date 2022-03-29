tool
class_name FrameworkManifestEditorNode
extends Reference


var type: int
var value
var default_value
var children

var parent
var key
var schema

var is_overridden := false
var override_source: String
var override_value


func _init(parent, key, schema) -> void:
    self.parent = parent
    self.key = key
    if FrameworkSchema.get_is_explicit_type_entry(schema) and \
            (schema[0] == TYPE_DICTIONARY or \
            schema[0] == TYPE_ARRAY):
        schema = schema[1]
    self.schema = schema


func load_from_manifest(
        manifest,
        includes_defaults_from_schema := false) -> void:
    if schema is Dictionary:
        _load_from_manifest_dictionary(manifest)
    elif schema is Array:
        if FrameworkSchema.get_is_explicit_type_entry(schema):
            type = schema[0]
            value = manifest
        else:
            _load_from_manifest_array(manifest, includes_defaults_from_schema)
    else:
        # Inferred-type value definition.
        var schema_type := FrameworkSchema.get_type(schema)
        if FrameworkSchema.get_is_valid_type(schema_type):
            type = schema_type
            value = manifest
        else:
            Sc.logger.error("FrameworkManifestEditorNode.load_from_manifest")


func _load_from_manifest_dictionary(manifest) -> void:
    assert(schema is Dictionary and \
            manifest is Dictionary)
    
    # Remove any unexpected keys from the manifest.
    for key in manifest.keys():
        if !schema.has(key):
            _log_warning(
                    "Unexpected key saved in manifest Dictionary",
                    ("%s=%s") % [str(key), str(manifest[key])])
            manifest.erase(key)
    
    # Remove any invalid-typed entries from the manifest.
    for key in manifest.keys():
        if !FrameworkSchema \
                .get_matches_schema(manifest[key], schema[key]):
            _log_warning(
                    "Invalid type saved in manifest Dictionary",
                    ("%s=%s") % [str(key), str(manifest[key])])
            manifest.erase(key)
    
    type = TYPE_DICTIONARY
    children = {}
    for key in schema:
        # Ensure a manifest entry exists for this key.
        var did_key_exist_in_manifest: bool = manifest.has(key)
        if !did_key_exist_in_manifest:
            manifest[key] = FrameworkSchema.get_default_value(schema[key])
        
        var child = get_script().new(self, key, schema[key])
        child.load_from_manifest(manifest[key], !did_key_exist_in_manifest)
        children[key] = child


func _load_from_manifest_array(
        manifest,
        includes_defaults_from_schema: bool) -> void:
    assert(schema is Array and \
            manifest is Array)
    
    # Remove any invalid-typed entries from the manifest.
    var i := 0
    while i < manifest.size():
        if !FrameworkSchema \
                .get_matches_schema(manifest[i], schema[0]):
            _log_warning(
                    "Invalid type saved in manifest Array",
                    ("[%s]=%s") % [str(i), str(manifest[i])])
            manifest.remove(i)
            i -= 1
        i += 1
    
    if includes_defaults_from_schema:
        if schema.size() == 1 and \
                FrameworkSchema.get_is_explicit_type_entry(schema[0]):
            # Don't auto-include a default manifest entry if the schema entry
            # is only meant to define the type.
            pass
        else:
            # Ensure defaults exist in the manifest.
            manifest.resize(schema.size())
            for j in schema.size():
                manifest[j] = FrameworkSchema.get_default_value(schema[j])
    
    type = TYPE_ARRAY
    children = []
    children.resize(manifest.size())
    for j in manifest.size():
        var child_schema = schema[j] if j < schema.size() else schema[0]
        var child = get_script().new(self, j, child_schema)
        child.load_from_manifest(manifest[j], includes_defaults_from_schema)
        children[j] = child


func add_array_element():
    assert(type == TYPE_ARRAY)
    var child = get_script().new(self, children.size(), schema[0])
    child.load_from_manifest(FrameworkSchema.get_default_value(schema[0]), true)
    children.push_back(child)
    return child


func get_manifest_value():
    match type:
        TYPE_DICTIONARY:
            var dictionary := {}
            for key in children:
                dictionary[key] = children[key].get_manifest_value()
            return dictionary
        TYPE_ARRAY:
            var array := []
            array.resize(children.size())
            for i in children.size():
                array[i] = children[i].get_manifest_value()
            return array
        _:
            return value


func get_node_path() -> String:
    if !is_instance_valid(parent):
        return ""
    else:
        var prefix: String = parent.get_node_path()
        var suffix: String = \
                "." + key if \
                key is String else \
                "[" + str(key) + "]"
        return prefix + suffix


func _log_warning(
        message: String,
        details: String) -> void:
    Sc.logger.warning(
            ("%s (This may mean you included a null value in the manifest " +
            "schema whose type cannot be inferred, or this may mean you " +
            "changed a property in the schema): %s (%s)") % [
                message,
                get_node_path(),
                details,
            ])

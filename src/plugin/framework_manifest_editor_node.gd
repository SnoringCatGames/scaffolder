tool
class_name FrameworkManifestEditorNode
extends Reference


var type: int
var value
var children

var parent
var key
var schema


func _init(parent, key, schema) -> void:
    self.parent = parent
    self.key = key
    self.schema = schema


func load_from_manifest(manifest) -> void:
    if schema is Dictionary:
        _load_from_manifest_dictionary(manifest)
    elif schema is Array:
        if schema.size() == 1:
            _load_from_manifest_array(manifest)
        else:
            type = schema[0]
            value = manifest
    else:
        Sc.logger.error("FrameworkManifestEditorNode.load_from_manifest")


func _load_from_manifest_dictionary(manifest) -> void:
    # Ensure the manifest is the correct type.
    if !manifest is Dictionary:
        _log_warning(
                "Invalid type saved in manifest",
                ("expected: Dictionary, actual: %s") % str(manifest))
        manifest = {}
    
    # Remove any unexpected keys from the manifest.
    for key in manifest.keys():
        if !schema.has(key):
            _log_warning(
                    "Unexpected key saved in manifest Dictionary",
                    ("%s=%s") % [str(key), str(manifest[key])])
            manifest.erase(key)
    
    # Remove any invalid-typed entries from the manifest.
    for key in manifest.keys():
        if !FrameworkManifestSchema \
                .get_matches_schema(manifest[key], schema[key]):
            _log_warning(
                    "Invalid type saved in manifest Dictionary",
                    ("%s=%s") % [str(key), str(manifest[key])])
            manifest.erase(key)
    
    type = TYPE_DICTIONARY
    children = {}
    for key in schema:
        # Ensure a manifest entry exists for this key.
        if !manifest.has(key):
            manifest[key] = \
                    FrameworkManifestSchema.get_default_value(schema[key])
        
        var child = get_script().new(self, key, schema[key])
        child.load_from_manifest(manifest[key])
        children[key] = child


func _load_from_manifest_array(manifest) -> void:
    # Ensure the manifest is the correct type.
    if !manifest is Array:
        _log_warning(
                "Invalid type saved in manifest",
                ("expected: Array, actual: %s") % str(manifest))
        manifest = []
    
    # Remove any invalid-typed entries from the manifest.
    var i := 0
    while i < manifest.size():
        if !FrameworkManifestSchema \
                .get_matches_schema(manifest[i], schema[0]):
            _log_warning(
                    "Invalid type saved in manifest Array",
                    ("[%s]=%s") % [str(i), str(manifest[i])])
            manifest.remove(i)
            i -= 1
        i += 1
    
    type = TYPE_ARRAY
    children = []
    children.resize(manifest.size())
    for j in manifest.size():
        var child = get_script().new(self, j, schema[0])
        child.load_from_manifest(manifest[j])
        children[j] = child


func add_array_element():
    assert(type == TYPE_ARRAY)
    var child = get_script().new(self, children.size(), schema[0])
    child.load_from_manifest(
            FrameworkManifestSchema.get_default_value(schema[0]))
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
            ("%s (this probably happened because you changed a " +
            "property in the schema, which is fine!): " +
            "%s (%s)") % [
                message,
                get_node_path(),
                details,
            ])

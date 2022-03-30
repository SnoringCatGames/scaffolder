tool
class_name FrameworkManifestEditorNode
extends Reference


signal changed
signal is_changed_changed(is_changed)

var type: int
var value setget _set_value
var children

var parent
var key
var schema

var is_changed := false setget _set_is_changed

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
            _set_value(manifest)
        else:
            _load_from_manifest_array(manifest, includes_defaults_from_schema)
    else:
        # Inferred-type value definition.
        var schema_type := FrameworkSchema.get_type(schema)
        if FrameworkSchema.get_is_valid_type(schema_type):
            type = schema_type
            _set_value(manifest)
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
    
    var has_default_number_of_children: bool
    if schema.size() == 1 and \
            FrameworkSchema.get_is_explicit_type_entry(schema[0]):
        has_default_number_of_children = manifest.empty()
    else:
        has_default_number_of_children = manifest.size() == schema.size()
    _set_is_changed(!has_default_number_of_children)
    
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
    _set_is_changed(true)
    return child


func remove_array_element(i := -1) -> void:
    if i < 0:
        children.pop_back()
    else:
        children.remove(i)
    _set_is_changed(true, true, true)


func get_manifest_value(includes_default_values: bool):
    match type:
        TYPE_DICTIONARY:
            var dictionary := {}
            for key in children:
                if includes_default_values or \
                        children[key].is_changed:
                    dictionary[key] = children[key] \
                            .get_manifest_value(includes_default_values)
            return dictionary
        TYPE_ARRAY:
            var array := []
            array.resize(children.size())
            for i in children.size():
                array[i] = children[i] \
                        .get_manifest_value(includes_default_values)
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


func _set_value(
        new_value,
        propagates := true,
        forces_emit_changed := false) -> void:
    if value != new_value:
        value = new_value
        emit_signal("changed")
        # Auto-update is_changed for non-group rows.
        if type != TYPE_DICTIONARY and \
                type != TYPE_ARRAY:
            _set_is_changed(
                    value != FrameworkSchema.get_default_value(schema),
                    propagates)
    elif forces_emit_changed:
        emit_signal("changed")


func _set_is_changed(
        new_is_changed: bool,
        propagates := true,
        forces_emit_changed := false) -> void:
    if is_changed != new_is_changed:
        is_changed = new_is_changed
        emit_signal("changed")
        emit_signal("is_changed_changed", is_changed)
        _propagate_is_changed()
    elif forces_emit_changed:
        emit_signal("changed")


func _propagate_is_changed() -> void:
    if !is_instance_valid(parent):
        return
    if !is_changed:
        # We need to check if any other child is still changed.
        if parent.type == TYPE_DICTIONARY:
            for child in parent.children.values():
                if child.is_changed:
                    return
        elif parent.type == TYPE_ARRAY:
            for child in parent.children:
                if child.is_changed:
                    return
    parent._set_is_changed(is_changed, true)


func reset_changes() -> void:
    if !is_changed:
        return
    _set_value(FrameworkSchema.get_default_value(schema), false)
    if type == TYPE_DICTIONARY:
        for child in children.values():
            child.reset_changes()
    elif type == TYPE_ARRAY:
        children.clear()
        self.load_from_manifest(FrameworkSchema.get_default_value(schema), true)


func get_default_value():
    return FrameworkSchema.get_default_value(schema)

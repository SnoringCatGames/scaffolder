tool
class_name FrameworkGlobal
extends Node


signal registered
signal initialized

const _DEP_CHECK_INTERVAL := 0.005
const _DEP_FAIL_DURATION := 0.2
const _RUN_AFTER_FRAMEWORK_REGISTERED_DEBOUNCE_DELAY := 0.05

var is_registered := false
var is_initialized := false

var _schema_class_or_path

var schema: FrameworkSchema
var editor_node: FrameworkManifestEditorNode
var manifest: Dictionary


func _init(schema_class_or_path) -> void:
    self._schema_class_or_path = schema_class_or_path


func _ready() -> void:
    call_deferred("_instantiate_schema", _schema_class_or_path)


func _instantiate_schema(_schema_class_or_path) -> void:
    self.schema = Singletons.instance(_schema_class_or_path)
    _check_addons_directory()
    Sc.logger.on_global_init(self, schema.auto_load_name)
    Sc.register_framework_global(self)
    _start_polling_for_auto_load_deps()


func _destroy() -> void:
    for member in _get_members_to_destroy():
        if is_instance_valid(member):
            if member.has_method("_destroy"):
                member._destroy()
            elif member.has_method("queue_free"):
                member.queue_free()
            else:
                # Old Reference instances should be automatically cleaned up
                # when re-assigned.
                assert(member is Reference)
    editor_node = null
    manifest = {}
    is_initialized = false


func _get_members_to_destroy() -> Array:
    Sc.logger.error(
            "Abstract FrameworkGlobal._get_members_to_destroy " +
            "is not implemented")
    return []


## This life-cycle event is called when all the AutoLoads that this framework
## depends on are available.
func _on_auto_load_deps_ready() -> void:
    pass


## This gives the framework a chance to modify configurations in either its own
## manifest or another framework's manifest before the manifests have been
## parsed.
func _amend_manifest() -> void:
    pass


## This is where the manifest is actually interpreted and its properties are
## recorded within this global object.
func _parse_manifest() -> void:
    pass


## -   This is where the framework should instantiate other objects that it
##     depends on.
## -   Configuration of these objects should be avoided until
##     _configure_sub_modules.
##     -   This separation enables one object to reference another when they're
##         being initialized (otherwise, the dependency might not exist yet).
func _instantiate_sub_modules() -> void:
    pass


## -   This is where objects instantiated by the framework should be configured.
## -   This separation from _instantiate_sub_modules enables one object to
##     reference another when they're being initialized (otherwise, the
##     dependency might not exist yet).
func _configure_sub_modules() -> void:
    pass


## -   This is where state should be loaded if it is saved in local user
##     storage.
## -   This consists of things like save state and local settings.
func _load_state() -> void:
    pass


func _override_manifest(
        additive_overrides: Array,
        subtractive_overrides := []) -> void:
    var globals := {}
    for global in Sc._framework_globals:
        globals[global.schema.auto_load_name] = global
    
    for entry in subtractive_overrides:
        var result := parse_override_entry(entry, globals)
        
        assert(result.was_key_in_manifest and \
                result.was_key_in_manifest_node_tree)
        
        var manifest_index: int = \
                result.manifest[result.token].find(result.property_value)
        assert(manifest_index >= 0)
        result.manifest[result.token].remove(manifest_index)
        
        var node: FrameworkManifestEditorNode = \
                result.node.children[result.token]
        assert(node.type == TYPE_ARRAY)
        var found_match := false
        for i in node.children.size():
            if node.children[i].value == result.property_value:
                found_match = true
                node.remove_array_element(i)
                break
        assert(found_match)
        node.override_value = {subtract = result.property_value}
        node.override_source = result.override_source
        node.is_overridden = true
    
    for entry in additive_overrides:
        var result := parse_override_entry(entry, globals)
        result.manifest[result.token] = result.property_value
        
        if result.was_key_in_manifest_node_tree:
            result.node = result.node.children[result.token]
            result.node.override_value = result.property_value
            result.node.override_source = result.override_source
            result.node.is_overridden = true


func parse_override_entry(
        entry: Array,
        globals: Dictionary) -> Dictionary:
    var property_path: String = entry[0]
    var property_value = entry[1]
    var override_source: String = \
            entry[2] if \
            entry.size() > 2 else \
            ""
    
    assert(property_path.find("[") < 0,
            "Array-element overrides are not currently supported.")
    var tokens: PoolStringArray = property_path.split(".")
    assert(tokens.size() > 2)
    
    assert(override_source == "" or \
            Sc.modes.options.has(override_source),
            "Override sources currently must correspond to a registered " +
            "mode")
    
    var token: String = tokens[0]
    assert(globals.has(token))
    var global: FrameworkGlobal = globals[token]
    
    token = tokens[1]
    assert(token == "manifest")
    var manifest: Dictionary = global.manifest
    
    var node := global.editor_node
    
    for i in range(2, tokens.size() - 1):
        token = tokens[i]
        manifest = manifest[token]
        node = node.children[token]
    
    token = tokens[tokens.size() - 1]
    
    var was_key_in_manifest := manifest.has(token)
    var was_key_in_manifest_node_tree: bool = node.children.has(token)
    
    return {
        token = token,
        manifest = manifest,
        node = node,
        property_path = property_path,
        property_value = property_value,
        override_source = override_source,
        was_key_in_manifest = was_key_in_manifest,
        was_key_in_manifest_node_tree = was_key_in_manifest_node_tree,
    }


func set_editor_node(editor_node: FrameworkManifestEditorNode) -> void:
    self.editor_node = editor_node
    editor_node.connect("changed", self, "_on_manifest_changed")
    self.manifest = editor_node.get_manifest_value(true)


func _set_manifest_path() -> void:
    for global in Sc._framework_globals:
        if global.schema.manifest_path_override != "":
            Sc.manifest_path = global.schema.manifest_path_override


func _set_registered() -> void:
    if !is_registered:
        is_registered = true
        _set_manifest_path()
        _on_auto_load_deps_ready()
        emit_signal("registered")
        Sc._trigger_debounced_run()


func _set_initialized() -> void:
    if !is_initialized:
        is_initialized = true
        emit_signal("initialized")


func _on_manifest_changed() -> void:
    # FIXME: --------
    # - Reset this, and all dependent, frameworks.
    # - Save all dependent frameworks during the sorting / circular-deps check.
    pass


func _check_addons_directory() -> void:
    if schema.folder_name != "":
        assert(self.get_script().resource_path.begins_with(
                    "res://addons/%s" % schema.folder_name),
                "%s must be located in your project's 'addons' directory." % \
                    schema.display_name)


func _start_polling_for_auto_load_deps() -> void:
    var timer := Timer.new()
    timer.one_shot = true
    timer.wait_time = _DEP_CHECK_INTERVAL
    timer.set_meta("i", 0)
    timer.connect(
            "timeout",
            self,
            "_check_if_all_auto_load_deps_are_present",
            [timer])
    add_child(timer)
    _check_if_all_auto_load_deps_are_present(timer)


func _check_if_all_auto_load_deps_are_present(timer: Timer) -> void:
    var missing_dep_name := _get_missing_auto_load_dep_name()
    if missing_dep_name == "":
        # All AutoLoad dependencies are present.
        timer.queue_free()
        _set_registered()
    else:
        # An AutoLoad dependency is missing.
        var i: int = timer.get_meta("i")
        var timer_count := _DEP_FAIL_DURATION / _DEP_CHECK_INTERVAL
        if i >= timer_count:
            push_error(("Framework AutoLoad dependency is missing: %s=>%s") % [
                        schema.auto_load_name,
                        missing_dep_name,
                    ])
            timer.queue_free()
        else:
            timer.set_meta("i", i + 1)
            timer.start()


func _get_missing_auto_load_dep_name() -> String:
    for auto_load_dep in schema.auto_load_deps:
        if !has_node("/root/" + auto_load_dep):
            return auto_load_dep
    return ""

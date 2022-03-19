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

var schema: FrameworkSchema
var manifest_controller: FrameworkManifestController
var manifest: Dictionary


func _init(schema_class: Script) -> void:
    self.schema = Singletons.instance(schema_class)


func _ready() -> void:
    self.schema = schema
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
    manifest_controller = null
    manifest = {}
    is_initialized = false


func _get_members_to_destroy() -> Array:
    Sc.logger.error(
            "Abstract FrameworkGlobal._get_members_to_destroy " +
            "is not implemented")
    return []


func _load_manifest() -> void:
    self.manifest_controller = FrameworkManifestController.new(schema)
    self.manifest = manifest_controller.load_manifest()
    manifest_controller \
            .connect("manifest_changed", self, "_on_manifest_changed")


func _on_auto_load_deps_ready() -> void:
    pass


func _amend_manifest() -> void:
    pass


func _parse_manifest() -> void:
    pass


func _instantiate_sub_modules() -> void:
    pass


func _configure_sub_modules() -> void:
    pass


func _load_state() -> void:
    pass


func _set_registered() -> void:
    if !is_registered:
        is_registered = true
        _on_auto_load_deps_ready()
        emit_signal("registered")
        Sc._trigger_debounced_run()


func _set_initialized() -> void:
    if !is_initialized:
        is_initialized = true
        emit_signal("initialized")


func _on_manifest_changed() -> void:
    # FIXME: LEFT OFF HERE: --------------------------------
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

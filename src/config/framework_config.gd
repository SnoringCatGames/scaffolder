tool
class_name FrameworkConfig
extends Node


signal registered
signal initialized

const _DEP_CHECK_INTERVAL := 0.005
const _DEP_FAIL_DURATION := 0.2

var is_registered := false
var is_initialized := false

var _framework_display_name: String
var _framework_addons_folder_name: String
var _auto_load_name: String
var _auto_load_deps: Array

# NOTE: This will only be assigned when running in the editor environment.
var manifest_controller: FrameworkManifestController


func _init(
        framework_display_name: String,
        framework_addons_folder_name: String,
        auto_load_name: String,
        auto_load_deps: Array) -> void:
    self._framework_display_name = framework_display_name
    self._framework_addons_folder_name = framework_addons_folder_name
    self._auto_load_name = auto_load_name
    self._auto_load_deps = auto_load_deps


func _ready() -> void:
    _check_addons_directory()
    _start_polling_for_auto_load_deps()
    Sc.logger.on_global_init(self, _auto_load_name)
    Sc.register_framework_config(self)


func _on_auto_load_deps_ready() -> void:
    pass


func _amend_manifest(manifest: Dictionary) -> void:
    pass


func _register_manifest(manifest: Dictionary) -> void:
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
        emit_signal("registered")


func _set_initialized() -> void:
    if !is_initialized:
        is_initialized = true
        emit_signal("initialized")


func _check_addons_directory() -> void:
    if _framework_addons_folder_name != "":
        assert(self.get_script().resource_path.begins_with(
                    "res://addons/%s" % _framework_addons_folder_name),
                "%s must be located in your project's 'addons' directory." % \
                    _framework_display_name)


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
        remove_child(timer)
        _on_auto_load_deps_ready()
        _set_registered()
    else:
        # An AutoLoad dependency is missing.
        var i: int = timer.get_meta("i")
        var timer_count := _DEP_FAIL_DURATION / _DEP_CHECK_INTERVAL
        if i >= timer_count:
            push_error(("Framework AutoLoad dependency is missing: %s=>%s") % [
                        _auto_load_name,
                        missing_dep_name,
                    ])
            remove_child(timer)
        else:
            timer.set_meta("i", i + 1)
            timer.start()


func _get_missing_auto_load_dep_name() -> String:
    for auto_load_dep in _auto_load_deps:
        if !has_node("/root/" + auto_load_dep):
            return auto_load_dep
    return ""

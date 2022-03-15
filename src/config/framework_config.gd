tool
class_name FrameworkConfig
extends Node


signal initialized

var is_initialized := false

# NOTE: This will only be assigned when running in the editor environment.
var manifest_controller: FrameworkManifestController


func _amend_app_manifest(manifest: Dictionary) -> void:
    pass


func _register_app_manifest(manifest: Dictionary) -> void:
    pass


func _instantiate_sub_modules() -> void:
    pass


func _configure_sub_modules() -> void:
    pass


func _load_state() -> void:
    pass


func _set_initialized() -> void:
    if !is_initialized:
        is_initialized = true
        emit_signal("initialized")

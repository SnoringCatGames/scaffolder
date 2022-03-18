tool
class_name ScaffolderPlugin
extends FrameworkPlugin


# FIXME: ---------------------------------
# - Refactor Sc manifest and AutoLoad configuration to work with the plugin flow.


const _DISPLAY_NAME := "Scaffolder"
# FIXME: ----------------------
const _ICON_DIRECTORY_PATH := "res://addons/scaffolder/assets/images/"
const _AUTO_LOAD_NAME := "Sc"
const _AUTO_LOAD_PATH := "res://addons/scaffolder/src/config/sc.gd"
# FIXME: ----------------------
# - Make this be the framework-agnostic container panel.
# - Then have this panel dynamically create accordion panels for each
#   frameworks' manifest schema.
const _MAIN_PANEL_SCENE := \
        preload("res://addons/surface_tiler/src/plugin/surface_tiler_main_panel.tscn")


func _init().(
        _DISPLAY_NAME,
        _ICON_DIRECTORY_PATH,
        _AUTO_LOAD_NAME,
        _AUTO_LOAD_PATH) -> void:
    pass


func _set_up() -> void:
    ._set_up()
    
    if !_get_is_ready():
        return
    
    if !is_instance_valid(_auto_load.manifest_controller):
        _auto_load.manifest_controller = FrameworkManifestController.new()
        _auto_load.manifest_controller.set_up(SurfaceTilerManifestSchema.new())
        
        # FIXME: --------------------- REMOVE
        _auto_load._register_manifest_TMP(_auto_load.manifest)
    
    _main_panel = _MAIN_PANEL_SCENE.instance()
    get_editor_interface().get_editor_viewport().add_child(_main_panel)
    
    make_visible(false)


func _exit_tree() -> void:
    if is_instance_valid(_main_panel):
        _main_panel.queue_free()


func has_main_screen() -> bool:
    return true


func make_visible(visible: bool) -> void:
    if is_instance_valid(_main_panel):
        _main_panel.visible = visible

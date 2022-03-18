tool
class_name ScaffolderPlugin
extends FrameworkPlugin


const _SCHEMA_CLASS := SquirrelAwayManifestSchema

const _MAIN_PANEL_SCENE := preload(
        "res://addons/scaffolder/src/plugin/scaffolder_plugin_main_panel.tscn")

var _main_panel: ScaffolderPluginMainPanel


func _init().(_SCHEMA_CLASS) -> void:
    pass


func _set_up() -> void:
    ._set_up()
    
    if !_get_is_ready():
        return
    
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

tool
class_name ScaffolderPlugin
extends FrameworkPlugin


const _METADATA_SCRIPT := ScaffolderMetadata

const _TAB_LABEL := "Configuration"
const _TAB_ICON_PATH_PREFIX := \
        "res://addons/scaffolder/addons/plugger/assets/images/plugger"

const _CORNER_MATCH_TILEMAP_INSPECTOR_PLUGIN := preload(
        "res://addons/scaffolder/src/plugin/color_config_inspector_plugin.gd")

var _corner_match_tilemap_inspector_plugin


func _init().(_METADATA_SCRIPT) -> void:
    pass


func _set_up() -> void:
    ._set_up()
    
    Pl._set_up()
    
    assert(!is_instance_valid(_corner_match_tilemap_inspector_plugin))
    _corner_match_tilemap_inspector_plugin = \
            _CORNER_MATCH_TILEMAP_INSPECTOR_PLUGIN.new()
    add_inspector_plugin(_corner_match_tilemap_inspector_plugin)
    
    make_visible(false)


func _exit_tree() -> void:
    if is_instance_valid(Pl):
        Pl._destroy()
    remove_inspector_plugin(_corner_match_tilemap_inspector_plugin)


func has_main_screen() -> bool:
    return true


func make_visible(visible: bool) -> void:
    if is_instance_valid(Pl):
        Pl.make_visible(visible)


func get_plugin_name() -> String:
    return _TAB_LABEL


func get_plugin_icon() -> Texture:
    return PlInterface._static_get_icon(
            _TAB_ICON_PATH_PREFIX,
            get_editor_interface())

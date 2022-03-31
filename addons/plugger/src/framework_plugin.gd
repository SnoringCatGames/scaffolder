tool
class_name FrameworkPlugin
extends EditorPlugin


# FIXME: LEFT OFF HERE: --------------
# 
# - Update schema defaults to not include squirrel-away-specific state.
#   - And update squirrel-away metadata and GDScript overrides to include it!
# 
# - Search in each repo to make sure there are no references to other addons/
#   directories that there shouldn't be.
# 
# - Add a new release_mode: recording
#   - Disable HUDs and inspector.
#   - Disable debug panel.
#   - Disable music.
#   - Enable SFX.
#   - Set fullscreen.
# 
# - Search for FIXME in surface_tiler.
# 
# - Add support for coloring rows that aren't strictly overridden.
#   - For highlighting without assigning values overrides, just include a fourth
#      element in the array as false, and ignore the second element.
# - Also color ancestor rows?
#   - Maybe more faintly.
# 
# - Pl.get_editor_icon("Pin")
# 
# - In order to support pinned manifest entries:
#   - Include an array of property-path strings in each schema constructor.
#     - I could use an inline special-token key within schema Dictionaries, but 
#       then I wouldn't have control over the ordering of pinned items.
# 
# - For pinning, do go ahead and add support for dynamic pinning now:
#   - Just need to add a button at the right side of each row.
#   - Then each node can have an is_pinned property
#   - Then, can save all pinnings in a separate json, and in a separate save
#     pass
#   - Recreate the entire pin tree when a new pin is added or removed
#   - Will need to include all parents of a pinned row.
# 
# - Add the ability to pin important properties:
#   - Include defaults:
#     - scaffolder.images_manifest:
#        app_logo = preload("res://addons/squirrel_away/assets/images/logo.png"),
#        app_logo_scale = 1.0,
#        developer_logo = preload( \
#            "res://addons/scaffolder/assets/images/logos/snoring_cat_logo_about.png"),
#        developer_splash = preload( \
#            "res://addons/scaffolder/assets/images/logos/snoring_cat_logo_splash.png"),
#        go_normal = preload( \
#                "res://addons/squirrel_away/assets/images/gui/go_icon.png"),
#        go_scale = 1.5,
#     - _gui_manifest
#     - _default_welcome_panel_manifest
#     - 
#     - 
#     - 
#     - 
#   - Have each schema define its own default pins.
# - Show pinned properties in a separate panel at the top.
#   - Create a new pin icon.
#   - Don't support modifying pins through the UI for now.
#   - Do support overriding pins through GDScript though.
# 
# - Add a button for resetting frameworks within the editor.
# 
# - Add a button for resetting all global manifest and autoload state.
# 
# - Add a debug util for annotating GUIs:
#   - Simply call Sc.utils.highlight_node_for_debugging(node)
#     - If control, highlight boundary.
#     - If node, highlight position.
#   - Render a rectangle over bounds.
#   - Render crosshair for position.
#   - Continue lines and rectangle edges out to edge of viewport.
# 

const _PLUGGER_AUTO_LOAD_NAME := "Pl"
const _PLUGGER_AUTO_LOAD_PATH := \
        "res://addons/scaffolder/addons/plugger/src/pl.gd"

var _metadata: FrameworkMetadata

var _auto_load
var _sc_auto_load
var Pl

var _is_ready := false
var _is_set_up := false


func _init(framework_metadata_script: Script) -> void:
    self._metadata = framework_metadata_script.new()


func _ready() -> void:
    _is_ready = true
    _create_auto_load()
    _check_set_up()


func _get_is_ready() -> bool:
    return _is_ready and \
            is_inside_tree() and \
            is_instance_valid(_auto_load) and \
            _auto_load.is_initialized


func _create_auto_load() -> void:
    add_autoload_singleton(_metadata.auto_load_name, _metadata.auto_load_path)
    add_autoload_singleton(_PLUGGER_AUTO_LOAD_NAME, _PLUGGER_AUTO_LOAD_PATH)
    call_deferred("_connect_auto_load")


func _connect_auto_load() -> void:
    var auto_load_node_path := "/root/" + _metadata.auto_load_name
    if has_node(auto_load_node_path):
        self._auto_load = get_node(auto_load_node_path)
        _auto_load.connect("initialized", self, "_on_framework_initialized")
    
    var pl_node_path := "/root/" + _PLUGGER_AUTO_LOAD_NAME
    if has_node(pl_node_path):
        Pl = get_node(pl_node_path)
        Pl.editor = get_editor_interface()
        Pl.validate_icons(_metadata.plugin_icon_path_prefix)
    
    if is_instance_valid(self._auto_load) and \
            is_instance_valid(Pl):
        if _auto_load.is_initialized:
            _on_framework_initialized()


func _on_framework_initialized() -> void:
    _sc_auto_load = get_node("/root/Sc")
    Pl._sc_auto_load = _sc_auto_load
    _check_set_up()


func _enter_tree() -> void:
    _connect_auto_load()
    _check_set_up()


func _check_set_up() -> void:
    if _get_is_ready() and !_is_set_up:
        _is_set_up = true
        _sc_auto_load.register_framework_plugin(self)
        _set_up()


func _set_up() -> void:
    pass


func get_plugin_name() -> String:
    return _metadata.display_name


func get_plugin_icon() -> Texture:
    return PlInterface._static_get_icon(
            _metadata.plugin_icon_path_prefix,
            get_editor_interface())

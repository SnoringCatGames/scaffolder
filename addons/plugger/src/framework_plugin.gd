tool
class_name FrameworkPlugin
extends EditorPlugin


# FIXME: LEFT OFF HERE: ----------
# 
# - Implement the PropertyEditor widget for ColorConfig.
#   - Needs to work both in the inspector and in the Plugin main-screen.
# 
# - Implement new ColorConfig system.
# 
# - Add support for coloring rows that aren't strictly overridden.
# - Also color ancestor rows?
#   - Maybe more faintly.
# 
# - Update manifest.json files to only include non-default state.
#   - I need these to serve as a clear indication of what has actually been
#     changed by the user.
# 
# - Consolidate all manifest JSONs into one file, stored within the game
#   config/, rather than in addons.
# 
# - In order to support pinned manifest entries:
#   - Include an array of property-path strings in each schema constructor.
#     - I could use an inline special-token key within schema Dictionaries, but 
#       then I wouldn't have control over the ordering of pinned items.
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
# - Add TYPE_FONT.
# 
# - Add support for multi-line text-edit fields in manifest UI.
#   - Use this for anything that contains a newline in the default value.
# 
# - Add a button for resetting frameworks within the editor.
# 
# - Scan manifests to make sure I have support for all types I've previously
#   used.
# 
# - Port all legacy framework manifests to new pattern.
# 
# - Search for FIXME in plugger, surface_tiler, and also all other places.
# 
# 
# - Update schema defaults to not include squirrel-away-specific state.
# 
# - Search in each repo to make sure there are no references to other addons/
#   directories that there shouldn't be.
# 
# - Plan how to aggregate all the different plugins I now have in order to make
#   it easier for folks to use:
#   - 
# 
# - Add logic to adapt the main-screen content depending on which frameworks are present:
#   - If more than one, then show a tab list across the top for switching between them?
#   - List all framework manifest editors in a big vertical list with accordions
#     to collapse each framework.
#   - Create a manifest/config new icon for the main-screen tab.
#     - Just a simple settings-list/menu/horizontal-lines icon.
#   - Create clean icons for Scaffolder, Surfacer, SurfaceTiler, SurfaceParser,
#     Gooier, and game (use a simple star).
#     - Create the various different sizes and colors for each of these.
#     - Show these in the configuration-main-screen accordion headers for each
#       framework.
# - Add a button for resetting all global manifest and autoload state.
# - Refactor SurfaceTiler manifest to use the new plugin UI instead of GDScript
#   in SquirrelAway.
# - Create the multi-plugin scheme:
#   - Expect that Scaffolder will be the one core plugin that all the others depend upon.
#   - Expect that each individual plugin will register itself with Sc.
#   - Refactor things to work regardless of the order that AutoLoads are included.
#   - Expect that Scaffolder will force the order of plugin initialization to be as needed.
#     - Expect that each plugin will define a priority value.
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

var _metadata: PluginMetadata

var _auto_load
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
    _check_set_up()


func _enter_tree() -> void:
    _connect_auto_load()
    _check_set_up()


func _check_set_up() -> void:
    if _get_is_ready() and !_is_set_up:
        _is_set_up = true
        _set_up()


func _set_up() -> void:
    pass


func get_plugin_name() -> String:
    return _metadata.display_name


func get_plugin_icon() -> Texture:
    return PlInterface._static_get_icon(
            _metadata.plugin_icon_path_prefix,
            get_editor_interface())

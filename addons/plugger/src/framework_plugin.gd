tool
class_name FrameworkPlugin
extends EditorPlugin


# FIXME: LEFT OFF HERE: ---------------------------------------------
# 
# - Fix accordions.
# 
# - Fix the ability to specify an object type for an array child without
#   actually including it in the manifest by default.
# 
# - Fix main-screen panel width.
# 
# - Add support for different schema modes.
#     - ReleaseMode: local-dev vs playtest vs production
#     - AnnotationsMode: emphasized-annotations vs default
#     - SmoothnessMode: pixelated vs anti-aliased
#   - For each mode, define the collection of schema properties that are
#     configurable, and their default values.
#   - In the manifest's JSON file:
#     - Introduce new top-level sections:
#       main, release_mode, annotations_mode, smoothness_mode.
#     - In each mode section, only record the relevant properties for that mode.
#   - In the node tree:
#     - Introduce new top-level sections.
#     - Introduce corresponding new nodes under each mode-section branch.
#   - Add checkboxes at the top of the main panel (outside of any manifest
#     accordion) for toggling which mode we're in.
#     - Save the modes in another separate top-level section in the scaffolder
#       manifest JSON.
#     - When toggling a checkbox, update the values for all relevant controls.
#     - When editing a control value, only modify the property for the relevant
#       mode section.
#   - Render a special background color behind the mode checkbox+label and
#     behind all control-rows that are under the scope of the currently-selected
#     mode.
# 
# - Scan manifests to make sure I have support for all types I've previously
#   used.
# 
# - Don't port the manifests as a single framework all-at-once.
#   - Instead, port over the most significant and simple properties for each
#     framework first.
#   - Try to clear warnings/errors from concole.
# 
# - Plan the system for easily modding / overriding schemas as we do now:
#   - Should always override any preexisting values stored in json.
#   - Should save override values to json.
# 
# - Port all legacy framework manifests to new pattern.
# 
# - Test new MultiNumberEditor controls.
# 
# - Create plugin container system for rendering separate plugin manifest
#   editors within.
# 
# - Refactor main-panel to be generic for any plugin.
#   - Auto-open the last accordion registered (and close all others at that point).
# 
# - Convert old manifest stuff into new plugin-manifest structure.
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
#   - 

const _PLUGGER_AUTO_LOAD_NAME := "Pl"
const _PLUGGER_AUTO_LOAD_PATH := \
        "res://addons/scaffolder/addons/plugger/src/pl.gd"

var _metadata: PluginMetadata

var _auto_load
var Pl

var _is_ready := false


func _init(framework_metadata_script: Script) -> void:
    self._metadata = framework_metadata_script.new()


func _ready() -> void:
    _is_ready = true
    _create_auto_load()
    _set_up()


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
    self._auto_load = get_node("/root/" + _metadata.auto_load_name)
    _auto_load.connect("initialized", self, "_on_framework_initialized")
    
    Pl = get_node("/root/" + _PLUGGER_AUTO_LOAD_NAME)
    Pl.editor = get_editor_interface()
    Pl.validate_icons(
            _metadata.plugin_icon_directory_path + _metadata.folder_name)
    
    if _auto_load.is_initialized:
        _on_framework_initialized()


func _on_framework_initialized() -> void:
    _set_up()


func _enter_tree() -> void:
    _set_up()


func _set_up() -> void:
    if !_get_is_ready():
        return
    pass


func get_plugin_name() -> String:
    return _metadata.display_name


func get_plugin_icon() -> Texture:
    if is_instance_valid(Pl):
        return Pl.get_icon(
                _metadata.plugin_icon_directory_path + _metadata.folder_name)
    else:
        return null

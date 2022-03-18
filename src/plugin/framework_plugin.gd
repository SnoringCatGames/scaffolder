tool
class_name FrameworkPlugin
extends EditorPlugin


# FIXME: LEFT OFF HERE: -------------------------------------------
# - Create plugin container system for rendering separate plugin manifest
#   editors within.
# 
# - Registering:
#   - Include a new standard flow for getting framework manifest:
#     - Call controller.set_up() to instantiate the manifest.
# 
# - Refactor main-panel to be generic for any plugin.
#   - Auto-open the last accordion registered (and close all others at that point).
# 
# - Convert old manifest stuff into new plugin-manifest structure.
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

var _schema: FrameworkSchema
var _auto_load: FrameworkGlobal

var _is_ready := false


func _init(schema_class: Script) -> void:
    self._schema = Singletons.instance(schema_class)


func _ready() -> void:
    _is_ready = true
    _create_auto_load()
    _validate_editor_icons()
    _set_up()


func _get_is_ready() -> bool:
    return _is_ready and \
            is_inside_tree() and \
            is_instance_valid(_auto_load) and \
            _auto_load.is_initialized


func _create_auto_load() -> void:
    add_autoload_singleton(_schema.auto_load_name, _schema.auto_load_path)
    call_deferred("_connect_auto_load")


func _connect_auto_load() -> void:
    self._auto_load = get_node("/root/" + _schema.auto_load_name)
    _auto_load.connect("initialized", self, "_on_framework_initialized")
    if _auto_load.is_initialized:
        _on_framework_initialized()


func _on_framework_initialized() -> void:
    _set_up()


func _enter_tree() -> void:
    _set_up()


func _set_up() -> void:
    if !_get_is_ready():
        return
    
    if !is_instance_valid(_auto_load.manifest_controller):
        _auto_load.manifest_controller = \
                FrameworkManifestController.new(_auto_load.schema)
        
        # FIXME: --------------------- REMOVE
        _auto_load._register_manifest_TMP(_auto_load.manifest)


func get_plugin_name() -> String:
    return _schema.display_name


func get_plugin_icon() -> Texture:
    # TODO: We need better support for updating icon colors based on theme: 
    # https://github.com/godotengine/godot-proposals/issues/572
    var is_light_theme: bool = \
            get_editor_interface().get_editor_settings() \
                .get_setting("interface/theme/base_color").v > 0.5
    var theme := "light" if is_light_theme else "dark"
    var scale := get_editor_interface().get_editor_scale()
    var icon_path := _get_editor_icon_path(theme, scale)
    return load(icon_path) as Texture


func _validate_editor_icons() -> void:
    var file := File.new()
    for theme in ["light", "dark"]:
        for scale in [0.75, 1.0, 1.5, 2.0]:
            var path := _get_editor_icon_path(theme, scale)
            assert(file.file_exists(path),
                    "Plugin editor-icon version is missing: " +
                    "plugin=%s, theme=%s, scale=%s, path=%s" % [
                        _schema.display_name,
                        theme,
                        str(scale),
                        path,
                    ])


func _get_editor_icon_path(
        theme: String,
        scale: float) -> String:
    return ("%s%s_%s_theme_%s.png") % [
        _schema.plugin_icon_directory_path,
        _schema.folder_name,
        theme,
        str(scale),
    ]

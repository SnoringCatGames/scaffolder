tool
class_name PluginMetadata
extends Reference


var display_name: String
var folder_name: String
var auto_load_name: String
var auto_load_deps: Array
var auto_load_path: String
var plugin_icon_directory_path: String
var schema_path: String
var manifest_path: String


func _init(
        display_name: String,
        folder_name: String,
        auto_load_name: String,
        auto_load_deps: Array,
        auto_load_path: String,
        plugin_icon_directory_path: String,
        schema_path: String,
        manifest_path: String) -> void:
    self.display_name = display_name
    self.folder_name = folder_name
    self.auto_load_name = auto_load_name
    self.auto_load_deps = auto_load_deps
    self.auto_load_path = auto_load_path
    self.plugin_icon_directory_path = plugin_icon_directory_path
    self.schema_path = schema_path
    self.manifest_path = manifest_path


func get_editor_icon_path(
        theme := "dark",
        scale := 1.0) -> String:
    return ("%s%s_%s_theme_%s.png") % [
        self.plugin_icon_directory_path,
        self.folder_name,
        theme,
        str(scale),
    ]

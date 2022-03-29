tool
class_name PluginMetadata
extends Reference


var display_name: String
var folder_name: String
var auto_load_name: String
var auto_load_deps: Array
var auto_load_path: String
var plugin_icon_path_prefix: String
var schema_path: String
var manifest_path_override: String
var modes: Dictionary


func _init(
        display_name: String,
        folder_name: String,
        auto_load_name: String,
        auto_load_deps: Array,
        auto_load_path: String,
        plugin_icon_path_prefix: String,
        schema_path: String,
        manifest_path_override: String,
        modes: Dictionary) -> void:
    self.display_name = display_name
    self.folder_name = folder_name
    self.auto_load_name = auto_load_name
    self.auto_load_deps = auto_load_deps
    self.auto_load_path = auto_load_path
    self.plugin_icon_path_prefix = plugin_icon_path_prefix
    self.schema_path = schema_path
    self.manifest_path_override = manifest_path_override
    self.modes = modes

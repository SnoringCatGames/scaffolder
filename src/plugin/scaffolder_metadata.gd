tool
class_name ScaffolderMetadata
extends PluginMetadata


const DISPLAY_NAME := "Scaffolder"
const FOLDER_NAME := "scaffolder"
const AUTO_LOAD_NAME := "Sc"
const AUTO_LOAD_DEPS := []
const AUTO_LOAD_PATH := "res://addons/scaffolder/src/config/sc.gd"
const PLUGIN_ICON_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/editor_icons/plugin/scaffolder"
const SCHEMA_PATH := "res://addons/scaffolder/src/plugin/scaffolder_schema.gd"
const MANIFEST_PATH := "res://addons/scaffolder/src/config/manifest.json"

const PLUGIN_OPEN_ROWS_PATH := \
        "res://addons/scaffolder/src/config/plugin_open_rows.json"
const MODES_PATH := "res://addons/scaffolder/src/config/manifest_modes.json"
const DEFAULT_MODES := {
    FrameworkSchemaMode.RELEASE: \
            FrameworkSchemaMode.Release.LOCAL_DEV,
    FrameworkSchemaMode.THREADING: \
            FrameworkSchemaMode.Threading.DISABLED,
    FrameworkSchemaMode.ANNOTATIONS: \
            FrameworkSchemaMode.Annotations.DEFAULT,
    FrameworkSchemaMode.UI_SMOOTHNESS: \
            FrameworkSchemaMode.UiSmoothness.PIXELATED,
}


func _init().(
        DISPLAY_NAME,
        FOLDER_NAME,
        AUTO_LOAD_NAME,
        AUTO_LOAD_DEPS,
        AUTO_LOAD_PATH,
        PLUGIN_ICON_PATH_PREFIX,
        SCHEMA_PATH,
        MANIFEST_PATH) -> void:
    pass

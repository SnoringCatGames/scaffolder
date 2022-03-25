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
const MODES := {
    release = {
        options = ["local_dev", "playtest", "production"],
        default = "local_dev"
    },
    threading = {
        options = ["enabled", "disabled"],
        default = "disabled"
    },
    annotations = {
        options = ["default", "emphasized"],
        default = "default"
    },
    ui_smoothness = {
        options = ["pixelated", "anti_aliased"],
        default = "pixelated"
    },
}


func _init().(
        DISPLAY_NAME,
        FOLDER_NAME,
        AUTO_LOAD_NAME,
        AUTO_LOAD_DEPS,
        AUTO_LOAD_PATH,
        PLUGIN_ICON_PATH_PREFIX,
        SCHEMA_PATH,
        MANIFEST_PATH,
        MODES) -> void:
    pass

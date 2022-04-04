tool
class_name ScaffolderMetadata
extends FrameworkMetadata


const DISPLAY_NAME := "Scaffolder"
const FOLDER_NAME := "scaffolder"
const AUTO_LOAD_NAME := "Sc"
const AUTO_LOAD_DEPS := []
const AUTO_LOAD_PATH := "res://addons/scaffolder/src/global/sc.gd"
const PLUGIN_ICON_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/editor_icons/plugin/scaffolder"
const SCHEMA_PATH := "res://addons/scaffolder/src/config/scaffolder_schema.gd"
const MANIFEST_PATH_OVERRIDE := ""

const PLUGIN_OPEN_ROWS_PATH := \
        "res://addons/scaffolder/src/config/plugin_open_rows.json"
const MODES_PATH := "res://addons/scaffolder/src/global/manifest_modes.json"
const METRIC_KEYS := []
var MODES := {
    release = {
        options = ["local_dev", "playtest", "production", "recording"],
        default = "local_dev",
        color = Color.from_hsv(0.153, 0.85, 0.98, 1.0),
    },
    threading = {
        options = ["enabled", "disabled"],
        default = "disabled",
        color = Color.from_hsv(0.403, 0.85, 0.98, 1.0),
    },
    annotations = {
        options = ["default", "emphasized"],
        default = "default",
        color = Color.from_hsv(0.903, 0.85, 0.98, 1.0),
    },
    ui_smoothness = {
        options = ["pixelated", "anti_aliased"],
        default = "pixelated",
        color = Color.from_hsv(0.653, 0.7, 0.98, 1.0),
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
        MANIFEST_PATH_OVERRIDE,
        METRIC_KEYS,
        MODES) -> void:
    pass

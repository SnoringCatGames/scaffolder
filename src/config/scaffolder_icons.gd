class_name ScaffolderIcons
extends Node


# --- Constants ---

const DEFAULT_CHECKBOX_NORMAL_ICON_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/checkbox/checkbox_"
const DEFAULT_CHECKBOX_NORMAL_ICON_SIZE := 32
const DEFAULT_CHECKBOX_NORMAL_ICON_SIZES := [8, 16, 32, 64, 128]

const DEFAULT_CHECKBOX_PIXEL_ICON_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/checkbox_pixel/checkbox_"
const DEFAULT_CHECKBOX_PIXEL_ICON_SIZE := 32
const DEFAULT_CHECKBOX_PIXEL_ICON_SIZES := [8, 16, 32, 64, 128]

const DEFAULT_TREE_ARROW_NORMAL_ICON_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/tree_arrow/tree_arrow_"
const DEFAULT_TREE_ARROW_NORMAL_ICON_SIZE := 16
const DEFAULT_TREE_ARROW_NORMAL_ICON_SIZES := [8, 16, 32, 64]

const DEFAULT_TREE_ARROW_PIXEL_ICON_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/tree_arrow_pixel/tree_arrow_"
const DEFAULT_TREE_ARROW_PIXEL_ICON_SIZE := 16
const DEFAULT_TREE_ARROW_PIXEL_ICON_SIZES := [4, 8, 16, 32, 64, 128]

# --- Static configuration state ---

var checkbox_icon_path_prefix := DEFAULT_CHECKBOX_NORMAL_ICON_PATH_PREFIX
var default_checkbox_icon_size := DEFAULT_CHECKBOX_NORMAL_ICON_SIZE
var checkbox_icon_sizes := DEFAULT_CHECKBOX_NORMAL_ICON_SIZES

var tree_arrow_icon_path_prefix := DEFAULT_TREE_ARROW_NORMAL_ICON_PATH_PREFIX
var default_tree_arrow_icon_size := DEFAULT_TREE_ARROW_NORMAL_ICON_SIZE
var tree_arrow_icon_sizes := DEFAULT_TREE_ARROW_NORMAL_ICON_SIZES

# --- Derived configuration ---

# --- Global state ---

var current_checkbox_icon_size := default_checkbox_icon_size
var current_tree_arrow_icon_size := default_checkbox_icon_size

# ---


func _init() -> void:
    Gs.logger.on_global_init(self, "ScaffolderIcons")


func register_manifest(manifest: Dictionary) -> void:
    if manifest.has("checkbox_icon_path_prefix"):
        self.checkbox_icon_path_prefix = \
                manifest.checkbox_icon_path_prefix
    if manifest.has("default_checkbox_icon_size"):
        self.default_checkbox_icon_size = \
                manifest.default_checkbox_icon_size
    if manifest.has("checkbox_icon_sizes"):
        self.checkbox_icon_sizes = \
                manifest.checkbox_icon_sizes
    
    if manifest.has("tree_arrow_icon_path_prefix"):
        self.tree_arrow_icon_path_prefix = \
                manifest.tree_arrow_icon_path_prefix
    if manifest.has("default_tree_arrow_icon_size"):
        self.default_tree_arrow_icon_size = \
                manifest.default_tree_arrow_icon_size
    if manifest.has("tree_arrow_icon_sizes"):
        self.tree_arrow_icon_sizes = \
                manifest.tree_arrow_icon_sizes

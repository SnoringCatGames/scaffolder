class_name ScaffolderIcons
extends Node


# --- Constants ---

const ABOUT_CIRCLE_ACTIVE_PATH := \
        "res://addons/scaffolder/assets/images/gui/about_circle_active.png"
const ABOUT_CIRCLE_HOVER_PATH := \
        "res://addons/scaffolder/assets/images/gui/about_circle_hover.png"
const ABOUT_CIRCLE_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/about_circle_normal.png"

const ALERT_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/alert_normal.png"

const CLOSE_ACTIVE_PATH := \
        "res://addons/scaffolder/assets/images/gui/close_active.png"
const CLOSE_HOVER_PATH := \
        "res://addons/scaffolder/assets/images/gui/close_hover.png"
const CLOSE_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/close_normal.png"

const GEAR_CIRCLE_ACTIVE_PATH := \
        "res://addons/scaffolder/assets/images/gui/gear_circle_active.png"
const GEAR_CIRCLE_HOVER_PATH := \
        "res://addons/scaffolder/assets/images/gui/gear_circle_hover.png"
const GEAR_CIRCLE_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/gear_circle_normal.png"

const GO_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/go_normal.png"

const HOME_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/home_normal.png"

const LEFT_CARET_ACTIVE_PATH := \
        "res://addons/scaffolder/assets/images/gui/left_caret_active.png"
const LEFT_CARET_HOVER_PATH := \
        "res://addons/scaffolder/assets/images/gui/left_caret_hover.png"
const LEFT_CARET_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/left_caret_normal.png"

const PAUSE_CIRCLE_ACTIVE_PATH := \
        "res://addons/scaffolder/assets/images/gui/pause_circle_active.png"
const PAUSE_CIRCLE_HOVER_PATH := \
        "res://addons/scaffolder/assets/images/gui/pause_circle_hover.png"
const PAUSE_CIRCLE_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/pause_circle_normal.png"

const PAUSE_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/pause_normal.png"

const PLAY_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/play_normal.png"

const RETRY_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/retry_normal.png"

const STOP_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/stop_normal.png"

const DEFAULT_CHECKBOX_NORMAL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/checkbox/checkbox_"
const DEFAULT_CHECKBOX_NORMAL_SIZE := 32
const DEFAULT_CHECKBOX_NORMAL_SIZES := [8, 16, 32, 64, 128]

const DEFAULT_CHECKBOX_PIXEL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/checkbox_pixel/checkbox_"
const DEFAULT_CHECKBOX_PIXEL_SIZE := 32
const DEFAULT_CHECKBOX_PIXEL_SIZES := [8, 16, 32, 64, 128]

const DEFAULT_TREE_ARROW_NORMAL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/tree_arrow/tree_arrow_"
const DEFAULT_TREE_ARROW_NORMAL_SIZE := 16
const DEFAULT_TREE_ARROW_NORMAL_SIZES := [8, 16, 32, 64]

const DEFAULT_TREE_ARROW_PIXEL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/tree_arrow_pixel/tree_arrow_"
const DEFAULT_TREE_ARROW_PIXEL_SIZE := 16
const DEFAULT_TREE_ARROW_PIXEL_SIZES := [4, 8, 16, 32, 64, 128]

# --- Static configuration state ---

var about_circle_active: Texture
var about_circle_hover: Texture
var about_circle_normal: Texture

var alert_normal: Texture

var close_active: Texture
var close_hover: Texture
var close_normal: Texture

var gear_circle_active: Texture
var gear_circle_hover: Texture
var gear_circle_normal: Texture

var go_normal: Texture
var go_scale := 1.0

var home_normal: Texture

var left_caret_active: Texture
var left_caret_hover: Texture
var left_caret_normal: Texture

var pause_circle_active: Texture
var pause_circle_hover: Texture
var pause_circle_normal: Texture

var pause_normal: Texture

var play_normal: Texture

var retry_normal: Texture

var stop_normal: Texture

var checkbox_path_prefix := DEFAULT_CHECKBOX_NORMAL_PATH_PREFIX
var default_checkbox_size := DEFAULT_CHECKBOX_NORMAL_SIZE
var checkbox_sizes := DEFAULT_CHECKBOX_NORMAL_SIZES

var tree_arrow_path_prefix := DEFAULT_TREE_ARROW_NORMAL_PATH_PREFIX
var default_tree_arrow_size := DEFAULT_TREE_ARROW_NORMAL_SIZE
var tree_arrow_sizes := DEFAULT_TREE_ARROW_NORMAL_SIZES

# --- Derived configuration ---

# --- Global state ---

var current_checkbox_size := default_checkbox_size
var current_tree_arrow_size := default_checkbox_size

# ---


func _init() -> void:
    Gs.logger.on_global_init(self, "ScaffolderIcons")


func register_manifest(manifest: Dictionary) -> void:
    if manifest.has("about_circle_active"):
        self.about_circle_active = manifest.about_circle_active
    else:
        self.about_circle_active = load(ABOUT_CIRCLE_ACTIVE_PATH)
    if manifest.has("about_circle_hover"):
        self.about_circle_hover = manifest.about_circle_hover
    else:
        self.about_circle_hover = load(ABOUT_CIRCLE_HOVER_PATH)
    if manifest.has("about_circle_normal"):
        self.about_circle_normal = manifest.about_circle_normal
    else:
        self.about_circle_normal = load(ABOUT_CIRCLE_NORMAL_PATH)
    
    if manifest.has("alert_normal"):
        self.alert_normal = manifest.alert_normal
    else:
        self.alert_normal = load(ALERT_NORMAL_PATH)
    
    if manifest.has("close_active"):
        self.close_active = manifest.close_active
    else:
        self.close_active = load(CLOSE_ACTIVE_PATH)
    if manifest.has("close_hover"):
        self.close_hover = manifest.close_hover
    else:
        self.close_hover = load(CLOSE_HOVER_PATH)
    if manifest.has("close_normal"):
        self.close_normal = manifest.close_normal
    else:
        self.close_normal = load(CLOSE_NORMAL_PATH)
    
    if manifest.has("gear_circle_active"):
        self.gear_circle_active = manifest.gear_circle_active
    else:
        self.gear_circle_active = load(GEAR_CIRCLE_ACTIVE_PATH)
    if manifest.has("gear_circle_hover"):
        self.gear_circle_hover = manifest.gear_circle_hover
    else:
        self.gear_circle_hover = load(GEAR_CIRCLE_HOVER_PATH)
    if manifest.has("gear_circle_normal"):
        self.gear_circle_normal = manifest.gear_circle_normal
    else:
        self.gear_circle_normal = load(GEAR_CIRCLE_NORMAL_PATH)
    
    if manifest.has("go_normal"):
        self.go_normal = manifest.go_normal
    else:
        self.go_normal = load(GO_NORMAL_PATH)
    if manifest.has("go_scale"):
        self.go_scale = manifest.go_scale
    
    if manifest.has("home_normal"):
        self.home_normal = manifest.home_normal
    else:
        self.home_normal = load(HOME_NORMAL_PATH)
    
    if manifest.has("left_caret_active"):
        self.left_caret_active = manifest.left_caret_active
    else:
        self.left_caret_active = load(LEFT_CARET_ACTIVE_PATH)
    if manifest.has("left_caret_hover"):
        self.left_caret_hover = manifest.left_caret_hover
    else:
        self.left_caret_hover = load(LEFT_CARET_HOVER_PATH)
    if manifest.has("left_caret_normal"):
        self.left_caret_normal = manifest.left_caret_normal
    else:
        self.left_caret_normal = load(LEFT_CARET_NORMAL_PATH)
    
    if manifest.has("pause_circle_active"):
        self.pause_circle_active = manifest.pause_circle_active
    else:
        self.pause_circle_active = load(PAUSE_CIRCLE_ACTIVE_PATH)
    if manifest.has("pause_circle_hover"):
        self.pause_circle_hover = manifest.pause_circle_hover
    else:
        self.pause_circle_hover = load(PAUSE_CIRCLE_HOVER_PATH)
    if manifest.has("pause_circle_normal"):
        self.pause_circle_normal = manifest.pause_circle_normal
    else:
        self.pause_circle_normal = load(PAUSE_CIRCLE_NORMAL_PATH)
    
    if manifest.has("pause_normal"):
        self.pause_normal = manifest.pause_normal
    else:
        self.pause_normal = load(PAUSE_NORMAL_PATH)
    
    if manifest.has("play_normal"):
        self.play_normal = manifest.play_normal
    else:
        self.play_normal = load(PLAY_NORMAL_PATH)
    
    if manifest.has("retry_normal"):
        self.retry_normal = manifest.retry_normal
    else:
        self.retry_normal = load(RETRY_NORMAL_PATH)
    
    if manifest.has("stop_normal"):
        self.stop_normal = manifest.stop_normal
    else:
        self.stop_normal = load(STOP_NORMAL_PATH)
    
    if manifest.has("checkbox_path_prefix"):
        self.checkbox_path_prefix = \
                manifest.checkbox_path_prefix
    if manifest.has("default_checkbox_size"):
        self.default_checkbox_size = \
                manifest.default_checkbox_size
    if manifest.has("checkbox_sizes"):
        self.checkbox_sizes = \
                manifest.checkbox_sizes
    
    if manifest.has("tree_arrow_path_prefix"):
        self.tree_arrow_path_prefix = \
                manifest.tree_arrow_path_prefix
    if manifest.has("default_tree_arrow_size"):
        self.default_tree_arrow_size = \
                manifest.default_tree_arrow_size
    if manifest.has("tree_arrow_sizes"):
        self.tree_arrow_sizes = \
                manifest.tree_arrow_sizes

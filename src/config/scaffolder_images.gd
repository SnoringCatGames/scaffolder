tool
class_name ScaffolderImages
extends Node


# --- Constants ---

const SCAFFOLDER_LOGO_PATH := \
        "res://addons/scaffolder/assets/images/logos/scaffolder_logo.png"

const GO_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/go_normal.png"

const SNORING_CAT_LOGO_PATH := \
        "res://addons/scaffolder/assets/images/logos/snoring_cat_logo_about.png"
const SNORING_CAT_SPLASH_PATH := \
        "res://addons/scaffolder/assets/images/logos/snoring_cat_logo_splash.png"

const GODOT_LOGO_PATH := \
        "res://addons/scaffolder/assets/images/logos/godot_logo_about.png"
const GODOT_SPLASH_PATH := \
        "res://addons/scaffolder/assets/images/logos/godot_logo_splash.png"

const GITHUB_LOGO_PATH := \
        "res://addons/scaffolder/assets/images/logos/github_logo_about.png"

const ABOUT_CIRCLE_PRESSED_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/about_circle_pressed.png"
const ABOUT_CIRCLE_HOVER_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/about_circle_hover.png"
const ABOUT_CIRCLE_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/about_circle_normal.png"

const ALERT_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/alert_normal.png"

const CLOSE_PRESSED_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/close_pressed.png"
const CLOSE_HOVER_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/close_hover.png"
const CLOSE_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/close_normal.png"

const GEAR_CIRCLE_PRESSED_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/gear_circle_pressed.png"
const GEAR_CIRCLE_HOVER_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/gear_circle_hover.png"
const GEAR_CIRCLE_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/gear_circle_normal.png"

const HOME_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/home_normal.png"

const LEFT_CARET_PRESSED_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/left_caret_pressed.png"
const LEFT_CARET_HOVER_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/left_caret_hover.png"
const LEFT_CARET_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/left_caret_normal.png"

const PAUSE_CIRCLE_PRESSED_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/pause_circle_pressed.png"
const PAUSE_CIRCLE_HOVER_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/pause_circle_hover.png"
const PAUSE_CIRCLE_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/pause_circle_normal.png"

const PAUSE_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/pause_normal.png"

const PLAY_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/play_normal.png"

const RETRY_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/retry_normal.png"

const STOP_NORMAL_PATH := \
        "res://addons/scaffolder/assets/images/gui/icons/stop_normal.png"

const DEFAULT_CHECKBOX_NORMAL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/checkbox/checkbox_"
const DEFAULT_CHECKBOX_NORMAL_SIZE := 32
const DEFAULT_CHECKBOX_NORMAL_SIZES := [8, 16, 32, 64, 128]

const DEFAULT_CHECKBOX_PIXEL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/checkbox_pixel/checkbox_"
const DEFAULT_CHECKBOX_PIXEL_SIZE := 32
const DEFAULT_CHECKBOX_PIXEL_SIZES := [8, 16, 32, 64, 128]

const DEFAULT_RADIO_BUTTON_NORMAL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/radio_button/radio_button_"
const DEFAULT_RADIO_BUTTON_NORMAL_SIZE := 32
const DEFAULT_RADIO_BUTTON_NORMAL_SIZES := [16, 32, 64, 128]

const DEFAULT_RADIO_BUTTON_PIXEL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/radio_button_pixel/radio_button_"
const DEFAULT_RADIO_BUTTON_PIXEL_SIZE := 40
# These sizes don't include a margin.
#const DEFAULT_RADIO_BUTTON_PIXEL_SIZES := [8, 16, 32, 64, 128]
# These sizes include a margin.
const DEFAULT_RADIO_BUTTON_PIXEL_SIZES := [10, 20, 40, 80, 160]

const DEFAULT_TREE_ARROW_NORMAL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/tree_arrow/tree_arrow_"
const DEFAULT_TREE_ARROW_NORMAL_SIZE := 16
const DEFAULT_TREE_ARROW_NORMAL_SIZES := [8, 16, 32, 64]

const DEFAULT_TREE_ARROW_PIXEL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/tree_arrow_pixel/tree_arrow_"
const DEFAULT_TREE_ARROW_PIXEL_SIZE := 16
const DEFAULT_TREE_ARROW_PIXEL_SIZES := [4, 8, 16, 32, 64, 128]

const DEFAULT_DROPDOWN_ARROW_NORMAL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/dropdown_arrow/dropdown_arrow_"
const DEFAULT_DROPDOWN_ARROW_NORMAL_SIZE := 32
const DEFAULT_DROPDOWN_ARROW_NORMAL_SIZES := [16, 32, 64, 128]

const DEFAULT_DROPDOWN_ARROW_PIXEL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/dropdown_arrow_pixel/dropdown_arrow_"
const DEFAULT_DROPDOWN_ARROW_PIXEL_SIZE := 20
const DEFAULT_DROPDOWN_ARROW_PIXEL_SIZES := [5, 10, 20, 40, 80]

const DEFAULT_SLIDER_GRABBER_NORMAL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/slider/slider_grabber_"
const DEFAULT_SLIDER_GRABBER_NORMAL_SIZE := 16
const DEFAULT_SLIDER_GRABBER_NORMAL_SIZES := [8, 16, 32, 64]

const DEFAULT_SLIDER_GRABBER_PIXEL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/slider_pixel/slider_grabber_"
const DEFAULT_SLIDER_GRABBER_PIXEL_SIZE := 16
const DEFAULT_SLIDER_GRABBER_PIXEL_SIZES := [4, 8, 16, 32, 64]

const DEFAULT_SLIDER_TICK_NORMAL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/slider/slider_tick_"
const DEFAULT_SLIDER_TICK_NORMAL_SIZE := 2
const DEFAULT_SLIDER_TICK_NORMAL_SIZES := [1, 2, 3, 4]

const DEFAULT_SLIDER_TICK_PIXEL_PATH_PREFIX := \
        "res://addons/scaffolder/assets/images/gui/slider_pixel/slider_tick_"
const DEFAULT_SLIDER_TICK_PIXEL_SIZE := 4
const DEFAULT_SLIDER_TICK_PIXEL_SIZES := [1, 2, 4, 8, 16]

const BLACK_PIXEL_PATH := \
        "res://addons/scaffolder/assets/images/misc/black_pixel.png"
const WHITE_PIXEL_PATH := \
        "res://addons/scaffolder/assets/images/misc/white_pixel.png"
const TRANSPARENT_PIXEL_PATH := \
        "res://addons/scaffolder/assets/images/misc/transparent_pixel.png"

# --- Static configuration state ---

var app_logo: Texture
var app_logo_scale: float

var developer_logo: Texture
var developer_splash: Texture

var godot_logo := preload(GODOT_LOGO_PATH)
var godot_splash := preload(GODOT_SPLASH_PATH)

var github_logo := preload(GITHUB_LOGO_PATH)

var go_normal: Texture
var go_scale := 1.0

var about_circle_pressed: Texture
var about_circle_hover: Texture
var about_circle_normal: Texture

var alert_normal: Texture

var close_pressed: Texture
var close_hover: Texture
var close_normal: Texture

var gear_circle_pressed: Texture
var gear_circle_hover: Texture
var gear_circle_normal: Texture

var home_normal: Texture

var left_caret_pressed: Texture
var left_caret_hover: Texture
var left_caret_normal: Texture

var pause_circle_pressed: Texture
var pause_circle_hover: Texture
var pause_circle_normal: Texture

var pause_normal: Texture

var play_normal: Texture

var retry_normal: Texture

var stop_normal: Texture

var checkbox_path_prefix := DEFAULT_CHECKBOX_NORMAL_PATH_PREFIX
var default_checkbox_size := DEFAULT_CHECKBOX_NORMAL_SIZE
var checkbox_sizes := DEFAULT_CHECKBOX_NORMAL_SIZES

var radio_button_path_prefix := DEFAULT_RADIO_BUTTON_NORMAL_PATH_PREFIX
var default_radio_button_size := DEFAULT_RADIO_BUTTON_NORMAL_SIZE
var radio_button_sizes := DEFAULT_RADIO_BUTTON_NORMAL_SIZES

var tree_arrow_path_prefix := DEFAULT_TREE_ARROW_NORMAL_PATH_PREFIX
var default_tree_arrow_size := DEFAULT_TREE_ARROW_NORMAL_SIZE
var tree_arrow_sizes := DEFAULT_TREE_ARROW_NORMAL_SIZES

var dropdown_arrow_path_prefix := DEFAULT_DROPDOWN_ARROW_NORMAL_PATH_PREFIX
var default_dropdown_arrow_size := DEFAULT_DROPDOWN_ARROW_NORMAL_SIZE
var dropdown_arrow_sizes := DEFAULT_DROPDOWN_ARROW_NORMAL_SIZES

var slider_grabber_path_prefix := DEFAULT_SLIDER_GRABBER_NORMAL_PATH_PREFIX
var default_slider_grabber_size := DEFAULT_SLIDER_GRABBER_NORMAL_SIZE
var slider_grabber_sizes := DEFAULT_SLIDER_GRABBER_NORMAL_SIZES

var slider_tick_path_prefix := DEFAULT_SLIDER_TICK_NORMAL_PATH_PREFIX
var default_slider_tick_size := DEFAULT_SLIDER_TICK_NORMAL_SIZE
var slider_tick_sizes := DEFAULT_SLIDER_TICK_NORMAL_SIZES

# --- Derived configuration ---

# --- Global state ---

var current_checkbox_size := default_checkbox_size
var current_radio_button_size := default_radio_button_size
var current_tree_arrow_size := default_tree_arrow_size
var current_dropdown_arrow_size := default_dropdown_arrow_size
var current_slider_grabber_size := default_slider_grabber_size
var current_slider_tick_size := default_slider_tick_size

# ---


func _init() -> void:
    Sc.logger.on_global_init(self, "ScaffolderImages")


func _parse_manifest(manifest: Dictionary) -> void:
    if manifest.has("app_logo"):
        self.app_logo = manifest.app_logo
    else:
        self.app_logo = load(SCAFFOLDER_LOGO_PATH)
    if manifest.has("app_logo_scale"):
        self.app_logo_scale = manifest.app_logo_scale
    
    if manifest.has("developer_logo"):
        self.developer_logo = manifest.developer_logo
    else:
        self.developer_logo = load(SNORING_CAT_LOGO_PATH)
    if manifest.has("developer_splash"):
        self.developer_splash = manifest.developer_splash
    else:
        self.developer_splash = load(SNORING_CAT_SPLASH_PATH)
    
    if manifest.has("go_normal"):
        self.go_normal = manifest.go_normal
    else:
        self.go_normal = load(GO_NORMAL_PATH)
    if manifest.has("go_scale"):
        self.go_scale = manifest.go_scale
    
    if manifest.has("about_circle_pressed"):
        self.about_circle_pressed = manifest.about_circle_pressed
    else:
        self.about_circle_pressed = load(ABOUT_CIRCLE_PRESSED_PATH)
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
    
    if manifest.has("close_pressed"):
        self.close_pressed = manifest.close_pressed
    else:
        self.close_pressed = load(CLOSE_PRESSED_PATH)
    if manifest.has("close_hover"):
        self.close_hover = manifest.close_hover
    else:
        self.close_hover = load(CLOSE_HOVER_PATH)
    if manifest.has("close_normal"):
        self.close_normal = manifest.close_normal
    else:
        self.close_normal = load(CLOSE_NORMAL_PATH)
    
    if manifest.has("gear_circle_pressed"):
        self.gear_circle_pressed = manifest.gear_circle_pressed
    else:
        self.gear_circle_pressed = load(GEAR_CIRCLE_PRESSED_PATH)
    if manifest.has("gear_circle_hover"):
        self.gear_circle_hover = manifest.gear_circle_hover
    else:
        self.gear_circle_hover = load(GEAR_CIRCLE_HOVER_PATH)
    if manifest.has("gear_circle_normal"):
        self.gear_circle_normal = manifest.gear_circle_normal
    else:
        self.gear_circle_normal = load(GEAR_CIRCLE_NORMAL_PATH)
    
    if manifest.has("home_normal"):
        self.home_normal = manifest.home_normal
    else:
        self.home_normal = load(HOME_NORMAL_PATH)
    
    if manifest.has("left_caret_pressed"):
        self.left_caret_pressed = manifest.left_caret_pressed
    else:
        self.left_caret_pressed = load(LEFT_CARET_PRESSED_PATH)
    if manifest.has("left_caret_hover"):
        self.left_caret_hover = manifest.left_caret_hover
    else:
        self.left_caret_hover = load(LEFT_CARET_HOVER_PATH)
    if manifest.has("left_caret_normal"):
        self.left_caret_normal = manifest.left_caret_normal
    else:
        self.left_caret_normal = load(LEFT_CARET_NORMAL_PATH)
    
    if manifest.has("pause_circle_pressed"):
        self.pause_circle_pressed = manifest.pause_circle_pressed
    else:
        self.pause_circle_pressed = load(PAUSE_CIRCLE_PRESSED_PATH)
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
    
    if manifest.has("radio_button_path_prefix"):
        self.radio_button_path_prefix = \
                manifest.radio_button_path_prefix
    if manifest.has("default_radio_button_size"):
        self.default_radio_button_size = \
                manifest.default_radio_button_size
    if manifest.has("radio_button_sizes"):
        self.radio_button_sizes = \
                manifest.radio_button_sizes
    
    if manifest.has("tree_arrow_path_prefix"):
        self.tree_arrow_path_prefix = \
                manifest.tree_arrow_path_prefix
    if manifest.has("default_tree_arrow_size"):
        self.default_tree_arrow_size = \
                manifest.default_tree_arrow_size
    if manifest.has("tree_arrow_sizes"):
        self.tree_arrow_sizes = \
                manifest.tree_arrow_sizes
    
    if manifest.has("dropdown_arrow_path_prefix"):
        self.dropdown_arrow_path_prefix = \
                manifest.dropdown_arrow_path_prefix
    if manifest.has("default_dropdown_arrow_size"):
        self.default_dropdown_arrow_size = \
                manifest.default_dropdown_arrow_size
    if manifest.has("dropdown_arrow_sizes"):
        self.dropdown_arrow_sizes = \
                manifest.dropdown_arrow_sizes
    
    if manifest.has("slider_grabber_path_prefix"):
        self.slider_grabber_path_prefix = \
                manifest.slider_grabber_path_prefix
    if manifest.has("default_slider_grabber_size"):
        self.default_slider_grabber_size = \
                manifest.default_slider_grabber_size
    if manifest.has("slider_grabber_sizes"):
        self.slider_grabber_sizes = \
                manifest.slider_grabber_sizes
    
    if manifest.has("slider_tick_path_prefix"):
        self.slider_tick_path_prefix = \
                manifest.slider_tick_path_prefix
    if manifest.has("default_slider_tick_size"):
        self.default_slider_tick_size = \
                manifest.default_slider_tick_size
    if manifest.has("slider_tick_sizes"):
        self.slider_tick_sizes = \
                manifest.slider_tick_sizes


func _update_icon_sizes() -> void:
    Sc.images._update_checkbox_size()
    Sc.images._update_radio_button_size()
    Sc.images._update_tree_arrow_size()
    Sc.images._update_dropdown_arrow_size()
    Sc.images._update_slider_grabber_size()
    Sc.images._update_slider_tick_size()


func _update_checkbox_size() -> void:
    var target_icon_size: float = \
            Sc.images.default_checkbox_size * Sc.gui.scale
    var closest_icon_size: float = INF
    for icon_size in Sc.images.checkbox_sizes:
        if abs(target_icon_size - icon_size) < \
                abs(target_icon_size - closest_icon_size):
            closest_icon_size = icon_size
    Sc.images.current_checkbox_size = closest_icon_size
    
    var checked_icon_path: String = \
            Sc.images.checkbox_path_prefix + "checked_" + \
            str(Sc.images.current_checkbox_size) + ".png"
    var unchecked_icon_path: String = \
            Sc.images.checkbox_path_prefix + "unchecked_" + \
            str(Sc.images.current_checkbox_size) + ".png"
    
    var checked_icon := load(checked_icon_path)
    var unchecked_icon := load(unchecked_icon_path)
    
    Sc.gui.theme.set_icon("checked", "CheckBox", checked_icon)
    Sc.gui.theme.set_icon("unchecked", "CheckBox", unchecked_icon)
    Sc.gui.theme.set_icon("checked", "PopupMenu", checked_icon)
    Sc.gui.theme.set_icon("unchecked", "PopupMenu", unchecked_icon)


func _update_radio_button_size() -> void:
    var target_icon_size: float = \
            Sc.images.default_radio_button_size * Sc.gui.scale
    var closest_icon_size: float = INF
    for icon_size in Sc.images.radio_button_sizes:
        if abs(target_icon_size - icon_size) < \
                abs(target_icon_size - closest_icon_size):
            closest_icon_size = icon_size
    Sc.images.current_radio_button_size = closest_icon_size
    
    var checked_icon_path: String = \
            Sc.images.radio_button_path_prefix + "checked_" + \
            str(Sc.images.current_radio_button_size) + ".png"
    var unchecked_icon_path: String = \
            Sc.images.radio_button_path_prefix + "unchecked_" + \
            str(Sc.images.current_radio_button_size) + ".png"
    
    var checked_icon := load(checked_icon_path)
    var unchecked_icon := load(unchecked_icon_path)
    
    Sc.gui.theme.set_icon("radio_checked", "CheckBox", checked_icon)
    Sc.gui.theme.set_icon("radio_unchecked", "CheckBox", unchecked_icon)
    Sc.gui.theme.set_icon("radio_checked", "PopupMenu", checked_icon)
    Sc.gui.theme.set_icon("radio_unchecked", "PopupMenu", unchecked_icon)


func _update_tree_arrow_size() -> void:
    var target_icon_size: float = \
            Sc.images.default_tree_arrow_size * Sc.gui.scale
    var closest_icon_size: float = INF
    for icon_size in Sc.images.tree_arrow_sizes:
        if abs(target_icon_size - icon_size) < \
                abs(target_icon_size - closest_icon_size):
            closest_icon_size = icon_size
    Sc.images.current_tree_arrow_size = closest_icon_size
    
    var open_icon_path: String = \
            Sc.images.tree_arrow_path_prefix + "open_" + \
            str(Sc.images.current_tree_arrow_size) + ".png"
    var closed_icon_path: String = \
            Sc.images.tree_arrow_path_prefix + "closed_" + \
            str(Sc.images.current_tree_arrow_size) + ".png"
    
    var open_icon := load(open_icon_path)
    var closed_icon := load(closed_icon_path)
    
    Sc.gui.theme.set_icon("arrow", "Tree", open_icon)
    Sc.gui.theme.set_icon("arrow_collapsed", "Tree", closed_icon)
    Sc.gui.theme.set_constant(
            "item_margin", "Tree", Sc.images.current_tree_arrow_size)


func _update_dropdown_arrow_size() -> void:
    var target_icon_size: float = \
            Sc.images.default_dropdown_arrow_size * Sc.gui.scale
    var closest_icon_size: float = INF
    for icon_size in Sc.images.dropdown_arrow_sizes:
        if abs(target_icon_size - icon_size) < \
                abs(target_icon_size - closest_icon_size):
            closest_icon_size = icon_size
    Sc.images.current_dropdown_arrow_size = closest_icon_size
    
    var path: String = \
            Sc.images.dropdown_arrow_path_prefix + \
            str(Sc.images.current_dropdown_arrow_size) + ".png"
    
    var icon := load(path)
    
    Sc.gui.theme.set_icon("arrow", "OptionButton", icon)
    Sc.gui.theme.set_constant(
            "arrow_margin",
            "OptionButton",
            Sc.images.current_dropdown_arrow_size)


func _update_slider_grabber_size() -> void:
    var target_icon_size: float = \
            Sc.images.default_slider_grabber_size * Sc.gui.scale
    var closest_icon_size: float = INF
    for icon_size in Sc.images.slider_grabber_sizes:
        if abs(target_icon_size - icon_size) < \
                abs(target_icon_size - closest_icon_size):
            closest_icon_size = icon_size
    Sc.images.current_slider_grabber_size = closest_icon_size
    
    var path: String = \
            Sc.images.slider_grabber_path_prefix + \
            str(Sc.images.current_slider_grabber_size) + ".png"
    
    var icon := load(path)
    
    Sc.gui.theme.set_icon("grabber", "HSlider", icon)
    Sc.gui.theme.set_icon("grabber_disabled", "HSlider", icon)
    Sc.gui.theme.set_icon("grabber_highlight", "HSlider", icon)


func _update_slider_tick_size() -> void:
    var target_icon_size: float = \
            Sc.images.default_slider_tick_size * Sc.gui.scale
    var closest_icon_size: float = INF
    for icon_size in Sc.images.slider_tick_sizes:
        if abs(target_icon_size - icon_size) < \
                abs(target_icon_size - closest_icon_size):
            closest_icon_size = icon_size
    Sc.images.current_slider_tick_size = closest_icon_size
    
    var path: String = \
            Sc.images.slider_tick_path_prefix + \
            str(Sc.images.current_slider_tick_size) + ".png"
    
    var icon := load(path)
    
    Sc.gui.theme.set_icon("tick", "HSlider", icon)

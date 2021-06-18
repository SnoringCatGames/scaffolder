class_name ScaffolderGuiConfig
extends Node


# --- Constants ---

const WELCOME_PANEL_PATH := \
        "res://addons/scaffolder/src/gui/welcome_panel.tscn"
const DEBUG_PANEL_PATH := \
        "res://addons/scaffolder/src/gui/debug_panel.tscn"
const DEFAULT_HUD_KEY_VALUE_BOX_NINE_PATCH_RECT_PATH := \
        "res://addons/scaffolder/src/gui/hud/hud_key_value_box_nine_patch_rect.tscn"
const DEFAULT_FADE_IN_TRANSITON_TEXTURE_PATH := \
        "res://addons/scaffolder/assets/images/transition_in.png"
const DEFAULT_FADE_OUT_TRANSITON_TEXTURE_PATH := \
        "res://addons/scaffolder/assets/images/transition_out.png"

const MIN_GUI_SCALE := 0.2

const HUD_KEY_VALUE_BOX_DEFAULT_SIZE := Vector2(256.0, 48.0)

var DEFAULT_WELCOME_PANEL_ITEMS := [
    StaticTextLabeledControlItem.new("*Auto nav*", "click"),
    StaticTextLabeledControlItem.new("Inspect graph", "ctrl + click (x2)"),
    StaticTextLabeledControlItem.new("Walk/Climb", "arrow key / wasd"),
    StaticTextLabeledControlItem.new("Jump", "space / x"),
    StaticTextLabeledControlItem.new("Dash", "z"),
    StaticTextLabeledControlItem.new("Zoom in/out", "ctrl + =/-"),
    StaticTextLabeledControlItem.new("Pan", "ctrl + arrow key"),
]

var DEFAULT_HUD_MANIFEST := {
    hud_class = ScaffolderHud,
    hud_key_value_box_size = HUD_KEY_VALUE_BOX_DEFAULT_SIZE,
    hud_key_value_box_nine_patch_rect_path = \
            DEFAULT_HUD_KEY_VALUE_BOX_NINE_PATCH_RECT_PATH,
    hud_key_value_list_item_manifest = [
        {
            item_class = TimeLabeledControlItem,
            settings_enablement_label = "Time",
            enabled = true,
        },
    ],
}

var DEFAULT_SCAFFOLDER_SETTINGS_ITEM_MANIFEST := {
    groups = {
        main = {
            label = "",
            is_collapsible = false,
            item_classes = [
                MusicSettingsLabeledControlItem,
                SoundEffectsSettingsLabeledControlItem,
                HapticFeedbackSettingsLabeledControlItem,
            ],
        },
        hud = {
            label = "HUD",
            is_collapsible = true,
            item_classes = [
            ],
        },
        miscellaneous = {
            label = "Miscellaneous",
            is_collapsible = true,
            item_classes = [
                WelcomePanelSettingsLabeledControlItem,
                TimeScaleSettingsLabeledControlItem,
                MetronomeSettingsLabeledControlItem,
            ],
        },
    },
}

# --- Static configuration state ---

var cell_size: Vector2

# Should match Project Settings > Display > Window > Size > Width/Height
var default_game_area_size: Vector2

var aspect_ratio_max: float
var aspect_ratio_min: float

var camera_smoothing_speed: float
var default_camera_zoom := 1.0

var is_data_deletion_button_shown: bool

var input_vibrate_duration := 0.01

var display_resize_throttle_interval := 0.1

var recent_gesture_events_for_debugging_buffer_size := 1000

var checkbox_icon_path_prefix := \
        "res://addons/scaffolder/assets/images/gui/checkbox_"
var default_checkbox_icon_size := 32
var checkbox_icon_sizes := [16, 32, 64, 128]

var tree_arrow_icon_path_prefix := \
        "res://addons/scaffolder/assets/images/gui/tree_arrow_"
var default_tree_arrow_icon_size := 16
var tree_arrow_icon_sizes := [8, 16, 32, 64]

var third_party_license_text: String
var special_thanks_text: String

var main_menu_image_scene_path: String
var loading_image_scene_path: String
var welcome_panel_path: String

var fade_in_transition_texture := \
        preload(DEFAULT_FADE_IN_TRANSITON_TEXTURE_PATH)
var fade_out_transition_texture := \
        preload(DEFAULT_FADE_OUT_TRANSITON_TEXTURE_PATH)

var theme: Theme

var fonts: Dictionary

var settings_item_manifest: Dictionary
var hud_manifest: Dictionary
var welcome_panel_items: Array

var screen_path_exclusions: Array
var screen_path_inclusions: Array
var pause_item_class_exclusions: Array
var pause_item_class_inclusions: Array
var game_over_item_class_exclusions: Array
var game_over_item_class_inclusions: Array
var level_select_item_class_exclusions: Array
var level_select_item_class_inclusions: Array

# --- Derived configuration ---

var is_special_thanks_shown: bool
var is_third_party_licenses_shown: bool
var is_rate_app_shown: bool
var is_support_shown: bool
var is_gesture_logging_supported: bool
var is_developer_logo_shown: bool
var is_developer_splash_shown: bool
var is_main_menu_image_shown: bool
var is_loading_image_shown: bool
var does_app_contain_welcome_panel: bool
var is_welcome_panel_shown: bool
var original_font_sizes: Dictionary

# --- Global state ---

var game_area_region: Rect2
var scale := 1.0
var current_checkbox_icon_size := default_checkbox_icon_size
var current_tree_arrow_icon_size := default_checkbox_icon_size

var is_giving_haptic_feedback: bool
var is_debug_panel_shown: bool setget \
        _set_is_debug_panel_shown, _get_is_debug_panel_shown
var is_debug_time_shown: bool
var is_user_interaction_enabled := true

var debug_panel: DebugPanel
var hud: ScaffolderHud
var welcome_panel: WelcomePanel
var gesture_record: GestureRecord

var guis_to_scale := {}
var active_overlays := []

# ---


func amend_app_manifest(manifest: Dictionary) -> void:
    if !manifest.has("settings_item_manifest"):
        manifest.settings_item_manifest = \
                DEFAULT_SCAFFOLDER_SETTINGS_ITEM_MANIFEST
    if !manifest.has("screen_path_exclusions"):
        manifest.screen_path_exclusions = []
    if !manifest.has("screen_path_inclusions"):
        manifest.screen_path_inclusions = []
    if !manifest.has("pause_item_class_exclusions"):
        manifest.pause_item_class_exclusions = []
    if !manifest.has("pause_item_class_inclusions"):
        manifest.pause_item_class_inclusions = []
    if !manifest.has("game_over_item_class_exclusions"):
        manifest.game_over_item_class_exclusions = []
    if !manifest.has("game_over_item_class_inclusions"):
        manifest.game_over_item_class_inclusions = []
    if !manifest.has("level_select_item_class_exclusions"):
        manifest.level_select_item_class_exclusions = []
    if !manifest.has("level_select_item_class_inclusions"):
        manifest.level_select_item_class_inclusions = []
    if !manifest.has("welcome_panel_items"):
        manifest.welcome_panel_items = DEFAULT_WELCOME_PANEL_ITEMS
    if !manifest.has("hud_manifest"):
        manifest.hud_manifest = DEFAULT_HUD_MANIFEST


func register_manifest(manifest: Dictionary) -> void:
    amend_app_manifest(manifest)
    
    self.theme = manifest.theme
    self.cell_size = manifest.cell_size
    self.default_game_area_size = manifest.default_game_area_size
    self.aspect_ratio_max = manifest.aspect_ratio_max
    self.aspect_ratio_min = manifest.aspect_ratio_min
    self.is_data_deletion_button_shown = manifest.is_data_deletion_button_shown
    
    self.settings_item_manifest = manifest.settings_item_manifest
    self.screen_path_exclusions = manifest.screen_path_exclusions
    self.screen_path_inclusions = manifest.screen_path_inclusions
    self.pause_item_class_exclusions = manifest.pause_item_class_exclusions
    self.pause_item_class_inclusions = manifest.pause_item_class_inclusions
    self.game_over_item_class_exclusions = \
            manifest.game_over_item_class_exclusions
    self.game_over_item_class_inclusions = \
            manifest.game_over_item_class_inclusions
    self.level_select_item_class_exclusions = \
            manifest.level_select_item_class_exclusions
    self.level_select_item_class_inclusions = \
            manifest.level_select_item_class_inclusions
    self.welcome_panel_items = manifest.welcome_panel_items
    self.hud_manifest = manifest.hud_manifest
    self.fonts = manifest.fonts
    self.third_party_license_text = \
            manifest.third_party_license_text.strip_edges()
    self.special_thanks_text = manifest.special_thanks_text.strip_edges()
    
    if manifest.has("main_menu_image_scene_path"):
        self.main_menu_image_scene_path = manifest.main_menu_image_scene_path
    if manifest.has("loading_image_scene_path"):
        self.loading_image_scene_path = manifest.loading_image_scene_path
    if manifest.has("welcome_panel_path"):
        self.welcome_panel_path = manifest.welcome_panel_path
    if manifest.has("fade_in_transition_texture"):
        self.fade_in_transition_texture = manifest.fade_in_transition_texture
    if manifest.has("fade_out_transition_texture"):
        self.fade_out_transition_texture = manifest.fade_out_transition_texture
    
    if manifest.has("default_camera_zoom"):
        self.default_camera_zoom = manifest.default_camera_zoom
    if manifest.has("camera_smoothing_speed"):
        self.camera_smoothing_speed = manifest.camera_smoothing_speed
    if manifest.has("input_vibrate_duration"):
        self.input_vibrate_duration = \
                manifest.input_vibrate_duration
    if manifest.has("display_resize_throttle_interval"):
        self.display_resize_throttle_interval = \
                manifest.display_resize_throttle_interval
    if manifest.has("recent_gesture_events_for_debugging_buffer_size"):
        self.recent_gesture_events_for_debugging_buffer_size = \
                manifest.recent_gesture_events_for_debugging_buffer_size
    
    self.is_special_thanks_shown = !self.special_thanks_text.empty()
    self.is_third_party_licenses_shown = !self.third_party_license_text.empty()
    self.is_rate_app_shown = \
            !Gs.android_app_store_url.empty() and \
            !Gs.ios_app_store_url.empty()
    self.is_support_shown = \
            !Gs.support_url.empty() and \
            !Gs.app_id_query_param.empty()
    self.is_developer_logo_shown = Gs.developer_logo != null
    self.is_developer_splash_shown = \
            Gs.developer_splash != null and \
            Gs.audio_manifest.developer_splash_sound != ""
    self.is_main_menu_image_shown = self.main_menu_image_scene_path != ""
    self.is_loading_image_shown = self.loading_image_scene_path != ""
    self.does_app_contain_welcome_panel = welcome_panel_path != ""
    self.is_gesture_logging_supported = \
            !Gs.log_gestures_url.empty() and \
            !Gs.app_id_query_param.empty()
    
    _record_original_font_sizes()


func add_gui_to_scale(
        gui,
        default_gui_scale: float) -> void:
    guis_to_scale[gui] = default_gui_scale
    Gs.utils._scale_gui_for_current_screen_size(gui)


func remove_gui_to_scale(gui) -> void:
    guis_to_scale.erase(gui)


func _set_is_debug_panel_shown(is_visible: bool) -> void:
    is_debug_panel_shown = is_visible
    if debug_panel != null:
        debug_panel.visible = is_visible


func _get_is_debug_panel_shown() -> bool:
    return is_debug_panel_shown


func _record_original_font_sizes() -> void:
    for key in fonts:
        original_font_sizes[key] = fonts[key].size
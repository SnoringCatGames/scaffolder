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

# Useful for getting screenshots at specific resolutions.
const SCREEN_RESOLUTIONS := {
    # Should match Project Settings > Display > Window > Size > Width/Height
    default = Vector2(1024, 768),
    full_screen = Vector2.INF,
    play_store = Vector2(3840, 2160),
    iphone_6_5 = Vector2(2778, 1284),
    iphone_5_5 = Vector2(2208, 1242),
    ipad_12_9 = Vector2(2732, 2048),
    google_ads_landscape = Vector2(1024, 768),
    google_ads_portrait = Vector2(768, 1024),
}

var DEFAULT_WELCOME_PANEL_MANIFEST := {
#    header = Gs.app_metadata.app_name,
#    subheader = "(Click window to give focus)",
#    is_header_shown = true,
    items = [
        ["*Auto nav*", "click"],
        ["Inspect graph", "ctrl + click (x2)"],
        ["Walk/Climb", "arrow key / wasd"],
        ["Jump", "space / x"],
        ["Dash", "z"],
        ["Zoom in/out", "ctrl + =/-"],
        ["Pan", "ctrl + arrow key"],
    ],
}

var DEFAULT_HUD_MANIFEST := {
    hud_class = ScaffolderHud,
    hud_key_value_box_size = HUD_KEY_VALUE_BOX_DEFAULT_SIZE,
    hud_key_value_box_nine_patch_rect_path = \
            DEFAULT_HUD_KEY_VALUE_BOX_NINE_PATCH_RECT_PATH,
    hud_key_value_list_item_manifest = [
        {
            item_class = TimeLabeledControlItem,
            settings_enablement_label = "Time",
            enabled_by_default = true,
            settings_group_key = "hud",
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

var DEFAULT_SCAFFOLDER_PAUSE_ITEM_MANIFEST := [
    LevelLabeledControlItem,
    TimeLabeledControlItem,
    FastestTimeLabeledControlItem,
    ScoreLabeledControlItem,
    HighScoreLabeledControlItem,
]

var DEFAULT_SCAFFOLDER_GAME_OVER_ITEM_MANIFEST := [
    LevelLabeledControlItem,
    TimeLabeledControlItem,
    FastestTimeLabeledControlItem,
    ScoreLabeledControlItem,
    HighScoreLabeledControlItem,
]

var DEFAULT_SCAFFOLDER_LEVEL_SELECT_ITEM_MANIFEST := [
    TotalPlaysLabeledControlItem,
    FastestTimeLabeledControlItem,
    HighScoreLabeledControlItem,
]

# --- Static configuration state ---

var cell_size: Vector2

# Should match Project Settings > Display > Window > Size > Width/Height
var default_game_area_size: Vector2

var aspect_ratio_max: float
var aspect_ratio_min: float

var debug_window_size: Vector2

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
var pause_item_manifest: Array
var game_over_item_manifest: Array
var level_select_item_manifest: Array
var hud_manifest: Dictionary
var welcome_panel_manifest: Dictionary
var screen_manifest: Dictionary

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


func _init() -> void:
    Gs.logger.print("ScaffolderGuiConfig._init")


func amend_manifest(manifest: Dictionary) -> void:
    if !manifest.has("settings_item_manifest"):
        manifest.settings_item_manifest = \
                DEFAULT_SCAFFOLDER_SETTINGS_ITEM_MANIFEST
    if !manifest.has("pause_item_manifest"):
        manifest.pause_item_manifest = \
                DEFAULT_SCAFFOLDER_PAUSE_ITEM_MANIFEST
    if !manifest.has("game_over_item_manifest"):
        manifest.game_over_item_manifest = \
                DEFAULT_SCAFFOLDER_GAME_OVER_ITEM_MANIFEST
    if !manifest.has("level_select_item_manifest"):
        manifest.level_select_item_manifest = \
                DEFAULT_SCAFFOLDER_LEVEL_SELECT_ITEM_MANIFEST
    if !manifest.has("screen_manifest"):
        manifest.screen_manifest = {
            path_inclusions = [],
            path_exclusions = [],
        }
    if !manifest.has("welcome_panel_manifest"):
        manifest.welcome_panel_manifest = DEFAULT_WELCOME_PANEL_MANIFEST
    if !manifest.has("hud_manifest"):
        manifest.hud_manifest = DEFAULT_HUD_MANIFEST
    
    # Configure settings-screen enablement items for each HUD key-value-list
    # item.
    for item_config in manifest.hud_manifest.hud_key_value_list_item_manifest:
        if !item_config.has("settings_group_key"):
            continue
        assert(manifest.settings_item_manifest.groups.has(
                item_config.settings_group_key))
        var settings_group: Dictionary = manifest.settings_item_manifest \
                .groups[item_config.settings_group_key]
        if !settings_group.has("hud_enablement_items"):
            settings_group.hud_enablement_items = []
        settings_group.hud_enablement_items.push_back(item_config)


func register_manifest(manifest: Dictionary) -> void:
    amend_manifest(manifest)
    
    self.theme = manifest.theme
    self.cell_size = manifest.cell_size
    self.default_game_area_size = manifest.default_game_area_size
    self.aspect_ratio_max = manifest.aspect_ratio_max
    self.aspect_ratio_min = manifest.aspect_ratio_min
    self.debug_window_size = manifest.debug_window_size
    self.is_data_deletion_button_shown = manifest.is_data_deletion_button_shown
    
    self.settings_item_manifest = manifest.settings_item_manifest
    self.pause_item_manifest = manifest.pause_item_manifest
    self.game_over_item_manifest = manifest.game_over_item_manifest
    self.level_select_item_manifest = manifest.level_select_item_manifest
    self.screen_manifest = manifest.screen_manifest
    self.welcome_panel_manifest = manifest.welcome_panel_manifest
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
            !Gs.app_metadata.android_app_store_url.empty() and \
            !Gs.app_metadata.ios_app_store_url.empty()
    self.is_support_shown = \
            !Gs.app_metadata.support_url.empty() and \
            !Gs.app_metadata.app_id_query_param.empty()
    self.is_developer_logo_shown = Gs.app_metadata.developer_logo != null
    self.is_developer_splash_shown = \
            Gs.app_metadata.developer_splash != null and \
            Gs.audio_manifest.developer_splash_sound != ""
    self.is_main_menu_image_shown = self.main_menu_image_scene_path != ""
    self.is_loading_image_shown = self.loading_image_scene_path != ""
    self.does_app_contain_welcome_panel = welcome_panel_path != ""
    self.is_gesture_logging_supported = \
            !Gs.app_metadata.log_gestures_url.empty() and \
            !Gs.app_metadata.app_id_query_param.empty()
    
    _record_original_font_sizes()
    
    _initialize_hud_key_value_list_item_enablement()
    
    if !Gs.app_metadata.uses_level_scores:
        for manifest in [
                    pause_item_manifest,
                    game_over_item_manifest,
                    level_select_item_manifest,
                ]:
            manifest.erase(ScoreLabeledControlItem)
            manifest.erase(HighScoreLabeledControlItem)


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


func _initialize_hud_key_value_list_item_enablement() -> void:
    for item_config in hud_manifest.hud_key_value_list_item_manifest:
        item_config.settings_key = _get_key_value_item_enabled_settings_key(
                item_config.settings_enablement_label)
        item_config.enabled = Gs.save_state.get_setting(
                item_config.settings_key,
                item_config.enabled_by_default)


func _get_key_value_item_enabled_settings_key(
        settings_enablement_label: String) -> String:
    return settings_enablement_label.replace(" ", "_") + "_hud"

class_name ScaffolderAppMetadata
extends Node


# --- Static configuration state ---

var debug: bool
var playtest: bool
var test := false
var pauses_on_focus_out := true
var is_profiler_enabled: bool
var are_all_levels_unlocked := false
var are_test_levels_included := true
var is_save_state_cleared_for_debugging := false
var is_splash_skipped := false
var also_prints_to_stdout := true

# Should match Project Settings > Physics > 2d > Thread Model
var uses_threads: bool
var thread_count: int

var is_mobile_supported: bool

var app_name: String
var app_id: String
var app_version: String
var score_version: String
var data_agreement_version: String

var uses_level_scores: bool

var must_restart_level_to_change_settings: bool

var app_logo: Texture
var app_logo_scale: float
var go_icon: Texture
var go_icon_scale: float
var developer_name: String
var developer_url: String

var developer_logo: Texture
var developer_splash: Texture

var godot_splash_screen_duration := 0.8
var developer_splash_screen_duration := 1.0

# Must start with "UA-".
var google_analytics_id: String
var terms_and_conditions_url: String
var privacy_policy_url: String
var android_app_store_url: String
var ios_app_store_url: String
var support_url: String
var error_logs_url: String
var log_gestures_url: String
var app_id_query_param: String

# --- Derived configuration ---

var is_data_tracked: bool
var are_error_logs_captured: bool

# --- Global state ---

var is_app_configured := false
var is_app_initialized := false
var were_screenshots_taken := false
var agreed_to_terms: bool

# ---


func _init() -> void:
    Gs.logger.print("ScaffolderAppMetadata._init")


func register_manifest(manifest: Dictionary) -> void:
    self.debug = manifest.debug
    self.playtest = manifest.playtest
    if manifest.has("test"):
        self.test = manifest.test
    if manifest.has("are_all_levels_unlocked"):
        self.are_all_levels_unlocked = manifest.are_all_levels_unlocked
    if manifest.has("are_test_levels_included"):
        self.are_test_levels_included = manifest.are_test_levels_included
    if manifest.has("is_save_state_cleared_for_debugging"):
        self.is_save_state_cleared_for_debugging = \
                manifest.is_save_state_cleared_for_debugging
    self.pauses_on_focus_out = manifest.pauses_on_focus_out
    self.also_prints_to_stdout = manifest.also_prints_to_stdout
    self.is_profiler_enabled = manifest.is_profiler_enabled
    self.uses_threads = manifest.uses_threads
    self.thread_count = manifest.thread_count
    self.is_mobile_supported = manifest.is_mobile_supported
    self.uses_level_scores = manifest.uses_level_scores
    self.must_restart_level_to_change_settings = \
            manifest.must_restart_level_to_change_settings
    if manifest.has("is_splash_skipped"):
        self.is_splash_skipped = manifest.is_splash_skipped
    
    self.app_name = manifest.app_name
    self.app_id = manifest.app_id
    self.app_version = manifest.app_version
    self.score_version = manifest.score_version
    
    self.app_logo = manifest.app_logo
    self.app_logo_scale = manifest.app_logo_scale
    self.go_icon = manifest.go_icon
    self.go_icon_scale = manifest.go_icon_scale
    self.developer_name = manifest.developer_name
    self.developer_url = manifest.developer_url
    if manifest.has("developer_logo"):
        self.developer_logo = manifest.developer_logo
    if manifest.has("developer_splash"):
        self.developer_splash = manifest.developer_splash
    if manifest.has("godot_splash_screen_duration"):
        self.godot_splash_screen_duration = \
                manifest.godot_splash_screen_duration
    if manifest.has("developer_splash_screen_duration"):
        self.developer_splash_screen_duration = \
                manifest.developer_splash_screen_duration
    
    if manifest.has("google_analytics_id"):
        self.google_analytics_id = manifest.google_analytics_id
    if manifest.has("data_agreement_version"):
        self.data_agreement_version = manifest.data_agreement_version
    if manifest.has("terms_and_conditions_url"):
        self.terms_and_conditions_url = manifest.terms_and_conditions_url
    if manifest.has("privacy_policy_url"):
        self.privacy_policy_url = manifest.privacy_policy_url
    if manifest.has("android_app_store_url"):
        self.android_app_store_url = manifest.android_app_store_url
    if manifest.has("ios_app_store_url"):
        self.ios_app_store_url = manifest.ios_app_store_url
    if manifest.has("support_url"):
        self.support_url = manifest.support_url
    if manifest.has("error_logs_url"):
        self.error_logs_url = manifest.error_logs_url
    if manifest.has("log_gestures_url"):
        self.log_gestures_url = manifest.log_gestures_url
    if manifest.has("app_id_query_param"):
        self.app_id_query_param = manifest.app_id_query_param
    
    assert(self.google_analytics_id.empty() == \
            self.privacy_policy_url.empty() and \
            self.privacy_policy_url.empty() == \
            self.terms_and_conditions_url.empty())
    
    self.is_data_tracked = \
            !self.privacy_policy_url.empty() and \
            !self.terms_and_conditions_url.empty() and \
            !self.google_analytics_id.empty()
    self.are_error_logs_captured = \
            self.is_data_tracked and \
            !self.error_logs_url.empty()
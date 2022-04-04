tool
class_name ScaffolderAppMetadata
extends Node


# --- Static configuration state ---

var debug: bool
var playtest: bool
var recording: bool
var test := false
var pauses_on_focus_out := true
var is_profiler_enabled: bool
var are_all_levels_unlocked := false
var are_test_levels_included := true
var is_save_state_cleared_for_debugging := false
var is_splash_skipped := false
var opens_directly_to_level_id := ""
var also_prints_to_stdout := true
var logs_character_events := true
var logs_bootstrap_events := true
var logs_device_settings := true
var logs_in_editor_events := true
var logs_analytics_events := true
var overrides_project_settings := true
var overrides_input_map := true
var are_button_controls_enabled_by_default := false

# Should match Project Settings > Physics > 2d > Thread Model
var uses_threads: bool
var thread_count: int

var is_mobile_supported: bool

var rng_seed := 176

var base_path := ""

var app_name: String
var app_id: String
var app_version: String
var score_version: String
var data_agreement_version: String

var uses_level_scores: bool

var must_restart_level_to_change_settings: bool

var developer_name: String
var developer_url: String
var github_url: String

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
var were_screenshots_taken := false
var agreed_to_terms: bool
var are_button_controls_enabled: bool

# Dictionary<String, int>
var _render_layer_name_to_bitmask := {}
# Dictionary<String, int>
var _physics_layer_name_to_bitmask := {}

# Dictionary<int, String>
var _render_layer_bitmask_to_name := {}
# Dictionary<int, String>
var _physics_layer_bitmask_to_name := {}

# ---


func _init() -> void:
    Sc.logger.on_global_init(self, "ScaffolderAppMetadata")


func _parse_manifest(manifest: Dictionary) -> void:
    self.debug = manifest.debug
    self.playtest = manifest.playtest
    self.recording = manifest.recording
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
    self.logs_character_events = manifest.logs_character_events
    self.logs_analytics_events = manifest.logs_analytics_events
    self.logs_bootstrap_events = manifest.logs_bootstrap_events
    self.logs_device_settings = manifest.logs_device_settings
    self.logs_in_editor_events = manifest.logs_in_editor_events
    self.overrides_project_settings = manifest.overrides_project_settings
    self.overrides_input_map = manifest.overrides_input_map
    self.are_button_controls_enabled_by_default = \
            manifest.are_button_controls_enabled_by_default
    self.is_profiler_enabled = manifest.is_profiler_enabled
    self.uses_threads = manifest.uses_threads
    self.thread_count = manifest.thread_count
    self.is_mobile_supported = manifest.is_mobile_supported
    if manifest.has("rng_seed"):
        self.rng_seed = manifest.rng_seed
    if manifest.has("base_path"):
        self.base_path = manifest.base_path
    self.uses_level_scores = manifest.uses_level_scores
    self.must_restart_level_to_change_settings = \
            manifest.must_restart_level_to_change_settings
    if manifest.has("is_splash_skipped"):
        self.is_splash_skipped = manifest.is_splash_skipped
    if manifest.has("opens_directly_to_level_id"):
        self.opens_directly_to_level_id = manifest.opens_directly_to_level_id
    
    self.app_name = manifest.app_name
    self.app_id = manifest.app_id
    self.app_version = manifest.app_version
    self.score_version = manifest.score_version
    
    self.developer_name = manifest.developer_name
    self.developer_url = manifest.developer_url
    self.github_url = manifest.github_url
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
    
    _record_layer_names()


func _record_layer_names() -> void:
    for i in 20:
        var layer_name: String = ProjectSettings.get_setting(
                "layer_names/2d_render/layer_%d" % (i + 1))
        var layer_bitmask := int(pow(2, i))
        _render_layer_name_to_bitmask[layer_name] = layer_bitmask
        _render_layer_bitmask_to_name[layer_bitmask] = layer_name
    
    for i in 20:
        var layer_name: String = ProjectSettings.get_setting(
                "layer_names/2d_physics/layer_%d" % (i + 1))
        var layer_bitmask := int(pow(2, i))
        _physics_layer_name_to_bitmask[layer_name] = layer_bitmask
        _physics_layer_bitmask_to_name[layer_bitmask] = layer_name


func _clear_old_data_agreement_version() -> void:
    if Sc.metadata.data_agreement_version != \
            Sc.save_state.get_data_agreement_version():
        Sc.save_state.set_data_agreement_version(
                Sc.metadata.data_agreement_version)
        Sc.metadata.set_agreed_to_terms(false)


func set_agreed_to_terms(value := true) -> void:
    Sc.metadata.agreed_to_terms = value
    Sc.save_state.set_setting(
            SaveState.AGREED_TO_TERMS_SETTINGS_KEY,
            value)


func get_support_url_with_params() -> String:
    var params := "?source=" + OS.get_name()
    params += "&app=" + Sc.metadata.app_id_query_param
    return Sc.metadata.support_url + params


func get_log_gestures_url_with_params() -> String:
    var params := "?source=" + OS.get_name()
    params += "&app=" + Sc.metadata.app_id_query_param
    return Sc.logger_gestures_url + params

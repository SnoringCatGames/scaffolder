tool
class_name ScaffolderAudioManifest
extends Node


var sounds_manifest: Array
var default_sounds_path_prefix: String
var default_sounds_file_suffix: String
var default_sounds_bus_index: int

var music_manifest: Array
var default_music_path_prefix: String
var default_music_file_suffix: String
var default_music_bus_index: int

var godot_splash_sound := "achievement"
var developer_splash_sound: String
var level_end_sound_win: String
var level_end_sound_lose: String

var main_menu_music: String
var game_over_music: String
var pause_menu_music: String
var default_level_music: String

var pauses_level_music_on_pause: bool

var are_beats_tracked_by_default: bool

var is_arbitrary_music_speed_change_supported := false
var is_music_speed_scaled_with_time_scale := false
var is_music_speed_scaled_with_additional_debug_time_scale := true

var is_music_paused_in_slow_motion := true
var is_tick_tock_played_in_slow_motion := true
var is_slow_motion_start_stop_sound_effect_played := true


func _init() -> void:
    Sc.logger.on_global_init(self, "ScaffolderAudioManifest")


func _parse_manifest(manifest: Dictionary) -> void:
    self.sounds_manifest = manifest.sounds_manifest
    self.default_sounds_path_prefix = manifest.default_sounds_path_prefix
    self.default_sounds_file_suffix = manifest.default_sounds_file_suffix
    self.default_sounds_bus_index = manifest.default_sounds_bus_index
    
    self.music_manifest = manifest.music_manifest
    self.default_music_path_prefix = manifest.default_music_path_prefix
    self.default_music_file_suffix = manifest.default_music_file_suffix
    self.default_music_bus_index = manifest.default_music_bus_index
    
    if manifest.has("godot_splash_sound"):
        self.godot_splash_sound = manifest.godot_splash_sound
    if manifest.has("developer_splash_sound"):
        self.developer_splash_sound = manifest.developer_splash_sound
    if manifest.has("level_end_sound_win"):
        self.level_end_sound_win = manifest.level_end_sound_win
    if manifest.has("level_end_sound_lose"):
        self.level_end_sound_lose = manifest.level_end_sound_lose
    
    self.main_menu_music = manifest.main_menu_music
    if manifest.has("game_over_music"):
        self.game_over_music = manifest.game_over_music
    if manifest.has("pause_menu_music"):
        self.pause_menu_music = manifest.pause_menu_music
    if manifest.has("default_level_music"):
        self.default_level_music = manifest.default_level_music
    
    self.pauses_level_music_on_pause = manifest.pauses_level_music_on_pause
    
    self.are_beats_tracked_by_default = manifest.are_beats_tracked_by_default
    
    if manifest.has("is_arbitrary_music_speed_change_supported"):
        self.is_arbitrary_music_speed_change_supported = \
                manifest.is_arbitrary_music_speed_change_supported
    if manifest.has("is_music_speed_scaled_with_time_scale"):
        self.is_music_speed_scaled_with_time_scale = \
                manifest.is_music_speed_scaled_with_time_scale
    if manifest.has("is_music_speed_scaled_with_additional_debug_time_scale"):
        self.is_music_speed_scaled_with_additional_debug_time_scale = \
                manifest.is_music_speed_scaled_with_additional_debug_time_scale
    if manifest.has("is_music_paused_in_slow_motion"):
        self.is_music_paused_in_slow_motion = \
                manifest.is_music_paused_in_slow_motion
    if manifest.has("is_tick_tock_played_in_slow_motion"):
        self.is_tick_tock_played_in_slow_motion = \
                manifest.is_tick_tock_played_in_slow_motion
    if manifest.has("is_slow_motion_start_stop_sound_effect_played"):
        self.is_slow_motion_start_stop_sound_effect_played = \
                manifest.is_slow_motion_start_stop_sound_effect_played
    
    assert(Sc.audio_manifest.pauses_level_music_on_pause or \
            Sc.audio_manifest.pause_menu_music == "")
    
    Sc.beats.is_tracking_beat = are_beats_tracked_by_default
    
    Sc.audio.register_sounds(
            self.sounds_manifest,
            self.default_sounds_path_prefix,
            self.default_sounds_file_suffix,
            self.default_sounds_bus_index)
    Sc.audio.register_music(
            self.music_manifest,
            self.default_music_path_prefix,
            self.default_music_file_suffix,
            self.default_music_bus_index)

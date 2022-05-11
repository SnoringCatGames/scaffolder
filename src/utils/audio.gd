tool
class_name Audio
extends Node


signal music_changed(music_name)

const MUSIC_CROSS_FADE_DURATION := 0.2
const SILENT_VOLUME_DB := -80.0

const GLOBAL_AUDIO_VOLUME_OFFSET_DB := -10.0

const _DEFAULT_SOUNDS_PATH_PREFIX := "res://addons/scaffolder/assets/sounds/"
const _DEFAULT_SOUND_FILE_SUFFIX := ".wav"
const _DEFAULT_SOUNDS_BUS_INDEX := 1

const _DEFAULT_MUSIC_PATH_PREFIX := "res://addons/scaffolder/assets/music/"
const _DEFAULT_MUSIC_FILE_SUFFIX := ".ogg"
const _DEFAULT_MUSIC_BUS_INDEX := 2

var _inflated_sounds_config := {}
var _inflated_music_config := {}

var _fade_out_tween: ScaffolderTween
var _fade_in_tween: ScaffolderTween

var _pitch_shift_effect: AudioEffectPitchShift

var _previous_music_name := ""
var _current_music_name := ""

var playback_speed_multiplier := 1.0

var is_music_enabled := true setget _set_is_music_enabled
var is_sound_effects_enabled := true setget \
        _set_is_sound_effects_enabled
var is_metronome_enabled: bool


func _init() -> void:
    Sc.logger.on_global_init(self, "Audio")


func register_sounds(
        manifest: Array,
        path_prefix := _DEFAULT_SOUNDS_PATH_PREFIX,
        file_suffix := _DEFAULT_SOUND_FILE_SUFFIX,
        bus_index := _DEFAULT_SOUNDS_BUS_INDEX) -> void:
    if Engine.editor_hint:
        return
    
    _fade_out_tween = ScaffolderTween.new(self)
    _fade_in_tween = ScaffolderTween.new(self)
    _fade_in_tween.connect(
            "tween_all_completed",
            self,
            "_on_cross_fade_music_finished")
    
    AudioServer.add_bus(bus_index)
    var bus_name := AudioServer.get_bus_name(bus_index)
    
    for config in manifest:
        assert(config.has("name"))
        assert(config.has("volume_db"))
        var player := AudioStreamPlayer.new()
        var prefix: String = \
                config.path_prefix if \
                config.has("path_prefix") and config.path_prefix != "" else \
                path_prefix
        var suffix: String = \
                config.file_suffix if \
                config.has("file_suffix") else \
                file_suffix
        var path: String = prefix + config.name + suffix
        player.stream = load(path)
        player.bus = bus_name
        add_child(player)
        config.player = player
        _inflated_sounds_config[config.name] = config
    
    _update_volume()


func register_music(
        manifest: Array,
        path_prefix := _DEFAULT_MUSIC_PATH_PREFIX,
        file_suffix := _DEFAULT_MUSIC_FILE_SUFFIX,
        bus_index := _DEFAULT_MUSIC_BUS_INDEX) -> void:
    if Engine.editor_hint:
        return
    
    AudioServer.add_bus(bus_index)
    var bus_name := AudioServer.get_bus_name(bus_index)
    
    for config in manifest:
        assert(config.has("name"))
        assert(config.has("volume_db"))
        assert(config.has("bpm"))
        assert(config.has("meter"))
        var player := AudioStreamPlayer.new()
        var prefix: String = \
                config.path_prefix if \
                config.has("path_prefix") and config.path_prefix != "" else \
                path_prefix
        var suffix: String = \
                config.file_suffix if \
                config.has("file_suffix") else \
                file_suffix
        var path: String = prefix + config.name + suffix
        player.stream = load(path)
        player.bus = bus_name
        add_child(player)
        config.player = player
        _inflated_music_config[config.name] = config
    
    if Sc.audio_manifest.is_arbitrary_music_speed_change_supported or \
            Sc.audio_manifest.is_music_speed_scaled_with_time_scale or \
            Sc.audio_manifest \
                    .is_music_speed_scaled_with_additional_debug_time_scale:
        _pitch_shift_effect = AudioEffectPitchShift.new()
        AudioServer.add_bus_effect(bus_index, _pitch_shift_effect)
    
    _update_volume()
    
    self.is_metronome_enabled = Sc.save_state.get_setting(
            SaveState.IS_METRONOME_ENABLED_SETTINGS_KEY,
            false)


func play_sound(
        sound_name: String,
        volume_offset := 0.0,
        deferred := false) -> void:
    if Engine.editor_hint:
        return
    if deferred:
        call_deferred("_play_sound_deferred", sound_name, volume_offset)
    else:
        _play_sound_deferred(sound_name, volume_offset)


func play_music(
        music_name: String,
        transitions_immediately := false,
        deferred := false) -> void:
    var transition_duration := \
            0.01 if \
            transitions_immediately else \
            MUSIC_CROSS_FADE_DURATION
    if deferred:
        call_deferred(
                "cross_fade_music",
                music_name,
                transition_duration)
    else:
        cross_fade_music(music_name, transition_duration)


func stop_music() -> bool:
    var current_music_player := _get_current_music_player()
    if current_music_player != null:
        current_music_player.stop()
        _fade_out_tween.stop_all()
        _fade_in_tween.stop_all()
        emit_signal("music_changed", "")
        return true
    else:
        return false


func _play_sound_deferred(
        sound_name: String, 
        volume_offset := 0.0) -> void:
    var sound_config: Dictionary = _inflated_sounds_config[sound_name]
    sound_config.player.volume_db = \
            sound_config.volume_db + \
                    volume_offset + \
                    GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
            is_sound_effects_enabled else \
            SILENT_VOLUME_DB
    _inflated_sounds_config[sound_name].player.play()


func get_sound_player(sound_name: String) -> AudioStreamPlayer:
    return _inflated_sounds_config[sound_name].player


func get_music_player(music_name: String) -> AudioStreamPlayer:
    return _inflated_music_config[music_name].player


func _get_previous_music_player() -> AudioStreamPlayer:
    return _inflated_music_config[_previous_music_name].player if \
            _previous_music_name != "" else \
            null


func _get_current_music_player() -> AudioStreamPlayer:
    return _inflated_music_config[_current_music_name].player if \
            get_is_music_playing() else \
            null


func cross_fade_music(
        music_name: String,
        transition_duration: float) -> void:
    _on_cross_fade_music_finished()
    
    var previous_music_player := _get_previous_music_player()
    var current_music_player := _get_current_music_player()
    var next_music_player: AudioStreamPlayer = \
            _inflated_music_config[music_name].player if \
            music_name != "" else \
            null
    
    if previous_music_player != null and \
            previous_music_player != current_music_player and \
            previous_music_player.playing:
        Sc.logger.error(
                "Previous music still playing when trying to play new music.")
        previous_music_player.stop()
    
    _previous_music_name = _current_music_name
    _current_music_name = music_name
    previous_music_player = current_music_player
    current_music_player = next_music_player
    
    if previous_music_player == current_music_player and \
            current_music_player != null and \
            current_music_player.playing:
        if !_fade_in_tween.is_active():
            var loud_volume: float = \
                    _inflated_music_config[_current_music_name].volume_db + \
                            GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
                    is_music_enabled else \
                    SILENT_VOLUME_DB
            current_music_player.volume_db = loud_volume
        return
    
    if previous_music_player != null and \
            previous_music_player.playing:
        var previous_loud_volume: float = \
                _inflated_music_config[_previous_music_name].volume_db + \
                        GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
                is_music_enabled else \
                SILENT_VOLUME_DB
        _fade_out_tween.interpolate_property(
                previous_music_player,
                "volume_db",
                previous_loud_volume,
                SILENT_VOLUME_DB,
                transition_duration,
                "ease_in")
        _fade_out_tween.start()
    
    if current_music_player != null:
        set_playback_speed(playback_speed_multiplier)
        current_music_player.volume_db = SILENT_VOLUME_DB
        current_music_player.play()
        
        var current_loud_volume: float = \
                _inflated_music_config[_current_music_name].volume_db + \
                        GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
                is_music_enabled else \
                SILENT_VOLUME_DB
        _fade_in_tween.interpolate_property(
                current_music_player,
                "volume_db",
                SILENT_VOLUME_DB,
                current_loud_volume,
                transition_duration,
                "ease_out")
        _fade_in_tween.start()
    
    emit_signal("music_changed", _current_music_name)


func _on_cross_fade_music_finished() -> void:
    _fade_out_tween.stop_all()
    _fade_in_tween.stop_all()
    
    var previous_music_player := _get_previous_music_player()
    var current_music_player := _get_current_music_player()
    
    if previous_music_player != null and \
            previous_music_player != current_music_player:
        previous_music_player.volume_db = SILENT_VOLUME_DB
        previous_music_player.stop()
    if current_music_player != null:
        var loud_volume := \
                current_music_player.volume_db if \
                is_music_enabled else \
                SILENT_VOLUME_DB
        current_music_player.volume_db = loud_volume


func set_playback_speed(playback_speed_multiplier: float) -> void:
    assert(Sc.audio_manifest.is_arbitrary_music_speed_change_supported or \
            Sc.audio_manifest.is_music_speed_scaled_with_time_scale or \
            Sc.audio_manifest \
                    .is_music_speed_scaled_with_additional_debug_time_scale or \
            playback_speed_multiplier == 1.0)
    if !Sc.audio_manifest.is_arbitrary_music_speed_change_supported and \
            !Sc.audio_manifest.is_music_speed_scaled_with_time_scale and \
            !Sc.audio_manifest \
                    .is_music_speed_scaled_with_additional_debug_time_scale:
        return
    self.playback_speed_multiplier = playback_speed_multiplier
    
    var scaled_speed := get_scaled_speed()
    var current_music_player := _get_current_music_player()
    if current_music_player != null:
        current_music_player.pitch_scale = scaled_speed
    _pitch_shift_effect.pitch_scale = 1.0 / scaled_speed


func get_scaled_speed() -> float:
    var scaled_speed := playback_speed_multiplier
    if Sc.audio_manifest.is_music_speed_scaled_with_time_scale:
        scaled_speed *= Sc.time.time_scale
    if Sc.audio_manifest \
            .is_music_speed_scaled_with_additional_debug_time_scale:
        scaled_speed *= Sc.time.additional_debug_time_scale
    return scaled_speed


func get_playback_position() -> float:
    var current_music_player := _get_current_music_player()
    if current_music_player != null:
        return current_music_player.get_playback_position()
    else:
        return 0.0


func seek(position: float) -> void:
    var current_music_player := _get_current_music_player()
    if current_music_player != null:
        current_music_player.seek(position)


func get_music_name() -> String:
    return _current_music_name


func get_is_music_playing() -> bool:
    return _current_music_name != ""


func _set_is_music_enabled(value: bool) -> void:
    if is_music_enabled == value:
        return
    is_music_enabled = value
    _update_volume()


func _set_is_sound_effects_enabled(value: bool) -> void:
    if is_sound_effects_enabled == value:
        return
    is_sound_effects_enabled = value
    _update_volume()


func _update_volume() -> void:
    for config in _inflated_music_config.values():
        config.player.volume_db = \
                config.volume_db + GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
                is_music_enabled else \
                SILENT_VOLUME_DB
    
    for config in _inflated_sounds_config.values():
        config.player.volume_db = \
                config.volume_db + GLOBAL_AUDIO_VOLUME_OFFSET_DB if \
                is_sound_effects_enabled else \
                SILENT_VOLUME_DB

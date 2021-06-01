class_name Audio
extends Node

signal music_changed(music_name)
signal beat(is_downbeat, beat_index, meter)

const MUSIC_CROSS_FADE_DURATION_SEC := 0.2
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
var scaled_speed := 1.0

var music_playback_position := INF
var time_to_next_beat := INF
var next_beat_index := -1

var is_music_enabled := true setget _set_is_music_enabled
var is_sound_effects_enabled := true setget \
        _set_is_sound_effects_enabled
var is_tracking_beat := false setget _set_is_tracking_beat

func _init() -> void:
    Gs.logger.print("Audio._init")

func _process(_delta_sec: float) -> void:
    if is_tracking_beat and \
            get_is_music_playing():
        _update_music_playback_state()

func register_sounds(
        manifest: Array,
        path_prefix = _DEFAULT_SOUNDS_PATH_PREFIX,
        file_suffix = _DEFAULT_SOUND_FILE_SUFFIX,
        bus_index = _DEFAULT_SOUNDS_BUS_INDEX) -> void:
    _fade_out_tween = ScaffolderTween.new()
    add_child(_fade_out_tween)
    _fade_in_tween = ScaffolderTween.new()
    add_child(_fade_in_tween)
    _fade_in_tween.connect(
            "tween_completed",
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
                config.has("path_prefix") else \
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
        path_prefix = _DEFAULT_MUSIC_PATH_PREFIX,
        file_suffix = _DEFAULT_MUSIC_FILE_SUFFIX,
        bus_index = _DEFAULT_MUSIC_BUS_INDEX) -> void:
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
                config.has("path_prefix") else \
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
    
    if Gs.is_music_speed_change_supported or \
            Gs.is_music_speed_scaled_with_time_scale or \
            Gs.is_music_speed_scaled_with_additional_debug_time_scale:
        _pitch_shift_effect = AudioEffectPitchShift.new()
        AudioServer.add_bus_effect(bus_index, _pitch_shift_effect)
    
    _update_volume()

func play_sound(
        sound_name: String,
        volume_offset := 1.0,
        deferred := false) -> void:
    if deferred:
        call_deferred("_play_sound_deferred", sound_name, volume_offset)
    else:
        _play_sound_deferred(sound_name, volume_offset)

func play_music(
        music_name: String,
        transitions_immediately := false,
        deferred := false) -> void:
    var transition_duration_sec := \
            0.01 if \
            transitions_immediately else \
            MUSIC_CROSS_FADE_DURATION_SEC
    if deferred:
        call_deferred(
                "cross_fade_music",
                music_name,
                transition_duration_sec)
    else:
        cross_fade_music(music_name, transition_duration_sec)

func stop_music() -> bool:
    _clear_music_playback_state()
    var current_music_player := _get_current_music_player()
    if current_music_player != null:
        current_music_player.stop()
        return true
    else:
        return false

func _play_sound_deferred(
        sound_name: String, 
        volume_offset := 1.0) -> void:
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
        transition_duration_sec: float) -> void:
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
        Gs.logger.error(
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
                transition_duration_sec,
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
                transition_duration_sec,
                "ease_out")
        _fade_in_tween.start()
    
    emit_signal("music_changed", _current_music_name)

func _clear_music_playback_state() -> void:
    music_playback_position = INF
    time_to_next_beat = INF
    next_beat_index = -1

func _update_music_playback_state() -> void:
    # Update playback speed to match any change in time scale.
    var old_scaled_speed := scaled_speed
    _update_scaled_speed()
    if scaled_speed != old_scaled_speed:
        set_playback_speed(playback_speed_multiplier)
    
    var beat_duration_unscaled := get_beat_duration_unscaled()
    
    var current_music_player := _get_current_music_player()
    music_playback_position = current_music_player.get_playback_position()
    
    var current_beat_progress := \
            fmod(music_playback_position, beat_duration_unscaled)
    time_to_next_beat = beat_duration_unscaled - current_beat_progress
    
    var previous_beat_index := next_beat_index
    next_beat_index = int(music_playback_position / beat_duration_unscaled) + 1
    
    if previous_beat_index != next_beat_index:
        var meter := get_meter()
        var is_downbeat := (next_beat_index - 1) % meter == 0
        emit_signal(
                "beat",
                is_downbeat,
                next_beat_index - 1,
                meter)

func _on_cross_fade_music_finished(
        _object = null,
        _key = null) -> void:
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
    assert(Gs.is_music_speed_change_supported or \
            Gs.is_music_speed_scaled_with_time_scale or \
            Gs.is_music_speed_scaled_with_additional_debug_time_scale or \
            playback_speed_multiplier == 1.0)
    if !Gs.is_music_speed_change_supported and \
            !Gs.is_music_speed_scaled_with_time_scale and \
            !Gs.is_music_speed_scaled_with_additional_debug_time_scale:
        return
    self.playback_speed_multiplier = playback_speed_multiplier
    
    _update_scaled_speed()
    
    var current_music_player := _get_current_music_player()
    if current_music_player != null:
        current_music_player.pitch_scale = scaled_speed
    _pitch_shift_effect.pitch_scale = 1.0 / scaled_speed

func _update_scaled_speed() -> void:
    scaled_speed = playback_speed_multiplier
    if Gs.is_music_speed_scaled_with_time_scale:
        scaled_speed *= Gs.time.time_scale
    if Gs.is_music_speed_scaled_with_additional_debug_time_scale:
        scaled_speed *= Gs.time.additional_debug_time_scale

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

func get_bpm_unscaled() -> float:
    return _inflated_music_config[_current_music_name].bpm if \
            get_is_music_playing() else \
            INF

func get_bpm_scaled() -> float:
    return get_bpm_unscaled() * scaled_speed

func get_beat_duration_unscaled() -> float:
    return 60.0 / get_bpm_unscaled()

func get_beat_duration_scaled() -> float:
    return 60.0 / get_bpm_scaled()

func get_meter() -> int:
    return _inflated_music_config[_current_music_name].meter if \
            get_is_music_playing() else \
            -1

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

func _set_is_tracking_beat(value: bool) -> void:
    if is_tracking_beat == value:
        return
    is_tracking_beat = value
    if is_tracking_beat and \
            get_is_music_playing():
        pass
    else:
        _clear_music_playback_state()

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

tool
class_name BeatTracker
extends Node


signal beat(is_downbeat, beat_index, meter)


var music_playback_position := INF
var time_to_next_beat := INF
var next_beat_index := -1

var is_tracking_beat := false setget _set_is_tracking_beat
var is_beat_event_emission_paused := false

var _last_music_scaled_speed := 1.0


func _init() -> void:
    Sc.logger.on_global_init(self, "BeatTracker")
    Sc.audio.connect("music_changed", self, "_on_music_changed")


func _process(_delta: float) -> void:
    if Engine.editor_hint:
        return
    if is_tracking_beat and \
            Sc.audio.get_is_music_playing():
        _update_music_beat_state()


func _set_is_tracking_beat(value: bool) -> void:
    if is_tracking_beat == value:
        return
    is_tracking_beat = value
    if is_tracking_beat and \
            Sc.audio.get_is_music_playing():
        pass
    else:
        _clear_music_beat_state()


func _clear_music_beat_state() -> void:
    _last_music_scaled_speed = 1.0
    music_playback_position = INF
    time_to_next_beat = INF
    next_beat_index = -1


func _update_music_beat_state() -> void:
    # Update playback speed to match any change in time scale.
    var next_scaled_speed: float = Sc.audio.get_scaled_speed()
    if _last_music_scaled_speed != next_scaled_speed:
        _last_music_scaled_speed = next_scaled_speed
        Sc.audio.set_playback_speed(Sc.audio.playback_speed_multiplier)
    
    var beat_duration_unscaled := get_beat_duration_unscaled()
    
    music_playback_position = Sc.audio.get_playback_position()
    
    var current_beat_progress := \
            fmod(music_playback_position, beat_duration_unscaled)
    time_to_next_beat = beat_duration_unscaled - current_beat_progress
    
    var previous_beat_index := next_beat_index
    next_beat_index = int(music_playback_position / beat_duration_unscaled) + 1
    
    if previous_beat_index != next_beat_index and \
            !is_beat_event_emission_paused:
        var meter := get_meter()
        var is_downbeat := (next_beat_index - 1) % meter == 0
        _on_beat(is_downbeat, next_beat_index, meter)
        emit_signal(
                "beat",
                is_downbeat,
                next_beat_index - 1,
                meter)


func _on_beat(
        is_downbeat: bool,
        beat_index: int,
        meter: int) -> void:
    if Sc.audio.is_metronome_enabled:
        var sound_name := \
                "tock_high" if \
                is_downbeat else \
                "tock_low"
        Sc.audio.play_sound(sound_name)


func _on_music_changed(music_name: String) -> void:
    if music_name == "":
        _clear_music_beat_state()


func get_bpm_unscaled() -> float:
    return Sc.audio._inflated_music_config[ \
                    Sc.audio._current_music_name].bpm if \
            Sc.audio.get_is_music_playing() else \
            INF


func get_bpm_scaled() -> float:
    return get_bpm_unscaled() * _last_music_scaled_speed


func get_beat_duration_unscaled() -> float:
    return 60.0 / get_bpm_unscaled()


func get_beat_duration_scaled() -> float:
    return 60.0 / get_bpm_scaled()


func get_meter() -> int:
    return Sc.audio._inflated_music_config[ \
                    Sc.audio._current_music_name].meter if \
            Sc.audio.get_is_music_playing() else \
            -1

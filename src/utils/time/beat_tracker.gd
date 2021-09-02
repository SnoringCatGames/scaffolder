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


func calculate_path_beat_hashes_for_current_mode(
        path: PlatformGraphPath,
        path_start_time_scaled: float) -> Array:
    if !is_tracking_beat:
        return []
    
    var elapsed_path_time: float = \
            Sc.time.get_scaled_play_time() - path_start_time_scaled
    
    if Sc.slow_motion.get_is_enabled_or_transitioning():
        return calculate_path_beat_hashes(
                path,
                elapsed_path_time,
                Sc.slow_motion.music.time_to_next_music_beat,
                Sc.slow_motion.music.next_music_beat_index,
                Sc.slow_motion.music.music_beat_duration_unscaled,
                Sc.slow_motion.music.meter)
    else:
        return calculate_path_beat_hashes(
                path,
                elapsed_path_time,
                time_to_next_beat,
                next_beat_index,
                get_beat_duration_unscaled(),
                get_meter())


static func calculate_path_beat_hashes(
        path: PlatformGraphPath,
        elapsed_path_time: float,
        time_to_next_beat: float,
        next_beat_index: int,
        beat_duration: float,
        meter: int) -> Array:
    var time_from_path_start_to_next_beat := \
            time_to_next_beat + elapsed_path_time
    
    time_to_next_beat = fmod(
            time_from_path_start_to_next_beat,
            beat_duration)
    next_beat_index -= \
            int(time_from_path_start_to_next_beat / beat_duration)
    
    var path_time_of_next_beat := time_to_next_beat
    var edge_start_time := 0.0
    
    var beat_count := int(max(
            floor((path.duration - time_to_next_beat) / beat_duration) + 1,
            0))
    var hash_index := 0
    var hashes := []
    hashes.resize(beat_count)
    
    for edge in path.edges:
        var edge_end_time: float = edge_start_time + edge.duration
        
        while edge_end_time >= path_time_of_next_beat:
            var position_before: Vector2
            var position_after: Vector2
            var weight: float
            if edge.trajectory != null:
                var edge_vertices: PoolVector2Array = \
                        Sc.draw._get_edge_trajectory_vertices(
                                edge, false)
                var index_before_hash := \
                        int((path_time_of_next_beat - edge_start_time) / \
                                Time.PHYSICS_TIME_STEP)
                if index_before_hash < edge_vertices.size() - 1:
                    var time_of_index_before := \
                            edge_start_time + \
                            index_before_hash * Time.PHYSICS_TIME_STEP
                    position_before = edge_vertices[index_before_hash]
                    position_after = edge_vertices[index_before_hash + 1]
                    weight = \
                            (path_time_of_next_beat - time_of_index_before) / \
                            Time.PHYSICS_TIME_STEP
                else:
                    position_before = edge_vertices[edge_vertices.size() - 1]
                    position_after = position_before
                    weight = 1.0
            else:
                position_before = edge.get_start()
                position_after = edge.get_end()
                weight = \
                        (path_time_of_next_beat - edge_start_time) / \
                        edge.duration
            
            var position: Vector2 = lerp(
                    position_before,
                    position_after,
                    weight)
            var direction: Vector2 = \
                    (position_after - position_before).normalized()
            var is_downbeat := next_beat_index % meter == 0
            
            hashes[hash_index] = PathBeatPrediction.new(
                    path_time_of_next_beat,
                    position,
                    direction,
                    is_downbeat)
            
            path_time_of_next_beat += beat_duration
            next_beat_index += 1
            hash_index += 1
        
        edge_start_time = edge_end_time
    
    assert(hash_index == hashes.size())
    return hashes

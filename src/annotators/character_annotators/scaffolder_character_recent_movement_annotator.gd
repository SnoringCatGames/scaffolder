class_name ScaffolderCharacterRecentMovementAnnotator
extends Node2D


var character: ScaffolderCharacter

var movement_color_base: Color

# We use this as a circular buffer.
var recent_positions: PoolVector2Array

# We use this as a circular buffer.
var recent_beats: PoolIntArray

var current_position_index := -1

var total_position_count := 0


func _init(character: ScaffolderCharacter) -> void:
    self.character = character
    self.movement_color_base = character.navigation_annotation_color.sample()
    self.recent_positions = PoolVector2Array()
    self.recent_positions.resize(Sc.annotators.params.recent_positions_buffer_size)
    self.recent_beats = PoolIntArray()
    self.recent_beats.resize(Sc.annotators.params.recent_positions_buffer_size)
    
    Sc.beats.connect("beat", self, "_on_beat")
    Sc.slow_motion.music.connect("music_beat", self, "_on_beat")
    
    Sc.audio.connect("music_changed", self, "_on_music_changed")


func _on_beat(
        is_downbeat: bool,
        beat_index: int,
        meter: int) -> void:
    recent_beats[current_position_index] = beat_index


func _on_music_changed(music_name: String) -> void:
    pass


func check_for_update() -> void:
    if !character.did_move_last_frame:
        # Ignore this frame, since there was no movement.
        return
    
    total_position_count += 1
    current_position_index = \
            (current_position_index + 1) % \
            Sc.annotators.params.recent_positions_buffer_size
    
    # Record the new position for the current frame.
    recent_positions[current_position_index] = character.position
    # Record an empty place-holder beat value for the current frame.
    recent_beats[current_position_index] = -1
    
    update()


func _draw() -> void:
    if total_position_count < 2:
        # Don't try to draw the starting position by itself.
        return
    
    # Until we've actually been in enough positions, we won't actually render
    # points for the whole buffer.
    var position_count := \
            min(Sc.annotators.params.recent_positions_buffer_size,
                    total_position_count) as int
    
    # Calculate the oldest index that we'll render. We start drawing here.
    var start_index: int = \
            (current_position_index + 1 - position_count + \
                    Sc.annotators.params.recent_positions_buffer_size) % \
            Sc.annotators.params.recent_positions_buffer_size
    
    var previous_position := recent_positions[start_index]
    
    for i in range(1, position_count):
        # Older positions fade out.
        var opacity: float = \
                i / (position_count as float) * \
                (Sc.annotators.params.recent_movement_opacity_newest - \
                        Sc.annotators.params.recent_movement_opacity_oldest) + \
                Sc.annotators.params.recent_movement_opacity_oldest
        var color := Color.from_hsv(
                movement_color_base.h,
                0.6,
                0.9,
                opacity)
        
        # Calculate our current index in the circular buffer.
        i = (start_index + i) % Sc.annotators.params.recent_positions_buffer_size
        
        _draw_frame(
                i,
                previous_position,
                color,
                opacity)
        
        previous_position = recent_positions[i]


func _draw_frame(
        index: int,
        previous_position: Vector2,
        color: Color,
        opacity: float) -> void:
    var next_position := recent_positions[index]
    
    draw_line(
            previous_position,
            next_position,
            color,
            Sc.annotators.params.recent_movement_stroke_width)
    
    var beat_index: int = recent_beats[index]
    if beat_index >= 0:
        _draw_beat_hash(
                beat_index,
                previous_position,
                next_position,
                opacity)


func _draw_beat_hash(
        beat_index: int,
        previous_position: Vector2,
        next_position: Vector2,
        opacity: float) -> void:
    var is_downbeat: bool = beat_index % Sc.beats.get_meter() == 0
    var hash_length: float
    var stroke_width: float
    if is_downbeat:
        hash_length = Sc.annotators.params.recent_downbeat_hash_length
        stroke_width = Sc.annotators.params.recent_downbeat_hash_stroke_width
    else:
        hash_length = Sc.annotators.params.recent_offbeat_hash_length
        stroke_width = Sc.annotators.params.recent_offbeat_hash_stroke_width
    
    var color := Color.from_hsv(
            movement_color_base.h,
            0.6,
            0.9,
            opacity)
    
    # TODO: Revisit whether this still looks right.
    var next_vs_previous_weight := 1.0
    var hash_position: Vector2 = lerp(
            previous_position,
            next_position,
            next_vs_previous_weight)
    var hash_direction: Vector2 = \
            (next_position - previous_position).tangent().normalized()
    var hash_half_displacement := \
            hash_length * hash_direction / 2.0
    var hash_from := hash_position + hash_half_displacement
    var hash_to := hash_position - hash_half_displacement
    
    self.draw_line(
            hash_from,
            hash_to,
            color,
            stroke_width,
            false)

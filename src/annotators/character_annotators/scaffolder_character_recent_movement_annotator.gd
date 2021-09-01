class_name ScaffolderCharacterRecentMovementAnnotator
extends Node2D


const RECENT_POSITIONS_BUFFER_SIZE := 150

const MOVEMENT_OPACITY_NEWEST := 0.7
const MOVEMENT_OPACITY_OLDEST := 0.01
const MOVEMENT_STROKE_WIDTH := 1

const DOWNBEAT_HASH_LENGTH := 20.0
const OFFBEAT_HASH_LENGTH := 8.0
const DOWNBEAT_HASH_STROKE_WIDTH := 1.0
const OFFBEAT_HASH_STROKE_WIDTH := 1.0

var character: SurfacerCharacter

var movement_color_base: Color

# We use this as a circular buffer.
var recent_positions: PoolVector2Array

# We use this as a circular buffer.
var recent_beats: PoolIntArray

var current_position_index := -1

var total_position_count := 0


func _init(character: SurfacerCharacter) -> void:
    self.character = character
    self.movement_color_base = character.navigation_annotation_color
    self.recent_positions = PoolVector2Array()
    self.recent_positions.resize(RECENT_POSITIONS_BUFFER_SIZE)
    self.recent_beats = PoolIntArray()
    self.recent_beats.resize(RECENT_POSITIONS_BUFFER_SIZE)
    
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
            (current_position_index + 1) % RECENT_POSITIONS_BUFFER_SIZE
    
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
            min(RECENT_POSITIONS_BUFFER_SIZE, total_position_count) as int
    
    # Calculate the oldest index that we'll render. We start drawing here.
    var start_index := \
            (current_position_index + 1 - position_count + \
                    RECENT_POSITIONS_BUFFER_SIZE) % \
            RECENT_POSITIONS_BUFFER_SIZE
    
    var previous_position := recent_positions[start_index]
    
    for i in range(1, position_count):
        # Older positions fade out.
        var opacity := \
                i / (position_count as float) * \
                (MOVEMENT_OPACITY_NEWEST - MOVEMENT_OPACITY_OLDEST) + \
                MOVEMENT_OPACITY_OLDEST
        var color := Color.from_hsv(
                movement_color_base.h,
                0.6,
                0.9,
                opacity)
        
        # Calculate our current index in the circular buffer.
        i = (start_index + i) % RECENT_POSITIONS_BUFFER_SIZE
        
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
            MOVEMENT_STROKE_WIDTH)
    
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
        hash_length = DOWNBEAT_HASH_LENGTH
        stroke_width = DOWNBEAT_HASH_STROKE_WIDTH
    else:
        hash_length = OFFBEAT_HASH_LENGTH
        stroke_width = OFFBEAT_HASH_STROKE_WIDTH
    
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

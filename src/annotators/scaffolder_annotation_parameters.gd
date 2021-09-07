tool
class_name ScaffolderAnnotationParameters
extends Node


# ---

### Click

const click_inner_end_radius := 58.0
const click_outer_end_radius := 100.0

var click_inner_color: Color = Sc.colors.click
var click_outer_color: Color = Sc.colors.click

const click_inner_duration := 0.27
const click_outer_duration := 0.23

### Ruler

var ruler_line_width := 1.0

var ruler_line_color: Color = Sc.colors.opacify(
        Sc.colors.ruler, ScaffolderColors.ALPHA_XFAINT)
var ruler_text_color: Color = Sc.colors.opacify(
        Sc.colors.ruler, ScaffolderColors.ALPHA_FAINT)

### Exclamation mark

var exclamation_mark_width_start := 8.0
var exclamation_mark_length_start := 48.0
var exclamation_mark_stroke_width_start := 3.0
var exclamation_mark_scale_end := 2.0
var exclamation_mark_vertical_offset := 0.0
var exclamation_mark_duration := 1.0
var exclamation_mark_opacity_delay := 0.3

### On-beat hash

const downbeat_duration := 0.35
const offbeat_duration := downbeat_duration

const downbeat_hash_length_default := 5.0
const offbeat_hash_length_default := 3.0
const hash_stroke_width_default := 1.0

const downbeat_length_scale_start := 1.0
const downbeat_length_scale_end := 8.0
const downbeat_width_scale_start := downbeat_length_scale_start
const downbeat_width_scale_end := downbeat_length_scale_end

const offbeat_length_scale_start := downbeat_length_scale_start
const offbeat_length_scale_end := downbeat_length_scale_end
const offbeat_width_scale_start := offbeat_length_scale_start
const offbeat_width_scale_end := offbeat_length_scale_end

const beat_opacity_start := 0.9
const beat_opacity_end := 0.0

### Recent movement

const recent_positions_buffer_size := 150

const recent_movement_opacity_newest := 0.7
const recent_movement_opacity_oldest := 0.01
const recent_movement_stroke_width := 1

const recent_downbeat_hash_length := 20.0
const recent_offbeat_hash_length := 8.0
const recent_downbeat_hash_stroke_width := 1.0
const recent_offbeat_hash_stroke_width := 1.0

### Character position

const character_position_opacity := ScaffolderColors.ALPHA_XFAINT
const character_position_radius := 3.0

const character_collider_opacity := ScaffolderColors.ALPHA_FAINT
const character_collider_thickness := 4.0

# ---


func register_manifest(manifest: Dictionary) -> void:
    for key in manifest:
        assert(self.get(key) != null)
        self.set(key, manifest[key])

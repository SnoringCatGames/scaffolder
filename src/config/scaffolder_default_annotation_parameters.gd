tool
class_name ScaffolderDefaultAnnotationParameters
extends Reference
## NOTE: Any color-related property should instead be found in
##       ScaffolderDefaultColors.


var DEFAULTS := {
    ### Click

    click_inner_end_radius = 58.0,
    click_outer_end_radius = 100.0,

    click_inner_duration = 0.27,
    click_outer_duration = 0.23,

    ### Ruler

    ruler_line_width = 1.0,

    ### Exclamation mark

    exclamation_mark_width_start = 8.0,
    exclamation_mark_length_start = 48.0,
    exclamation_mark_stroke_width_start = 3.0,
    exclamation_mark_scale_end = 2.0,
    exclamation_mark_vertical_offset = 0.0,
    exclamation_mark_duration = 1.0,
    exclamation_mark_opacity_delay = 0.3,

    ### On-beat hash

    downbeat_duration = 0.35,
    offbeat_duration = downbeat_duration,

    downbeat_hash_length_default = 5.0,
    offbeat_hash_length_default = 3.0,
    hash_stroke_width_default = 1.0,

    downbeat_length_scale_start = 1.0,
    downbeat_length_scale_end = 8.0,
    downbeat_width_scale_start = downbeat_length_scale_start,
    downbeat_width_scale_end = downbeat_length_scale_end,

    offbeat_length_scale_start = downbeat_length_scale_start,
    offbeat_length_scale_end = downbeat_length_scale_end,
    offbeat_width_scale_start = offbeat_length_scale_start,
    offbeat_width_scale_end = offbeat_length_scale_end,

    ### Recent movement

    recent_positions_buffer_size = 150,

    recent_movement_stroke_width = 1,

    recent_downbeat_hash_length = 20.0,
    recent_offbeat_hash_length = 8.0,
    recent_downbeat_hash_stroke_width = 1.0,
    recent_offbeat_hash_stroke_width = 1.0,

    ### Character position

    character_position_radius = 3.0,

    character_collider_thickness = 4.0,
},

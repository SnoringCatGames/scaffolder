tool
class_name ScaffolderDefaultColors
extends Reference


var DEFAULTS := {
    ### Click

    click_inner_color = ColorFactory.palette("click"),
    click_outer_color = ColorFactory.palette("click"),

    ### Ruler

    ruler_line_color = ColorFactory.opacify("ruler", ColorConfig.ALPHA_XFAINT),
    ruler_text_color = ColorFactory.opacify("ruler", ColorConfig.ALPHA_FAINT),

    ### On-beat hash

    beat_opacity_start = 0.9,
    beat_opacity_end = 0.0,

    ### Recent movement

    recent_movement_opacity_newest = 0.7,
    recent_movement_opacity_oldest = 0.01,

    ### Character position

    character_position_opacity = ColorConfig.ALPHA_XFAINT,

    character_collider_opacity = ColorConfig.ALPHA_FAINT,
}

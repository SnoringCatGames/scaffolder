tool
class_name ScaffolderDefaultColors
extends Reference


### Click

var click_inner_color := ColorFactory.palette("click")
var click_outer_color := ColorFactory.palette("click")

### Ruler

var ruler_line_color := ColorFactory.opacify("ruler", ColorConfig.ALPHA_XFAINT)
var ruler_text_color := ColorFactory.opacify("ruler", ColorConfig.ALPHA_FAINT)

### On-beat hash

var beat_opacity_start := 0.9
var beat_opacity_end := 0.0

### Recent movement

var recent_movement_opacity_newest := 0.7
var recent_movement_opacity_oldest := 0.01

### Character position

var character_position_opacity := ColorConfig.ALPHA_XFAINT

var character_collider_opacity := ColorConfig.ALPHA_FAINT

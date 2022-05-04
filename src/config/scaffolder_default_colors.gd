tool
class_name ScaffolderDefaultColors
extends Reference


### GUIs

const _COLOR_BACKGROUND := Color("404040")
const _COLOR_BACKGROUND_LIGHTER := Color("4d4d4d")
const _COLOR_BACKGROUND_DARKER := Color("383838")

const _COLOR_TEXT := Color("eeeeee")
const _COLOR_HEADER := Color("d8d8d8")
const _COLOR_FOCUS := Color("f8f8f8")

const _COLOR_BUTTON := Color("707070")
const _COLOR_BUTTON_LIGHTER := Color("969696")
const _COLOR_BUTTON_DARKER := Color("5b5b5b")

const _COLOR_SHADOW := Color("88000000")

const _HUD_KEY_VALUE_BOX_MODULATE_COLOR := Color(2.0, 2.0, 2.0, 1.0)
const _BUTTON_PULSE_MODULATE_COLOR := Color(2.0, 2.0, 2.0, 1.0)

var transparent := ColorConfig.TRANSPARENT
var white := Color.white
var black := Color.black
var purple := Color(0.734, 0.277, 1.0)
var teal := Color(0.277, 0.973, 1.0)
var red := Color(1.0, 0.305, 0.277)
var orange := Color(1.0, 0.648, 0.277)

var highlight_green := Color("cc6abe30")
var highlight_light_blue := Color("ff1cb0ff")
var highlight_dark_blue := Color("cc003066")
var highlight_disabled := Color("77292929")
var highlight_red := Color("ffcc2c16")

# Should match Project Settings > Application > Boot Splash > Bg Color.
var default_splash_background := Color("202531")
# Should match Project Settings > Rendering > Environment > Default Clear Color.
var background := _COLOR_BACKGROUND

var boot_splash_background := ColorFactory.palette("default_splash_background")
var text := _COLOR_TEXT
var header := _COLOR_HEADER
var focus_border := _COLOR_FOCUS
var link_normal := _COLOR_BUTTON_LIGHTER
var link_hover := _COLOR_BUTTON
var link_pressed := _COLOR_BUTTON_DARKER
var button_normal := _COLOR_BUTTON
var button_pulse_modulate := _BUTTON_PULSE_MODULATE_COLOR
var button_disabled := _COLOR_BUTTON_LIGHTER
var button_focused := _COLOR_BUTTON_LIGHTER
var button_hover := _COLOR_BUTTON_LIGHTER
var button_pressed := _COLOR_BUTTON_DARKER
var button_border := _COLOR_TEXT
var dropdown_normal := _COLOR_BACKGROUND
var dropdown_disabled := _COLOR_BACKGROUND_LIGHTER
var dropdown_focused := _COLOR_BACKGROUND_LIGHTER
var dropdown_hover := _COLOR_BACKGROUND_LIGHTER
var dropdown_pressed := _COLOR_BACKGROUND_DARKER
var dropdown_border := _COLOR_BACKGROUND_DARKER
var tooltip := _COLOR_BACKGROUND
var tooltip_bg := _COLOR_TEXT
var popup_background := _COLOR_BACKGROUND_LIGHTER
var scroll_bar_background := _COLOR_BACKGROUND_LIGHTER
var scroll_bar_grabber_normal := _COLOR_BUTTON
var scroll_bar_grabber_hover := _COLOR_BUTTON_LIGHTER
var scroll_bar_grabber_pressed := _COLOR_BUTTON_DARKER
var slider_background := _COLOR_BACKGROUND_DARKER
var zebra_stripe_even_row := _COLOR_BACKGROUND_LIGHTER
var overlay_panel_background := _COLOR_BACKGROUND_DARKER
var overlay_panel_border := _COLOR_TEXT
var notification_panel_background := _COLOR_BACKGROUND_DARKER
var notification_panel_border := _COLOR_TEXT
var header_panel_background := _COLOR_BACKGROUND
var screen_border := _COLOR_TEXT
var shadow := _COLOR_SHADOW

var click := ColorFactory.opacify("white", ColorConfig.ALPHA_SLIGHTLY_FAINT)
var ruler := ColorFactory.palette("white")

### Annotations

# Click
var click_inner_color := ColorFactory.palette("click")
var click_outer_color := ColorFactory.palette("click")

# Ruler
var ruler_line_color := ColorFactory.opacify("ruler", ColorConfig.ALPHA_XFAINT)
var ruler_text_color := ColorFactory.opacify("ruler", ColorConfig.ALPHA_FAINT)

# On-beat hash
var beat_opacity_start := 0.9
var beat_opacity_end := 0.0

# Recent movement
var recent_movement_opacity_newest := 0.7
var recent_movement_opacity_oldest := 0.01

# Character position
var character_position_opacity := ColorConfig.ALPHA_XFAINT
var character_collider_opacity := ColorConfig.ALPHA_FAINT

class_name ScaffolderColors
extends Node


# Alpha values (from 0 to 1).
const ALPHA_SOLID := 1.0
const ALPHA_SLIGHTLY_FAINT := 0.7
const ALPHA_FAINT := 0.5
const ALPHA_XFAINT := 0.3
const ALPHA_XXFAINT := 0.1
const ALPHA_XXXFAINT := 0.03

# --- Configured colors ---

var font: Color

var header_font: Color

# Should match Project Settings > Application > Boot Splash > Bg Color
# Should match Project Settings > Rendering > Environment > Default Clear Color
var background: Color

var button: Color

var shiny_button_highlight: Color

var dropdown: Color

var tooltip: Color
var tooltip_bg: Color

var button_disabled_hsv_delta: Dictionary
var button_focused_hsv_delta: Dictionary
var button_hover_hsv_delta: Dictionary
var button_pressed_hsv_delta: Dictionary

var dropdown_disabled_hsv_delta: Dictionary
var dropdown_focused_hsv_delta: Dictionary
var dropdown_hover_hsv_delta: Dictionary
var dropdown_pressed_hsv_delta: Dictionary

var popup_background_hsv_delta: Dictionary

var zebra_stripe_even_row_hsv_delta: Dictionary

var scroll_bar_background_hsv_delta: Dictionary
var scroll_bar_grabber_normal_hsv_delta: Dictionary
var scroll_bar_grabber_hover_hsv_delta: Dictionary
var scroll_bar_grabber_pressed_hsv_delta: Dictionary

var _defaults := {
    font = Color("eeeeee"),
    header_font = Color("eeeeee"),
    background = Color("404040"),
    button = Color("707070"),
    shiny_button_highlight = Color("d0d0d0"),
    dropdown = Color("404040"),
    tooltip = Color("080808"),
    tooltip_bg = Color("bbbbbb"),
    
    button_disabled_hsv_delta = {h=0.0, s=0.0, v=0.15, a=-0.2},
    button_focused_hsv_delta = {h=-0.03, s=0.0, v=0.15},
    button_hover_hsv_delta = {h=-0.03, s=0.0, v=0.15},
    button_pressed_hsv_delta = {h=0.05, s=0.0, v=-0.1},
    dropdown_disabled_hsv_delta = {h=0.0, s=0.0, v=0.15, a=-0.2},
    dropdown_focused_hsv_delta = {h=0.05, s=0.0, v=0.15},
    dropdown_hover_hsv_delta = {h=0.05, s=0.0, v=0.15},
    dropdown_pressed_hsv_delta = {h=-0.05, s=0.0, v=-0.1},
    popup_background_hsv_delta = {h=0.0, s=0.0, v=0.05},
    zebra_stripe_even_row_hsv_delta = {h=0.01, s=0.0, v=0.05},
    scroll_bar_background_hsv_delta = {h=0.0, s=0.0, v=-0.1},
    scroll_bar_grabber_normal_hsv_delta = {h=0.05, s=0.0, v=-0.1},
    scroll_bar_grabber_hover_hsv_delta = {h=0.0, s=0.0, v=0.2},
    scroll_bar_grabber_pressed_hsv_delta = {h=0.08, s=0.0, v=-0.1},
}

# --- Derived colors ---

var button_normal: Color
var button_disabled: Color
var button_focused: Color
var button_hover: Color
var button_pressed: Color

var dropdown_normal: Color
var dropdown_disabled: Color
var dropdown_focused: Color
var dropdown_hover: Color
var dropdown_pressed: Color

var popup_background: Color

var zebra_stripe_even_row: Color

var scroll_bar_background: Color
var scroll_bar_grabber_normal: Color
var scroll_bar_grabber_hover: Color
var scroll_bar_grabber_pressed: Color

# ---


func register_colors(manifest: Dictionary) -> void:
    for key in _defaults:
        var value = \
                manifest[key] if \
                manifest.has(key) else \
                _defaults[key]
        self.set(key, value)
    
    _derive_colors()


func _derive_colors() -> void:
    Gs.colors.button_normal = Gs.colors.button
    Gs.colors.button_disabled = _derive_color_from_hsva_delta(
            Gs.colors.button, Gs.colors.button_disabled_hsv_delta)
    Gs.colors.button_focused = _derive_color_from_hsva_delta(
            Gs.colors.button, Gs.colors.button_focused_hsv_delta)
    Gs.colors.button_hover = _derive_color_from_hsva_delta(
            Gs.colors.button, Gs.colors.button_hover_hsv_delta)
    Gs.colors.button_pressed = _derive_color_from_hsva_delta(
            Gs.colors.button, Gs.colors.button_pressed_hsv_delta)
    
    Gs.colors.dropdown_normal = Gs.colors.dropdown
    Gs.colors.dropdown_disabled = _derive_color_from_hsva_delta(
            Gs.colors.dropdown, Gs.colors.dropdown_disabled_hsv_delta)
    Gs.colors.dropdown_focused = _derive_color_from_hsva_delta(
            Gs.colors.dropdown, Gs.colors.dropdown_focused_hsv_delta)
    Gs.colors.dropdown_hover = _derive_color_from_hsva_delta(
            Gs.colors.dropdown, Gs.colors.dropdown_hover_hsv_delta)
    Gs.colors.dropdown_pressed = _derive_color_from_hsva_delta(
            Gs.colors.dropdown, Gs.colors.dropdown_pressed_hsv_delta)
    
    Gs.colors.popup_background = _derive_color_from_hsva_delta(
            Gs.colors.background, Gs.colors.popup_background_hsv_delta)
    
    Gs.colors.zebra_stripe_even_row = \
            _derive_color_from_hsva_delta(
                    Gs.colors.background,
                    Gs.colors.zebra_stripe_even_row_hsv_delta)
    
    Gs.colors.scroll_bar_background = \
            _derive_color_from_hsva_delta(
                    Gs.colors.background,
                    Gs.colors.scroll_bar_background_hsv_delta)
    Gs.colors.scroll_bar_grabber_normal = \
            _derive_color_from_hsva_delta(
                    Gs.colors.button,
                    Gs.colors.scroll_bar_grabber_normal_hsv_delta)
    Gs.colors.scroll_bar_grabber_hover = \
            _derive_color_from_hsva_delta(
                    Gs.colors.scroll_bar_grabber_normal,
                    Gs.colors.scroll_bar_grabber_hover_hsv_delta)
    Gs.colors.scroll_bar_grabber_pressed = \
            _derive_color_from_hsva_delta(
                    Gs.colors.scroll_bar_grabber_normal,
                    Gs.colors.scroll_bar_grabber_pressed_hsv_delta)


func _derive_color_from_hsva_delta(
        base_color: Color,
        delta_hsva: Dictionary) -> Color:
    return Color.from_hsv(
            base_color.h + delta_hsva.h,
            base_color.s + delta_hsva.s,
            base_color.v + delta_hsva.v,
            base_color.a + delta_hsva.a if \
                    delta_hsva.has("a") else \
                    base_color.a)


func opacify(base_color_or_name, opacity: float) -> Color:
    var color: Color = \
            base_color_or_name if \
            base_color_or_name is Color else \
            Gs.colors[base_color_or_name]
    color.a = opacity
    return color


static func static_opacify(base_color: Color, opacity: float) -> Color:
    base_color.a = opacity
    return base_color

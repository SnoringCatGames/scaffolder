class_name ScaffolderColors
extends Node


# Alpha values (from 0 to 1).
const ALPHA_SOLID := 1.0
const ALPHA_SLIGHTLY_FAINT := 0.7
const ALPHA_FAINT := 0.5
const ALPHA_XFAINT := 0.3
const ALPHA_XXFAINT := 0.1
const ALPHA_XXXFAINT := 0.03

const DEFAULT_BOOT_SPLASH_BACKGROUND_COLOR := Color("202531")

# --- Configured colors ---

# Should match Project Settings > Application > Boot Splash > Bg Color
var boot_splash_background: Color

# Should match Project Settings > Rendering > Environment > Default Clear Color
var background: Color

var text: Color

var header: Color

var button_normal: Color
var button_disabled: Color
var button_focused: Color
var button_hover: Color
var button_pressed: Color
var button_border: Color

var scaffolder_button_highlight: Color

var link_normal: Color
var link_hover: Color
var link_pressed: Color

var dropdown_normal: Color
var dropdown_disabled: Color
var dropdown_focused: Color
var dropdown_hover: Color
var dropdown_pressed: Color
var dropdown_border: Color

var popup_background: Color

var tooltip: Color
var tooltip_bg: Color

var zebra_stripe_even_row: Color

var overlay_panel_body_background: Color
var overlay_panel_header_background: Color
var overlay_panel_border: Color

var scroll_bar_background: Color
var scroll_bar_grabber_normal: Color
var scroll_bar_grabber_hover: Color
var scroll_bar_grabber_pressed: Color

var screen_border: Color

# --- Optionally, you can configure some colors as relative to others. ---

var button_disabled_hsv_delta: Dictionary
var button_focused_hsv_delta: Dictionary
var button_hover_hsv_delta: Dictionary
var button_pressed_hsv_delta: Dictionary
var button_border_hsv_delta: Dictionary

var dropdown_disabled_hsv_delta: Dictionary
var dropdown_focused_hsv_delta: Dictionary
var dropdown_hover_hsv_delta: Dictionary
var dropdown_pressed_hsv_delta: Dictionary
var dropdown_border_hsv_delta: Dictionary

var popup_background_hsv_delta: Dictionary

var zebra_stripe_even_row_hsv_delta: Dictionary

var overlay_panel_body_background_hsv_delta: Dictionary
var overlay_panel_header_background_hsv_delta: Dictionary

var scroll_bar_background_hsv_delta: Dictionary
var scroll_bar_grabber_normal_hsv_delta: Dictionary
var scroll_bar_grabber_hover_hsv_delta: Dictionary
var scroll_bar_grabber_pressed_hsv_delta: Dictionary

var screen_border_hsv_delta: Dictionary

# ---

var _defaults := {
    boot_splash_background = DEFAULT_BOOT_SPLASH_BACKGROUND_COLOR,
    background = Color("404040"),
    text = Color("eeeeee"),
    header = Color("eeeeee"),
    link_normal = Color("707070"),
    link_hover = Color("969696"),
    link_pressed = Color("969696"),
    button_normal = Color("707070"),
    button_disabled = Color("969696"),
    button_focused = Color("969696"),
    button_hover = Color("969696"),
    button_pressed = Color("969696"),
    button_border = Color("969696"),
    scaffolder_button_highlight = Color("d0d0d0"),
    dropdown_normal = Color("404040"),
    dropdown_disabled = Color("4d4d4d"),
    dropdown_focused = Color("4d4d4d"),
    dropdown_hover = Color("4d4d4d"),
    dropdown_pressed = Color("4d4d4d"),
    dropdown_border = Color("4d4d4d"),
    tooltip = Color("080808"),
    tooltip_bg = Color("bbbbbb"),
    popup_background = Color("4d4d4d"),
    scroll_bar_background = Color("4d4d4d"),
    scroll_bar_grabber_normal = Color("707070"),
    scroll_bar_grabber_hover = Color("969696"),
    scroll_bar_grabber_pressed = Color("969696"),
    zebra_stripe_even_row = Color("4d4d4d"),
    overlay_panel_body_background = Color("141414"),
    overlay_panel_header_background = Color("282828"),
    overlay_panel_border = Color("eeeeee"),
    screen_border = Color("404040"),
}

# ---


func _init() -> void:
    Gs.logger.on_global_init(self, "ScaffolderColors")


func register_manifest(manifest: Dictionary) -> void:
    for key in _defaults:
        var value = \
                manifest[key] if \
                manifest.has(key) else \
                _defaults[key]
        self.set(key, value)
    
    _derive_colors()


func _derive_colors() -> void:
    if !Gs.colors.button_disabled_hsv_delta.empty():
        Gs.colors.button_disabled = _derive_color_from_hsva_delta(
                Gs.colors.button_normal,
                Gs.colors.button_disabled_hsv_delta)
    if !Gs.colors.button_focused_hsv_delta.empty():
        Gs.colors.button_focused = _derive_color_from_hsva_delta(
                Gs.colors.button_normal,
                Gs.colors.button_focused_hsv_delta)
    if !Gs.colors.button_hover_hsv_delta.empty():
        Gs.colors.button_hover = _derive_color_from_hsva_delta(
                Gs.colors.button_normal,
                Gs.colors.button_hover_hsv_delta)
    if !Gs.colors.button_pressed_hsv_delta.empty():
        Gs.colors.button_pressed = _derive_color_from_hsva_delta(
                Gs.colors.button_normal,
                Gs.colors.button_pressed_hsv_delta)
    if !Gs.colors.button_border_hsv_delta.empty():
        Gs.colors.button_border = _derive_color_from_hsva_delta(
                Gs.colors.button_normal,
                Gs.colors.button_border_hsv_delta)
    
    if !Gs.colors.dropdown_disabled_hsv_delta.empty():
        Gs.colors.dropdown_disabled = _derive_color_from_hsva_delta(
                Gs.colors.dropdown_normal,
                Gs.colors.dropdown_disabled_hsv_delta)
    if !Gs.colors.dropdown_focused_hsv_delta.empty():
        Gs.colors.dropdown_focused = _derive_color_from_hsva_delta(
                Gs.colors.dropdown_normal,
                Gs.colors.dropdown_focused_hsv_delta)
    if !Gs.colors.dropdown_hover_hsv_delta.empty():
        Gs.colors.dropdown_hover = _derive_color_from_hsva_delta(
                Gs.colors.dropdown_normal,
                Gs.colors.dropdown_hover_hsv_delta)
    if !Gs.colors.dropdown_pressed_hsv_delta.empty():
        Gs.colors.dropdown_pressed = _derive_color_from_hsva_delta(
                Gs.colors.dropdown_normal,
                Gs.colors.dropdown_pressed_hsv_delta)
    if !Gs.colors.dropdown_border_hsv_delta.empty():
        Gs.colors.dropdown_border = _derive_color_from_hsva_delta(
                Gs.colors.dropdown_normal,
                Gs.colors.dropdown_border_hsv_delta)
    
    if !Gs.colors.popup_background_hsv_delta.empty():
        Gs.colors.popup_background = _derive_color_from_hsva_delta(
                Gs.colors.background,
                Gs.colors.popup_background_hsv_delta)
    
    if !Gs.colors.zebra_stripe_even_row_hsv_delta.empty():
        Gs.colors.zebra_stripe_even_row = \
                _derive_color_from_hsva_delta(
                        Gs.colors.background,
                        Gs.colors.zebra_stripe_even_row_hsv_delta)
    
    if !Gs.colors.overlay_panel_body_background_hsv_delta.empty():
        Gs.colors.overlay_panel_body_background = \
                _derive_color_from_hsva_delta(
                        Gs.colors.background,
                        Gs.colors.overlay_panel_body_background_hsv_delta)
    if !Gs.colors.overlay_panel_header_background_hsv_delta.empty():
        Gs.colors.overlay_panel_header_background = \
                _derive_color_from_hsva_delta(
                        Gs.colors.background,
                        Gs.colors.overlay_panel_header_background_hsv_delta)
    
    if !Gs.colors.scroll_bar_background_hsv_delta.empty():
        Gs.colors.scroll_bar_background = \
                _derive_color_from_hsva_delta(
                        Gs.colors.background,
                        Gs.colors.scroll_bar_background_hsv_delta)
    if !Gs.colors.scroll_bar_grabber_normal_hsv_delta.empty():
        Gs.colors.scroll_bar_grabber_normal = \
                _derive_color_from_hsva_delta(
                        Gs.colors.button_normal,
                        Gs.colors.scroll_bar_grabber_normal_hsv_delta)
    if !Gs.colors.scroll_bar_grabber_hover_hsv_delta.empty():
        Gs.colors.scroll_bar_grabber_hover = \
                _derive_color_from_hsva_delta(
                        Gs.colors.scroll_bar_grabber_normal,
                        Gs.colors.scroll_bar_grabber_hover_hsv_delta)
    if !Gs.colors.scroll_bar_grabber_pressed_hsv_delta.empty():
        Gs.colors.scroll_bar_grabber_pressed = \
                _derive_color_from_hsva_delta(
                        Gs.colors.scroll_bar_grabber_normal,
                        Gs.colors.scroll_bar_grabber_pressed_hsv_delta)
    
    if !Gs.colors.screen_border_hsv_delta.empty():
        Gs.colors.screen_border = _derive_color_from_hsva_delta(
                Gs.colors.background,
                Gs.colors.screen_border_hsv_delta)


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

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

# Only used if Sc.gui.is_suggested_button_color_pulse_shown is enabled, and
# buttons are configured to use flat-color style-boxes.
var button_flat_pulse: Color
# Only used if Sc.gui.is_suggested_button_color_pulse_shown is enabled, and
# buttons are configured to use nine-patch-texture style-boxes.
var button_texture_modulate: Color

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

var overlay_panel_background: Color
var overlay_panel_border: Color

var header_panel_background: Color

var scroll_bar_background: Color
var scroll_bar_grabber_normal: Color
var scroll_bar_grabber_hover: Color
var scroll_bar_grabber_pressed: Color

var slider_background: Color

var screen_border: Color

var shadow: Color

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

var overlay_panel_background_hsv_delta: Dictionary
var header_panel_background_hsv_delta: Dictionary

var scroll_bar_background_hsv_delta: Dictionary
var scroll_bar_grabber_normal_hsv_delta: Dictionary
var scroll_bar_grabber_hover_hsv_delta: Dictionary
var scroll_bar_grabber_pressed_hsv_delta: Dictionary

var slider_background_hsv_delta: Dictionary

var screen_border_hsv_delta: Dictionary

# ---

var _defaults := {
    boot_splash_background = DEFAULT_BOOT_SPLASH_BACKGROUND_COLOR,
    background = Color("404040"),
    text = Color("eeeeee"),
    header = Color("eeeeee"),
    link_normal = Color("707070"),
    link_hover = Color("969696"),
    link_pressed = Color("5b5b5b"),
    button_normal = Color("707070"),
    button_disabled = Color("969696"),
    button_focused = Color("969696"),
    button_hover = Color("969696"),
    button_pressed = Color("5b5b5b"),
    button_border = Color("969696"),
    button_texture_modulate = Color(2, 2, 2, 1),
    button_flat_pulse = Color("d0d0d0"),
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
    scroll_bar_grabber_pressed = Color("5b5b5b"),
    slider_background = Color("4d4d4d"),
    zebra_stripe_even_row = Color("4d4d4d"),
    overlay_panel_background = Color("141414"),
    overlay_panel_border = Color("eeeeee"),
    header_panel_background = Color("282828"),
    screen_border = Color("404040"),
    shadow = Color("88000000"),
}

# ---


func _init() -> void:
    Sc.logger.on_global_init(self, "ScaffolderColors")


func register_manifest(manifest: Dictionary) -> void:
    for key in _defaults:
        var value = \
                manifest[key] if \
                manifest.has(key) else \
                _defaults[key]
        self.set(key, value)
    
    _derive_colors()


func _derive_colors() -> void:
    if !Sc.colors.button_disabled_hsv_delta.empty():
        Sc.colors.button_disabled = _derive_color_from_hsva_delta(
                Sc.colors.button_normal,
                Sc.colors.button_disabled_hsv_delta)
    if !Sc.colors.button_focused_hsv_delta.empty():
        Sc.colors.button_focused = _derive_color_from_hsva_delta(
                Sc.colors.button_normal,
                Sc.colors.button_focused_hsv_delta)
    if !Sc.colors.button_hover_hsv_delta.empty():
        Sc.colors.button_hover = _derive_color_from_hsva_delta(
                Sc.colors.button_normal,
                Sc.colors.button_hover_hsv_delta)
    if !Sc.colors.button_pressed_hsv_delta.empty():
        Sc.colors.button_pressed = _derive_color_from_hsva_delta(
                Sc.colors.button_normal,
                Sc.colors.button_pressed_hsv_delta)
    if !Sc.colors.button_border_hsv_delta.empty():
        Sc.colors.button_border = _derive_color_from_hsva_delta(
                Sc.colors.button_normal,
                Sc.colors.button_border_hsv_delta)
    
    if !Sc.colors.dropdown_disabled_hsv_delta.empty():
        Sc.colors.dropdown_disabled = _derive_color_from_hsva_delta(
                Sc.colors.dropdown_normal,
                Sc.colors.dropdown_disabled_hsv_delta)
    if !Sc.colors.dropdown_focused_hsv_delta.empty():
        Sc.colors.dropdown_focused = _derive_color_from_hsva_delta(
                Sc.colors.dropdown_normal,
                Sc.colors.dropdown_focused_hsv_delta)
    if !Sc.colors.dropdown_hover_hsv_delta.empty():
        Sc.colors.dropdown_hover = _derive_color_from_hsva_delta(
                Sc.colors.dropdown_normal,
                Sc.colors.dropdown_hover_hsv_delta)
    if !Sc.colors.dropdown_pressed_hsv_delta.empty():
        Sc.colors.dropdown_pressed = _derive_color_from_hsva_delta(
                Sc.colors.dropdown_normal,
                Sc.colors.dropdown_pressed_hsv_delta)
    if !Sc.colors.dropdown_border_hsv_delta.empty():
        Sc.colors.dropdown_border = _derive_color_from_hsva_delta(
                Sc.colors.dropdown_normal,
                Sc.colors.dropdown_border_hsv_delta)
    
    if !Sc.colors.popup_background_hsv_delta.empty():
        Sc.colors.popup_background = _derive_color_from_hsva_delta(
                Sc.colors.background,
                Sc.colors.popup_background_hsv_delta)
    
    if !Sc.colors.zebra_stripe_even_row_hsv_delta.empty():
        Sc.colors.zebra_stripe_even_row = \
                _derive_color_from_hsva_delta(
                        Sc.colors.background,
                        Sc.colors.zebra_stripe_even_row_hsv_delta)
    
    if !Sc.colors.overlay_panel_background_hsv_delta.empty():
        Sc.colors.overlay_panel_background = \
                _derive_color_from_hsva_delta(
                        Sc.colors.background,
                        Sc.colors.overlay_panel_background_hsv_delta)
    if !Sc.colors.header_panel_background_hsv_delta.empty():
        Sc.colors.header_panel_background = \
                _derive_color_from_hsva_delta(
                        Sc.colors.background,
                        Sc.colors.header_panel_background_hsv_delta)
    
    if !Sc.colors.scroll_bar_background_hsv_delta.empty():
        Sc.colors.scroll_bar_background = \
                _derive_color_from_hsva_delta(
                        Sc.colors.background,
                        Sc.colors.scroll_bar_background_hsv_delta)
    if !Sc.colors.scroll_bar_grabber_normal_hsv_delta.empty():
        Sc.colors.scroll_bar_grabber_normal = \
                _derive_color_from_hsva_delta(
                        Sc.colors.button_normal,
                        Sc.colors.scroll_bar_grabber_normal_hsv_delta)
    if !Sc.colors.scroll_bar_grabber_hover_hsv_delta.empty():
        Sc.colors.scroll_bar_grabber_hover = \
                _derive_color_from_hsva_delta(
                        Sc.colors.scroll_bar_grabber_normal,
                        Sc.colors.scroll_bar_grabber_hover_hsv_delta)
    if !Sc.colors.scroll_bar_grabber_pressed_hsv_delta.empty():
        Sc.colors.scroll_bar_grabber_pressed = \
                _derive_color_from_hsva_delta(
                        Sc.colors.scroll_bar_grabber_normal,
                        Sc.colors.scroll_bar_grabber_pressed_hsv_delta)
    
    if !Sc.colors.slider_background_hsv_delta.empty():
        Sc.colors.slider_background = \
                _derive_color_from_hsva_delta(
                        Sc.colors.background,
                        Sc.colors.slider_background_hsv_delta)
    
    if !Sc.colors.screen_border_hsv_delta.empty():
        Sc.colors.screen_border = _derive_color_from_hsva_delta(
                Sc.colors.background,
                Sc.colors.screen_border_hsv_delta)


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
            Sc.colors[base_color_or_name]
    color.a = opacity
    return color


static func static_opacify(base_color: Color, opacity: float) -> Color:
    base_color.a = opacity
    return base_color

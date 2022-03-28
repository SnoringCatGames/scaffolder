tool
class_name ColorPalette
extends Node
## -   This is a mapping from color names to color values.[br]
## -   These color mappings are referenced by PaletteColorConfig instances.
## -   The registered values could be either Color or ColorConfig instances.


# Dictionary<String, Color|ColorConfig>
var _DEFAULT_COLORS := {
    transparent = ColorConfig.TRANSPARENT,
    white = Color.white,
    black = Color.white,
    purple = Color(0.734, 0.277, 1.0),
    teal = Color(0.277, 0.973, 1.0),
    red = Color(1.0, 0.305, 0.277),
    orange = Color(1.0, 0.648, 0.277),
    
    # Should match Project Settings > Application > Boot Splash > Bg Color.
    default_splash_background = Color("202531"),
    # Should match Project Settings > Rendering > Environment > Default Clear Color.
    background = Color("404040"),
    
    boot_splash_background = ColorFactory.palette("default_splash_background"),
    text = Color("eeeeee"),
    header = Color("eeeeee"),
    focus_border = Color("eeeeee"),
    link_normal = Color("707070"),
    link_hover = Color("969696"),
    link_pressed = Color("5b5b5b"),
    button_normal = Color("707070"),
    button_disabled = Color("969696"),
    button_focused = Color("969696"),
    button_hover = Color("969696"),
    button_pressed = Color("5b5b5b"),
    button_border = Color("969696"),
    button_pulse_modulate = Color(2.0, 2.0, 2.0, 1.0),
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
    notification_panel_background = Color("141414"),
    notification_panel_border = Color("eeeeee"),
    header_panel_background = Color("282828"),
    screen_border = Color("404040"),
    shadow = Color("88000000"),
    click = ColorFactory.opacify("white", ColorConfig.ALPHA_SLIGHTLY_FAINT),
    ruler = ColorFactory.palette("white"),
}

const _MAX_PALETTE_REDIRECT_DEPTH := 5

# Dictionary<String, Color>
var _colors := {}


func _register_defaults() -> void:
    for key in _DEFAULT_COLORS:
        _colors[key] = _DEFAULT_COLORS[key]


func set_color(
        key: String,
        color: Color) -> void:
    _colors[key] = color


func get_color(
        key: String,
        _redirect_depth := 0) -> Color:
    if _redirect_depth > _MAX_PALETTE_REDIRECT_DEPTH:
        Sc.logger.error(
            ("ColorPalette contains a redirect chain that is too long: " +
            "key=%s") % key)
        return ColorConfig.TRANSPARENT
    var color = _colors[key]
    if color is ColorConfig:
        return color.sample(_redirect_depth + 1)
    else:
        return color


func _destroy() -> void:
    _colors.clear()

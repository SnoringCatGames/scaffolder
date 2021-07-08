class_name ScaffolderStyles
extends Node


const OVERLAY_PANEL_BODY_STYLEBOX := \
        preload("res://addons/scaffolder/src/gui/overlay_panel_body_stylebox.tres")
const OVERLAY_PANEL_HEADER_STYLEBOX := \
        preload("res://addons/scaffolder/src/gui/overlay_panel_header_stylebox.tres")

var button_corner_radius: int
var button_corner_detail: int
var button_shadow_size: int
var button_border_width: int

var dropdown_corner_radius: int
var dropdown_corner_detail: int
var dropdown_shadow_size: int
var dropdown_border_width: int

var screen_shadow_size: int
var screen_shadow_offset: Vector2
var screen_border_width: int

var scroll_corner_radius: int
var scroll_corner_detail: int
# Width of the scrollbar.
var scroll_content_margin: int

var scroll_grabber_corner_radius: int
var scroll_grabber_corner_detail: int

var overlay_panel_border_width: int


func _init() -> void:
    Gs.logger.on_global_init(self, "ScaffolderStyles")


func register_manifest(manifest: Dictionary) -> void:
    self.button_corner_radius = manifest.button_corner_radius
    self.button_corner_detail = manifest.button_corner_detail
    self.button_shadow_size = manifest.button_shadow_size
    self.button_border_width = manifest.button_border_width
    
    self.dropdown_corner_radius = manifest.dropdown_corner_radius
    self.dropdown_corner_detail = manifest.dropdown_corner_detail
    self.dropdown_shadow_size = manifest.dropdown_shadow_size
    self.dropdown_border_width = manifest.dropdown_border_width
    
    self.screen_shadow_size = manifest.screen_shadow_size
    self.screen_shadow_offset = manifest.screen_shadow_offset
    self.screen_border_width = manifest.screen_border_width
    
    self.scroll_corner_radius = manifest.scroll_corner_radius
    self.scroll_corner_detail = manifest.scroll_corner_detail
    self.scroll_content_margin = manifest.scroll_content_margin
    
    self.scroll_grabber_corner_radius = manifest.scroll_grabber_corner_radius
    self.scroll_grabber_corner_detail = manifest.scroll_grabber_corner_detail
    
    self.overlay_panel_border_width = manifest.overlay_panel_border_width


func configure_theme() -> void:
    _configure_theme_color(
            "font_color", "Label", Gs.colors.text)
    _configure_theme_color(
            "font_color", "Button", Gs.colors.text)
    _configure_theme_color(
            "font_color", "CheckBox", Gs.colors.text)
    _configure_theme_color(
            "font_color", "ItemList", Gs.colors.text)
    _configure_theme_color(
            "font_color", "OptionButton", Gs.colors.text)
    _configure_theme_color(
            "font_color", "PopupMenu", Gs.colors.text)
    _configure_theme_color(
            "font_color", "Tree", Gs.colors.text)
    
    _configure_theme_stylebox(
            "disabled", "Button", {
                bg_color = Gs.colors.button_disabled,
                corner_radius = Gs.styles.button_corner_radius,
                corner_detail = Gs.styles.button_corner_detail,
                shadow_size = round(Gs.styles.button_shadow_size * 0.0),
                border_width = round(Gs.styles.button_border_width * 0.0),
                border_color = Gs.colors.button_border,
            })
    _configure_theme_stylebox(
            "focused", "Button", {
                bg_color = Gs.colors.button_focused,
                corner_radius = Gs.styles.button_corner_radius,
                corner_detail = Gs.styles.button_corner_detail,
                shadow_size = round(Gs.styles.button_shadow_size * 1.5),
                shadow_color = Color.from_hsv(0, 0, 0, 0.5),
                border_width = Gs.styles.button_border_width,
                border_color = Gs.colors.button_border,
            })
    _configure_theme_stylebox(
            "hover", "Button", {
                bg_color = Gs.colors.button_hover,
                corner_radius = Gs.styles.button_corner_radius,
                corner_detail = Gs.styles.button_corner_detail,
                shadow_size = round(Gs.styles.button_shadow_size * 1.5),
                shadow_color = Color.from_hsv(0, 0, 0, 0.5),
                border_width = Gs.styles.button_border_width,
                border_color = Gs.colors.button_border,
            })
    _configure_theme_stylebox(
            "normal", "Button", {
                bg_color = Gs.colors.button_normal,
                corner_radius = Gs.styles.button_corner_radius,
                corner_detail = Gs.styles.button_corner_detail,
                shadow_size = Gs.styles.button_shadow_size,
                border_width = Gs.styles.button_border_width,
                border_color = Gs.colors.button_border,
            })
    _configure_theme_stylebox(
            "pressed", "Button", {
                bg_color = Gs.colors.button_pressed,
                corner_radius = Gs.styles.button_corner_radius,
                corner_detail = Gs.styles.button_corner_detail,
                shadow_size = round(Gs.styles.button_shadow_size * 0.2),
                border_width = Gs.styles.button_border_width,
                border_color = Gs.colors.button_border,
            })
    
    _configure_theme_stylebox(
            "disabled", "OptionButton", {
                bg_color = Gs.colors.dropdown_disabled,
                corner_radius = Gs.styles.dropdown_corner_radius,
                corner_detail = Gs.styles.dropdown_corner_detail,
                shadow_size = Gs.styles.dropdown_shadow_size,
                border_width = Gs.styles.dropdown_border_width,
                border_color = Gs.colors.dropdown_border,
            })
    _configure_theme_stylebox(
            "focused", "OptionButton", {
                bg_color = Gs.colors.dropdown_focused,
                corner_radius = Gs.styles.dropdown_corner_radius,
                corner_detail = Gs.styles.dropdown_corner_detail,
                shadow_size = Gs.styles.dropdown_shadow_size,
                border_width = Gs.styles.dropdown_border_width,
                border_color = Gs.colors.dropdown_border,
            })
    _configure_theme_stylebox(
            "hover", "OptionButton", {
                bg_color = Gs.colors.dropdown_hover,
                corner_radius = Gs.styles.dropdown_corner_radius,
                corner_detail = Gs.styles.dropdown_corner_detail,
                shadow_size = Gs.styles.dropdown_shadow_size,
                border_width = Gs.styles.dropdown_border_width,
                border_color = Gs.colors.dropdown_border,
            })
    _configure_theme_stylebox(
            "normal", "OptionButton", {
                bg_color = Gs.colors.dropdown_normal,
                corner_radius = Gs.styles.dropdown_corner_radius,
                corner_detail = Gs.styles.dropdown_corner_detail,
                shadow_size = Gs.styles.dropdown_shadow_size,
                border_width = Gs.styles.dropdown_border_width,
                border_color = Gs.colors.dropdown_border,
            })
    _configure_theme_stylebox(
            "pressed", "OptionButton", {
                bg_color = Gs.colors.dropdown_pressed,
                corner_radius = Gs.styles.dropdown_corner_radius,
                corner_detail = Gs.styles.dropdown_corner_detail,
                shadow_size = Gs.styles.dropdown_shadow_size,
                border_width = Gs.styles.dropdown_border_width,
                border_color = Gs.colors.dropdown_border,
            })
    
    _configure_theme_stylebox(
            "panel", "PopupMenu", Gs.colors.popup_background)
    
    _configure_theme_stylebox(
            "scroll", "HScrollBar", {
                bg_color = Gs.colors.scroll_bar_background,
                corner_radius = Gs.styles.scroll_corner_radius,
                corner_detail = Gs.styles.scroll_corner_detail,
                content_margin = Gs.styles.scroll_content_margin,
            })
    _configure_theme_stylebox(
            "grabber", "HScrollBar", {
                bg_color = Gs.colors.scroll_bar_grabber_normal,
                corner_radius = Gs.styles.scroll_grabber_corner_radius,
                corner_detail = Gs.styles.scroll_grabber_corner_detail,
            })
    _configure_theme_stylebox(
            "grabber_highlight", "HScrollBar", {
                bg_color = Gs.colors.scroll_bar_grabber_hover,
                corner_radius = Gs.styles.scroll_grabber_corner_radius,
                corner_detail = Gs.styles.scroll_grabber_corner_detail,
            })
    _configure_theme_stylebox(
            "grabber_pressed", "HScrollBar", {
                bg_color = Gs.colors.scroll_bar_grabber_pressed,
                corner_radius = Gs.styles.scroll_grabber_corner_radius,
                corner_detail = Gs.styles.scroll_grabber_corner_detail,
            })
    
    _configure_theme_stylebox(
            "scroll", "VScrollBar", {
                bg_color = Gs.colors.scroll_bar_background,
                corner_radius = Gs.styles.scroll_corner_radius,
                corner_detail = Gs.styles.scroll_corner_detail,
                content_margin = Gs.styles.scroll_content_margin,
            })
    _configure_theme_stylebox(
            "grabber", "VScrollBar", {
                bg_color = Gs.colors.scroll_bar_grabber_normal,
                corner_radius = Gs.styles.scroll_grabber_corner_radius,
                corner_detail = Gs.styles.scroll_grabber_corner_detail,
            })
    _configure_theme_stylebox(
            "grabber_highlight", "VScrollBar", {
                bg_color = Gs.colors.scroll_bar_grabber_hover,
                corner_radius = Gs.styles.scroll_grabber_corner_radius,
                corner_detail = Gs.styles.scroll_grabber_corner_detail,
            })
    _configure_theme_stylebox(
            "grabber_pressed", "VScrollBar", {
                bg_color = Gs.colors.scroll_bar_grabber_pressed,
                corner_radius = Gs.styles.scroll_grabber_corner_radius,
                corner_detail = Gs.styles.scroll_grabber_corner_detail,
            })
    
    _configure_theme_stylebox(
            "panel", "Panel", Gs.colors.background)
    _configure_theme_stylebox(
            "panel", "PanelContainer", Gs.colors.background)
    _configure_theme_stylebox(
            "bg", "Tree", Color.transparent)
    
    _configure_theme_stylebox_empty("disabled", "CheckBox")
    _configure_theme_stylebox_empty("focus", "CheckBox")
    _configure_theme_stylebox_empty("hover", "CheckBox")
    _configure_theme_stylebox_empty("hover_pressed", "CheckBox")
    _configure_theme_stylebox_empty("normal", "CheckBox")
    _configure_theme_stylebox_empty("pressed", "CheckBox")
    
    if Gs.gui.theme.default_font == null:
        Gs.gui.theme.default_font = Gs.gui.fonts.main_m
    
    Gs.gui.theme.set_font("font", "TooltipLabel", Gs.gui.fonts.main_xs)
    _configure_theme_color( \
            "font_color", "TooltipLabel", Gs.colors.tooltip)
    _configure_theme_stylebox( \
            "panel", "TooltipPanel", Gs.colors.tooltip_bg)
    
    OVERLAY_PANEL_BODY_STYLEBOX.bg_color = \
            Gs.colors.overlay_panel_body_background
    OVERLAY_PANEL_HEADER_STYLEBOX.bg_color = \
            Gs.colors.overlay_panel_header_background


func _configure_theme_color(
        name: String,
        type: String,
        color: Color) -> void:
    if !Gs.gui.theme.has_color(name, type):
        Gs.gui.theme.set_color(name, type, color)


func _configure_theme_stylebox(
        name: String,
        type: String,
        config) -> void:
    if !Gs.gui.theme.has_stylebox(name, type):
        var stylebox: StyleBoxFlatScalable = \
                Gs.utils.create_stylebox_flat_scalable(config)
        Gs.gui.theme.set_stylebox(name, type, stylebox)
    elif !(Gs.gui.theme.get_stylebox(name, type) is StyleBoxFlatScalable):
        var old: StyleBox = Gs.gui.theme.get_stylebox(name, type)
        var new: StyleBoxFlatScalable = \
                Gs.utils.create_stylebox_flat_scalable(old)
        Gs.gui.theme.set_stylebox(name, type, new)


func _configure_theme_stylebox_empty(
        name: String,
        type: String) -> void:
    if !Gs.gui.theme.has_stylebox(name, type):
        var stylebox := StyleBoxEmpty.new()
        Gs.gui.theme.set_stylebox(name, type, stylebox)

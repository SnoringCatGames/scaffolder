class_name ScaffolderStyles
extends Node


const OVERLAY_PANEL_BODY_STYLEBOX := \
        preload("res://addons/scaffolder/src/gui/overlay_panel_body_stylebox.tres")
const OVERLAY_PANEL_HEADER_STYLEBOX := \
        preload("res://addons/scaffolder/src/gui/overlay_panel_header_stylebox.tres")

const BUTTON_ACTIVE_NINE_PATCH_PATH := \
        "res://addons/scaffolder/assets/images/gui/button_active.png"
const BUTTON_HOVER_NINE_PATCH_PATH := \
        "res://addons/scaffolder/assets/images/gui/button_hover.png"
const BUTTON_NORMAL_NINE_PATCH_PATH = \
        "res://addons/scaffolder/assets/images/gui/button_normal.png"

var button_corner_radius: int
var button_corner_detail: int
var button_shadow_size: int
var button_border_width: int

var button_shine_margin := 0

var button_active_nine_patch: Texture
var button_disabled_nine_patch: Texture
var button_focused_nine_patch: Texture
var button_hover_nine_patch: Texture
var button_normal_nine_patch: Texture
var button_nine_patch_scale: float
var button_nine_patch_margin: float

var dropdown_corner_radius: int
var dropdown_corner_detail: int
var dropdown_shadow_size: int
var dropdown_border_width: int

var dropdown_active_nine_patch: StyleBoxTexture
var dropdown_disabled_nine_patch: StyleBoxTexture
var dropdown_focused_nine_patch: StyleBoxTexture
var dropdown_hover_nine_patch: StyleBoxTexture
var dropdown_normal_nine_patch: StyleBoxTexture
var dropdown_nine_patch_scale: float
var dropdown_nine_patch_margin: float

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
    if manifest.has("button_corner_radius"):
        self.button_corner_radius = manifest.button_corner_radius
    if manifest.has("button_corner_detail"):
        self.button_corner_detail = manifest.button_corner_detail
    if manifest.has("button_shadow_size"):
        self.button_shadow_size = manifest.button_shadow_size
    if manifest.has("button_border_width"):
        self.button_border_width = manifest.button_border_width
    
    if manifest.has("button_shine_margin"):
        self.button_shine_margin = manifest.button_shine_margin
    
    if manifest.has("button_active_nine_patch"):
        self.button_active_nine_patch = manifest.button_active_nine_patch
    if manifest.has("button_disabled_nine_patch"):
        self.button_disabled_nine_patch = manifest.button_disabled_nine_patch
    if manifest.has("button_focused_nine_patch"):
        self.button_focused_nine_patch = manifest.button_focused_nine_patch
    if manifest.has("button_hover_nine_patch"):
        self.button_hover_nine_patch = manifest.button_hover_nine_patch
    if manifest.has("button_normal_nine_patch"):
        self.button_normal_nine_patch = manifest.button_normal_nine_patch
    if manifest.has("button_nine_patch_scale"):
        self.button_nine_patch_scale = manifest.button_nine_patch_scale
    if manifest.has("button_nine_patch_margin"):
        self.button_nine_patch_margin = manifest.button_nine_patch_margin
    
    assert((manifest.has("button_active_nine_patch") and \
            manifest.has("button_disabled_nine_patch") and \
            manifest.has("button_focused_nine_patch") and \
            manifest.has("button_hover_nine_patch") and \
            manifest.has("button_normal_nine_patch") and \
            manifest.has("button_nine_patch_scale") and \
            manifest.has("button_nine_patch_margin")) or \
            (manifest.has("button_corner_radius") and \
            manifest.has("button_corner_detail") and \
            manifest.has("button_shadow_size") and \
            manifest.has("button_border_width")))
    
    if manifest.has("dropdown_corner_radius"):
        self.dropdown_corner_radius = manifest.dropdown_corner_radius
    if manifest.has("dropdown_corner_detail"):
        self.dropdown_corner_detail = manifest.dropdown_corner_detail
    if manifest.has("dropdown_shadow_size"):
        self.dropdown_shadow_size = manifest.dropdown_shadow_size
    if manifest.has("dropdown_border_width"):
        self.dropdown_border_width = manifest.dropdown_border_width
    
    if manifest.has("dropdown_active_nine_patch"):
        self.dropdown_active_nine_patch = manifest.dropdown_active_nine_patch
    if manifest.has("dropdown_disabled_nine_patch"):
        self.dropdown_disabled_nine_patch = \
                manifest.dropdown_disabled_nine_patch
    if manifest.has("dropdown_focused_nine_patch"):
        self.dropdown_focused_nine_patch = manifest.dropdown_focused_nine_patch
    if manifest.has("dropdown_hover_nine_patch"):
        self.dropdown_hover_nine_patch = manifest.dropdown_hover_nine_patch
    if manifest.has("dropdown_normal_nine_patch"):
        self.dropdown_normal_nine_patch = manifest.dropdown_normal_nine_patch
    if manifest.has("dropdown_nine_patch_scale"):
        self.dropdown_nine_patch_scale = manifest.dropdown_nine_patch_scale
    if manifest.has("dropdown_nine_patch_margin"):
        self.dropdown_nine_patch_margin = manifest.dropdown_nine_patch_margin
    
    assert((manifest.has("dropdown_active_nine_patch") and \
            manifest.has("dropdown_disabled_nine_patch") and \
            manifest.has("dropdown_focused_nine_patch") and \
            manifest.has("dropdown_hover_nine_patch") and \
            manifest.has("dropdown_normal_nine_patch") and \
            manifest.has("dropdown_nine_patch_scale") and \
            manifest.has("dropdown_nine_patch_margin")) or \
            (manifest.has("dropdown_corner_radius") and \
            manifest.has("dropdown_corner_detail") and \
            manifest.has("dropdown_shadow_size") and \
            manifest.has("dropdown_border_width")))
    
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
    
    if is_instance_valid(Gs.styles.button_normal_nine_patch):
        _configure_theme_stylebox(
                "disabled", "Button", {
                    texture = Gs.styles.button_disabled_nine_patch,
                    texture_scale = Gs.styles.button_nine_patch_scale,
                    margin = Gs.styles.button_nine_patch_margin,
                })
        _configure_theme_stylebox(
                "focused", "Button", {
                    texture = Gs.styles.button_focused_nine_patch,
                    texture_scale = Gs.styles.button_nine_patch_scale,
                    margin = Gs.styles.button_nine_patch_margin,
                })
        _configure_theme_stylebox(
                "hover", "Button", {
                    texture = Gs.styles.button_hover_nine_patch,
                    texture_scale = Gs.styles.button_nine_patch_scale,
                    margin = Gs.styles.button_nine_patch_margin,
                })
        _configure_theme_stylebox(
                "normal", "Button", {
                    texture = Gs.styles.button_normal_nine_patch,
                    texture_scale = Gs.styles.button_nine_patch_scale,
                    margin = Gs.styles.button_nine_patch_margin,
                })
        _configure_theme_stylebox(
                "pressed", "Button", {
                    texture = Gs.styles.button_active_nine_patch,
                    texture_scale = Gs.styles.button_nine_patch_scale,
                    margin = Gs.styles.button_nine_patch_margin,
                })
    else:
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
    
    if is_instance_valid(Gs.styles.dropdown_normal_nine_patch):
        _configure_theme_stylebox(
                "disabled", "OptionButton", {
                    texture = Gs.styles.dropdown_disabled_nine_patch,
                    texture_scale = Gs.styles.dropdown_nine_patch_scale,
                    margin = Gs.styles.dropdown_nine_patch_margin,
                })
        _configure_theme_stylebox(
                "focused", "OptionButton", {
                    texture = Gs.styles.dropdown_focused_nine_patch,
                    texture_scale = Gs.styles.dropdown_nine_patch_scale,
                    margin = Gs.styles.dropdown_nine_patch_margin,
                })
        _configure_theme_stylebox(
                "hover", "OptionButton", {
                    texture = Gs.styles.dropdown_hover_nine_patch,
                    texture_scale = Gs.styles.dropdown_nine_patch_scale,
                    margin = Gs.styles.dropdown_nine_patch_margin,
                })
        _configure_theme_stylebox(
                "normal", "OptionButton", {
                    texture = Gs.styles.dropdown_normal_nine_patch,
                    texture_scale = Gs.styles.dropdown_nine_patch_scale,
                    margin = Gs.styles.dropdown_nine_patch_margin,
                })
        _configure_theme_stylebox(
                "pressed", "OptionButton", {
                    texture = Gs.styles.dropdown_active_nine_patch,
                    texture_scale = Gs.styles.dropdown_nine_patch_scale,
                    margin = Gs.styles.dropdown_nine_patch_margin,
                })
    else:
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
        var stylebox: StyleBox = Gs.styles.create_stylebox_scalable(config)
        Gs.gui.theme.set_stylebox(name, type, stylebox)
    else:
        var old: StyleBox = Gs.gui.theme.get_stylebox(name, type)
        if !(old is StyleBoxFlatScalable or \
                old is StyleBoxTextureScalable):
            var new: StyleBox = Gs.styles.create_stylebox_scalable(old)
            Gs.gui.theme.set_stylebox(name, type, new)


func _configure_theme_stylebox_empty(
        name: String,
        type: String) -> void:
    if !Gs.gui.theme.has_stylebox(name, type):
        var stylebox := StyleBoxEmpty.new()
        Gs.gui.theme.set_stylebox(name, type, stylebox)


func create_stylebox_scalable(config) -> StyleBox:
    if config is Color:
        var stylebox := StyleBoxFlatScalable.new()
        stylebox.bg_color = config
        stylebox.ready()
        return stylebox
    elif config is Dictionary:
        if config.has("texture"):
            return _create_stylebox_texture_scalable_from_config(config)
        else:
            return _create_stylebox_flat_scalable_from_config(config)
    elif config is StyleBoxTexture:
        return _create_stylebox_texture_scalable_from_stylebox(config)
    elif config is StyleBox:
        return _create_stylebox_flat_scalable_from_stylebox(config)
    else:
        Gs.logger.error()
        return null


func _create_stylebox_texture_scalable_from_config(
        config: Dictionary) -> StyleBoxTextureScalable:
    var stylebox := StyleBoxTextureScalable.new()
    stylebox.texture = config.texture
    if config.has("texture_scale"):
        stylebox.initial_texture_scale = config.texture_scale
    if config.has("margin"):
        stylebox.margin_bottom = config.margin
        stylebox.margin_left = config.margin
        stylebox.margin_right = config.margin
        stylebox.margin_top = config.margin
    if config.has("expand_margin"):
        stylebox.expand_margin_bottom = config.expand_margin
        stylebox.expand_margin_left = config.expand_margin
        stylebox.expand_margin_right = config.expand_margin
        stylebox.expand_margin_top = config.expand_margin
    
    # Setting content-margin to 0 is important for preventing the button from
    # forcing an undesirable min height.
    stylebox.content_margin_bottom = 0
    stylebox.content_margin_left = 0
    stylebox.content_margin_right = 0
    stylebox.content_margin_top = 0
    
    stylebox.ready()
    return stylebox


func _create_stylebox_texture_scalable_from_stylebox(
        old: StyleBoxTexture) -> StyleBoxTextureScalable:
    var new := StyleBoxTextureScalable.new()
    
    new.texture = old.texture
    new.normal_map = old.normal_map
    new.region_rect = old.region_rect
    
    new.content_margin_left = old.content_margin_left
    new.content_margin_top = old.content_margin_top
    new.content_margin_right = old.content_margin_right
    new.content_margin_bottom = old.content_margin_bottom
    
    new.margin_left = old.margin_left
    new.margin_top = old.margin_top
    new.margin_right = old.margin_right
    new.margin_bottom = old.margin_bottom
    
    new.expand_margin_left = old.expand_margin_left
    new.expand_margin_top = old.expand_margin_top
    new.expand_margin_right = old.expand_margin_right
    new.expand_margin_bottom = old.expand_margin_bottom
    
    new.modulate_color = old.modulate_color
    new.draw_center = old.draw_center
    
    if old is StyleBoxTextureScalable:
        new.texture = old.initial_texture
        new.content_margin_top = old.initial_content_margin
        new.expand_margin_top = old.initial_expand_margin
        new.margin_top = old.initial_margin
        new.initial_texture_scale = old.initial_texture_scale
    
    new.ready()
    return new


func _create_stylebox_flat_scalable_from_config(
        config: Dictionary) -> StyleBoxFlatScalable:
    var stylebox: StyleBoxFlatScalable
    if config.has("stylebox"):
        stylebox = _create_stylebox_flat_scalable_from_stylebox(
                config.stylebox)
    else:
        stylebox = StyleBoxFlatScalable.new()
    
    if config.has("bg_color"):
        stylebox.bg_color = config.bg_color
    if config.has("border_width"):
        stylebox.border_width_left = config.border_width
        stylebox.border_width_top = config.border_width
        stylebox.border_width_right = config.border_width
        stylebox.border_width_bottom = config.border_width
    if config.has("border_color"):
        stylebox.border_color = config.border_color
    if config.has("content_margin"):
        stylebox.content_margin_left = config.content_margin
        stylebox.content_margin_top = config.content_margin
        stylebox.content_margin_right = config.content_margin
        stylebox.content_margin_bottom = config.content_margin
    if config.has("corner_detail"):
        stylebox.corner_detail = config.corner_detail
    if config.has("corner_radius"):
        stylebox.corner_radius_top_left = config.corner_radius
        stylebox.corner_radius_top_right = config.corner_radius
        stylebox.corner_radius_bottom_left = config.corner_radius
        stylebox.corner_radius_bottom_right = config.corner_radius
    if config.has("expand_margin"):
        stylebox.expand_margin_left = config.expand_margin
        stylebox.expand_margin_top = config.expand_margin
        stylebox.expand_margin_right = config.expand_margin
        stylebox.expand_margin_bottom = config.expand_margin
    if config.has("shadow_color"):
        stylebox.shadow_color = config.shadow_color
    if config.has("shadow_offset"):
        stylebox.shadow_offset = config.shadow_offset
    if config.has("shadow_size"):
        stylebox.shadow_size = config.shadow_size
    stylebox.ready()
    return stylebox


func _create_stylebox_flat_scalable_from_stylebox(
        old: StyleBox) -> StyleBoxFlatScalable:
    var new := StyleBoxFlatScalable.new()
    
    new.expand_margin_left = old.expand_margin_left
    new.expand_margin_top = old.expand_margin_top
    new.expand_margin_right = old.expand_margin_right
    new.expand_margin_bottom = old.expand_margin_bottom
    
    if old is StyleBoxFlat:
        new.anti_aliasing = old.anti_aliasing
        new.anti_aliasing_size = old.anti_aliasing_size
        new.bg_color = old.bg_color
        new.border_blend = old.border_blend
        new.border_color = old.border_color
        new.border_width_left = old.border_width_left
        new.border_width_top = old.border_width_top
        new.border_width_right = old.border_width_right
        new.border_width_bottom = old.border_width_bottom
        new.content_margin_left = old.content_margin_left
        new.content_margin_top = old.content_margin_top
        new.content_margin_right = old.content_margin_right
        new.content_margin_bottom = old.content_margin_bottom
        new.corner_detail = old.corner_detail
        new.corner_radius_top_left = old.corner_radius_top_left
        new.corner_radius_top_right = old.corner_radius_top_right
        new.corner_radius_bottom_left = old.corner_radius_bottom_left
        new.corner_radius_bottom_right = old.corner_radius_bottom_right
        new.draw_center = old.draw_center
        new.shadow_color = old.shadow_color
        new.shadow_offset = old.shadow_offset
        new.shadow_size = old.shadow_size
    
    new.ready()
    return new

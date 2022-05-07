tool
class_name ScaffolderStyles
extends Node


var transparent_panel_stylebox: StyleBox
var overlay_panel_stylebox: StyleBox
var notification_panel_stylebox: StyleBox
var header_panel_stylebox: StyleBox
var hud_panel_stylebox: StyleBox
var simple_transparent_black_panel_stylebox: StyleBox

var focus_border_corner_radius: int
var focus_border_corner_detail: int
var focus_border_shadow_size: int
var focus_border_border_width: int

var focus_border_nine_patch: Texture
var focus_border_nine_patch_margin_left: float
var focus_border_nine_patch_margin_top: float
var focus_border_nine_patch_margin_right: float
var focus_border_nine_patch_margin_bottom: float
var focus_border_nine_patch_scale: float
var focus_border_nine_patch_border_width: float

var focus_border_expand_margin_left: float
var focus_border_expand_margin_top: float
var focus_border_expand_margin_right: float
var focus_border_expand_margin_bottom: float

var button_content_margin_left := 12.0
var button_content_margin_top := 12.0
var button_content_margin_right := 12.0
var button_content_margin_bottom := 12.0

var button_shine_margin_left := 0
var button_shine_margin_top := 0
var button_shine_margin_right := 0
var button_shine_margin_bottom := 0

var button_corner_radius: int
var button_corner_detail: int
var button_shadow_size: int
var button_border_width: int

var button_pressed_nine_patch: Texture
var button_disabled_nine_patch: Texture
var button_hover_nine_patch: Texture
var button_normal_nine_patch: Texture
var button_nine_patch_scale: float
var button_nine_patch_border_width: float
var button_nine_patch_margin_left: float
var button_nine_patch_margin_top: float
var button_nine_patch_margin_right: float
var button_nine_patch_margin_bottom: float

var dropdown_corner_radius: int
var dropdown_corner_detail: int
var dropdown_shadow_size: int
var dropdown_border_width: int

var dropdown_pressed_nine_patch: Texture
var dropdown_disabled_nine_patch: Texture
var dropdown_hover_nine_patch: Texture
var dropdown_normal_nine_patch: Texture
var dropdown_nine_patch_scale: float
var dropdown_nine_patch_border_width: float
var dropdown_nine_patch_margin_left: float
var dropdown_nine_patch_margin_top: float
var dropdown_nine_patch_margin_right: float
var dropdown_nine_patch_margin_bottom: float

var scroll_corner_radius: int
var scroll_corner_detail: int
# Width of the scrollbar.
var scroll_content_margin_left: int
var scroll_content_margin_top: int
var scroll_content_margin_right: int
var scroll_content_margin_bottom: int

var scroll_grabber_corner_radius: int
var scroll_grabber_corner_detail: int

var scroll_track_nine_patch: Texture
var scroll_track_nine_patch_scale: float
var scroll_track_nine_patch_margin_left: float
var scroll_track_nine_patch_margin_top: float
var scroll_track_nine_patch_margin_right: float
var scroll_track_nine_patch_margin_bottom: float

var scroll_grabber_pressed_nine_patch: Texture
var scroll_grabber_hover_nine_patch: Texture
var scroll_grabber_normal_nine_patch: Texture
var scroll_grabber_nine_patch_scale: float
var scroll_grabber_nine_patch_margin_left: float
var scroll_grabber_nine_patch_margin_top: float
var scroll_grabber_nine_patch_margin_right: float
var scroll_grabber_nine_patch_margin_bottom: float

var slider_corner_radius: int
var slider_corner_detail: int
var slider_content_margin_left: int
var slider_content_margin_top: int
var slider_content_margin_right: int
var slider_content_margin_bottom: int

var slider_track_nine_patch: Texture
var slider_track_nine_patch_scale: float
var slider_track_nine_patch_margin_left: float
var slider_track_nine_patch_margin_top: float
var slider_track_nine_patch_margin_right: float
var slider_track_nine_patch_margin_bottom: float

var overlay_panel_nine_patch: Texture
var overlay_panel_nine_patch_scale: float
var overlay_panel_nine_patch_border_width: float
var overlay_panel_nine_patch_margin_left: float
var overlay_panel_nine_patch_margin_top: float
var overlay_panel_nine_patch_margin_right: float
var overlay_panel_nine_patch_margin_bottom: float

var overlay_panel_corner_radius: int
var overlay_panel_corner_detail: int
var overlay_panel_shadow_size: int
var overlay_panel_shadow_offset: Vector2

var overlay_panel_border_width: int

var overlay_panel_content_margin_left: int
var overlay_panel_content_margin_top: int
var overlay_panel_content_margin_right: int
var overlay_panel_content_margin_bottom: int

var notification_panel_nine_patch: Texture
var notification_panel_nine_patch_scale: float
var notification_panel_nine_patch_border_width: float
var notification_panel_nine_patch_margin_left: float
var notification_panel_nine_patch_margin_top: float
var notification_panel_nine_patch_margin_right: float
var notification_panel_nine_patch_margin_bottom: float

var notification_panel_corner_radius: int
var notification_panel_corner_detail: int
var notification_panel_shadow_size: int
var notification_panel_shadow_offset: Vector2

var notification_panel_border_width: int

var notification_panel_content_margin_left: int
var notification_panel_content_margin_top: int
var notification_panel_content_margin_right: int
var notification_panel_content_margin_bottom: int

var header_panel_nine_patch: Texture
var header_panel_nine_patch_scale: float
var header_panel_nine_patch_border_width: float
var header_panel_nine_patch_margin_left: float
var header_panel_nine_patch_margin_top: float
var header_panel_nine_patch_margin_right: float
var header_panel_nine_patch_margin_bottom: float

var header_panel_content_margin_left: int
var header_panel_content_margin_top: int
var header_panel_content_margin_right: int
var header_panel_content_margin_bottom: int

var hud_panel_nine_patch: Texture
var hud_panel_nine_patch_scale: float
var hud_panel_nine_patch_border_width: float
var hud_panel_nine_patch_margin_left: float
var hud_panel_nine_patch_margin_top: float
var hud_panel_nine_patch_margin_right: float
var hud_panel_nine_patch_margin_bottom: float
var hud_panel_content_margin_left: int
var hud_panel_content_margin_top: int
var hud_panel_content_margin_right: int
var hud_panel_content_margin_bottom: int
    
var simple_transparent_black_panel_corner_radius: int
var simple_transparent_black_panel_corner_detail: int
var simple_transparent_black_panel_content_margin_left: int
var simple_transparent_black_panel_content_margin_top: int
var simple_transparent_black_panel_content_margin_right: int
var simple_transparent_black_panel_content_margin_bottom: int

var screen_shadow_size: int
var screen_shadow_offset: Vector2
var screen_border_width: int


func _init() -> void:
    Sc.logger.on_global_init(self, "ScaffolderStyles")


func _parse_manifest(manifest: Dictionary) -> void:
    _validate_manifest(manifest)
    
    if manifest.has("focus_border_nine_patch"):
        self.focus_border_nine_patch = manifest.focus_border_nine_patch
        self.focus_border_nine_patch_scale = \
                manifest.focus_border_nine_patch_scale
        self.focus_border_nine_patch_border_width = \
                manifest.focus_border_nine_patch_border_width
        self.focus_border_nine_patch_margin_left = \
                manifest.focus_border_nine_patch_margin_left
        self.focus_border_nine_patch_margin_top = \
                manifest.focus_border_nine_patch_margin_top
        self.focus_border_nine_patch_margin_right = \
                manifest.focus_border_nine_patch_margin_right
        self.focus_border_nine_patch_margin_bottom = \
                manifest.focus_border_nine_patch_margin_bottom
    else:
        self.focus_border_corner_radius = manifest.focus_border_corner_radius
        self.focus_border_corner_detail = manifest.focus_border_corner_detail
        self.focus_border_shadow_size = manifest.focus_border_shadow_size
        self.focus_border_border_width = manifest.focus_border_border_width
    self.focus_border_expand_margin_left = \
            manifest.focus_border_expand_margin_left
    self.focus_border_expand_margin_top = \
            manifest.focus_border_expand_margin_top
    self.focus_border_expand_margin_right = \
            manifest.focus_border_expand_margin_right
    self.focus_border_expand_margin_bottom = \
            manifest.focus_border_expand_margin_bottom
    
    if manifest.has("button_content_margin_left"):
        self.button_content_margin_left = \
                manifest.button_content_margin_left
        self.button_content_margin_top = \
                manifest.button_content_margin_top
        self.button_content_margin_right = \
                manifest.button_content_margin_right
        self.button_content_margin_bottom = \
                manifest.button_content_margin_bottom
    
    if manifest.has("button_shine_margin_left"):
        self.button_shine_margin_left = manifest.button_shine_margin_left
        self.button_shine_margin_top = manifest.button_shine_margin_top
        self.button_shine_margin_right = manifest.button_shine_margin_right
        self.button_shine_margin_bottom = manifest.button_shine_margin_bottom
    
    if manifest.has("button_normal_nine_patch"):
        self.button_pressed_nine_patch = manifest.button_pressed_nine_patch
        self.button_disabled_nine_patch = manifest.button_disabled_nine_patch
        self.button_hover_nine_patch = manifest.button_hover_nine_patch
        self.button_normal_nine_patch = manifest.button_normal_nine_patch
        self.button_nine_patch_scale = manifest.button_nine_patch_scale
        self.button_nine_patch_border_width = \
                manifest.button_nine_patch_border_width
        self.button_nine_patch_margin_left = \
                manifest.button_nine_patch_margin_left
        self.button_nine_patch_margin_top = \
                manifest.button_nine_patch_margin_top
        self.button_nine_patch_margin_right = \
                manifest.button_nine_patch_margin_right
        self.button_nine_patch_margin_bottom = \
                manifest.button_nine_patch_margin_bottom
    else:
        self.button_corner_radius = manifest.button_corner_radius
        self.button_corner_detail = manifest.button_corner_detail
        self.button_shadow_size = manifest.button_shadow_size
        self.button_border_width = manifest.button_border_width
    
    if manifest.has("dropdown_normal_nine_patch"):
        self.dropdown_pressed_nine_patch = manifest.dropdown_pressed_nine_patch
        self.dropdown_disabled_nine_patch = \
                manifest.dropdown_disabled_nine_patch
        self.dropdown_hover_nine_patch = manifest.dropdown_hover_nine_patch
        self.dropdown_normal_nine_patch = manifest.dropdown_normal_nine_patch
        self.dropdown_nine_patch_scale = manifest.dropdown_nine_patch_scale
        self.dropdown_nine_patch_border_width = \
                manifest.dropdown_nine_patch_border_width
        self.dropdown_nine_patch_margin_left = \
                manifest.dropdown_nine_patch_margin_left
        self.dropdown_nine_patch_margin_top = \
                manifest.dropdown_nine_patch_margin_top
        self.dropdown_nine_patch_margin_right = \
                manifest.dropdown_nine_patch_margin_right
        self.dropdown_nine_patch_margin_bottom = \
                manifest.dropdown_nine_patch_margin_bottom
    else:
        self.dropdown_corner_radius = manifest.dropdown_corner_radius
        self.dropdown_corner_detail = manifest.dropdown_corner_detail
        self.dropdown_shadow_size = manifest.dropdown_shadow_size
        self.dropdown_border_width = manifest.dropdown_border_width
    
    if manifest.has("scroll_track_nine_patch"):
        self.scroll_track_nine_patch = manifest.scroll_track_nine_patch
        self.scroll_track_nine_patch_scale = \
                manifest.scroll_track_nine_patch_scale
        
        self.scroll_track_nine_patch_margin_left = \
                manifest.scroll_track_nine_patch_margin_left
        self.scroll_track_nine_patch_margin_top = \
                manifest.scroll_track_nine_patch_margin_top
        self.scroll_track_nine_patch_margin_right = \
                manifest.scroll_track_nine_patch_margin_right
        self.scroll_track_nine_patch_margin_bottom = \
                manifest.scroll_track_nine_patch_margin_bottom
        
        self.scroll_grabber_pressed_nine_patch = \
                manifest.scroll_grabber_pressed_nine_patch
        self.scroll_grabber_hover_nine_patch = \
                manifest.scroll_grabber_hover_nine_patch
        self.scroll_grabber_normal_nine_patch = \
                manifest.scroll_grabber_normal_nine_patch
        self.scroll_grabber_nine_patch_scale = \
                manifest.scroll_grabber_nine_patch_scale
        
        self.scroll_grabber_nine_patch_margin_left = \
                manifest.scroll_grabber_nine_patch_margin_left
        self.scroll_grabber_nine_patch_margin_top = \
                manifest.scroll_grabber_nine_patch_margin_top
        self.scroll_grabber_nine_patch_margin_right = \
                manifest.scroll_grabber_nine_patch_margin_right
        self.scroll_grabber_nine_patch_margin_bottom = \
                manifest.scroll_grabber_nine_patch_margin_bottom
    else:
        self.scroll_corner_radius = manifest.scroll_corner_radius
        self.scroll_corner_detail = manifest.scroll_corner_detail
        self.scroll_content_margin_left = \
                manifest.scroll_content_margin_left
        self.scroll_content_margin_top = \
                manifest.scroll_content_margin_top
        self.scroll_content_margin_right = \
                manifest.scroll_content_margin_right
        self.scroll_content_margin_bottom = \
                manifest.scroll_content_margin_bottom
        self.scroll_grabber_corner_radius = \
                manifest.scroll_grabber_corner_radius
        self.scroll_grabber_corner_detail = \
                manifest.scroll_grabber_corner_detail
    
    if manifest.has("slider_track_nine_patch"):
        self.slider_track_nine_patch = manifest.slider_track_nine_patch
        self.slider_track_nine_patch_scale = \
                manifest.slider_track_nine_patch_scale
        self.slider_track_nine_patch_margin_left = \
                manifest.slider_track_nine_patch_margin_left
        self.slider_track_nine_patch_margin_top = \
                manifest.slider_track_nine_patch_margin_top
        self.slider_track_nine_patch_margin_right = \
                manifest.slider_track_nine_patch_margin_right
        self.slider_track_nine_patch_margin_bottom = \
                manifest.slider_track_nine_patch_margin_bottom
    else:
        self.slider_corner_radius = manifest.slider_corner_radius
        self.slider_corner_detail = manifest.slider_corner_detail
        self.slider_content_margin_left = \
                manifest.slider_content_margin_left
        self.slider_content_margin_top = \
                manifest.slider_content_margin_top
        self.slider_content_margin_right = \
                manifest.slider_content_margin_right
        self.slider_content_margin_bottom = \
                manifest.slider_content_margin_bottom
    
    if manifest.has("overlay_panel_nine_patch"):
        self.overlay_panel_nine_patch = manifest.overlay_panel_nine_patch
        self.overlay_panel_nine_patch_scale = \
                manifest.overlay_panel_nine_patch_scale
        self.overlay_panel_nine_patch_border_width = \
                manifest.overlay_panel_nine_patch_border_width
        self.overlay_panel_nine_patch_margin_left = \
                manifest.overlay_panel_nine_patch_margin_left
        self.overlay_panel_nine_patch_margin_top = \
                manifest.overlay_panel_nine_patch_margin_top
        self.overlay_panel_nine_patch_margin_right = \
                manifest.overlay_panel_nine_patch_margin_right
        self.overlay_panel_nine_patch_margin_bottom = \
                manifest.overlay_panel_nine_patch_margin_bottom
    else:
        self.overlay_panel_corner_radius = manifest.overlay_panel_corner_radius
        self.overlay_panel_corner_detail = manifest.overlay_panel_corner_detail
        self.overlay_panel_shadow_size = manifest.overlay_panel_shadow_size
        self.overlay_panel_shadow_offset = manifest.overlay_panel_shadow_offset
        self.overlay_panel_border_width = manifest.overlay_panel_border_width
    self.overlay_panel_content_margin_left = \
            manifest.overlay_panel_content_margin_left
    self.overlay_panel_content_margin_top = \
            manifest.overlay_panel_content_margin_top
    self.overlay_panel_content_margin_right = \
            manifest.overlay_panel_content_margin_right
    self.overlay_panel_content_margin_bottom = \
            manifest.overlay_panel_content_margin_bottom
    
    if manifest.has("notification_panel_nine_patch"):
        self.notification_panel_nine_patch = \
                manifest.notification_panel_nine_patch
        self.notification_panel_nine_patch_scale = \
                manifest.notification_panel_nine_patch_scale
        self.notification_panel_nine_patch_border_width = \
                manifest.notification_panel_nine_patch_border_width
        self.notification_panel_nine_patch_margin_left = \
                manifest.notification_panel_nine_patch_margin_left
        self.notification_panel_nine_patch_margin_top = \
                manifest.notification_panel_nine_patch_margin_top
        self.notification_panel_nine_patch_margin_right = \
                manifest.notification_panel_nine_patch_margin_right
        self.notification_panel_nine_patch_margin_bottom = \
                manifest.notification_panel_nine_patch_margin_bottom
    else:
        self.notification_panel_corner_radius = \
                manifest.notification_panel_corner_radius
        self.notification_panel_corner_detail = \
                manifest.notification_panel_corner_detail
        self.notification_panel_shadow_size = \
                manifest.notification_panel_shadow_size
        self.notification_panel_shadow_offset = \
                manifest.notification_panel_shadow_offset
        self.notification_panel_border_width = \
                manifest.notification_panel_border_width
    self.notification_panel_content_margin_left = \
            manifest.notification_panel_content_margin_left
    self.notification_panel_content_margin_top = \
            manifest.notification_panel_content_margin_top
    self.notification_panel_content_margin_right = \
            manifest.notification_panel_content_margin_right
    self.notification_panel_content_margin_bottom = \
            manifest.notification_panel_content_margin_bottom
    
    if manifest.has("header_panel_nine_patch"):
        self.header_panel_nine_patch = manifest.header_panel_nine_patch
        self.header_panel_nine_patch_scale = \
                manifest.header_panel_nine_patch_scale
        self.header_panel_nine_patch_border_width = \
                manifest.header_panel_nine_patch_border_width
        self.header_panel_nine_patch_margin_left = \
                manifest.header_panel_nine_patch_margin_left
        self.header_panel_nine_patch_margin_top = \
                manifest.header_panel_nine_patch_margin_top
        self.header_panel_nine_patch_margin_right = \
                manifest.header_panel_nine_patch_margin_right
        self.header_panel_nine_patch_margin_bottom = \
                manifest.header_panel_nine_patch_margin_bottom
    self.header_panel_content_margin_left = \
            manifest.header_panel_content_margin_left
    self.header_panel_content_margin_top = \
            manifest.header_panel_content_margin_top
    self.header_panel_content_margin_right = \
            manifest.header_panel_content_margin_right
    self.header_panel_content_margin_bottom = \
            manifest.header_panel_content_margin_bottom
    
    self.hud_panel_nine_patch = manifest.hud_panel_nine_patch
    self.hud_panel_nine_patch_scale = manifest.hud_panel_nine_patch_scale
    self.hud_panel_nine_patch_border_width = \
            manifest.hud_panel_nine_patch_border_width
    self.hud_panel_nine_patch_margin_left = \
            manifest.hud_panel_nine_patch_margin_left
    self.hud_panel_nine_patch_margin_top = \
            manifest.hud_panel_nine_patch_margin_top
    self.hud_panel_nine_patch_margin_right = \
            manifest.hud_panel_nine_patch_margin_right
    self.hud_panel_nine_patch_margin_bottom = \
            manifest.hud_panel_nine_patch_margin_bottom
    self.hud_panel_content_margin_left = \
            manifest.hud_panel_content_margin_left
    self.hud_panel_content_margin_top = \
            manifest.hud_panel_content_margin_top
    self.hud_panel_content_margin_right = \
            manifest.hud_panel_content_margin_right
    self.hud_panel_content_margin_bottom = \
            manifest.hud_panel_content_margin_bottom
    
    self.simple_transparent_black_panel_corner_radius = \
            manifest.simple_transparent_black_panel_corner_radius
    self.simple_transparent_black_panel_corner_detail = \
            manifest.simple_transparent_black_panel_corner_detail
    self.simple_transparent_black_panel_content_margin_left = \
            manifest.simple_transparent_black_panel_content_margin_left
    self.simple_transparent_black_panel_content_margin_top = \
            manifest.simple_transparent_black_panel_content_margin_top
    self.simple_transparent_black_panel_content_margin_right = \
            manifest.simple_transparent_black_panel_content_margin_right
    self.simple_transparent_black_panel_content_margin_bottom = \
            manifest.simple_transparent_black_panel_content_margin_bottom
    
    self.screen_shadow_size = manifest.screen_shadow_size
    self.screen_shadow_offset = manifest.screen_shadow_offset
    self.screen_border_width = manifest.screen_border_width
    
    self.overlay_panel_border_width = manifest.overlay_panel_border_width
    self.notification_panel_border_width = \
            manifest.notification_panel_border_width


func _validate_manifest(manifest: Dictionary) -> void:
    assert(((manifest.has("focus_border_nine_patch") and \
            manifest.has("focus_border_nine_patch_scale") and \
            manifest.has("focus_border_nine_patch_border_width") and \
            manifest.has("focus_border_nine_patch_margin_left") and \
            manifest.has("focus_border_nine_patch_margin_top") and \
            manifest.has("focus_border_nine_patch_margin_right") and \
            manifest.has("focus_border_nine_patch_margin_bottom")) or \
            (manifest.has("focus_border_corner_radius") and \
            manifest.has("focus_border_corner_detail") and \
            manifest.has("focus_border_shadow_size") and \
            manifest.has("focus_border_border_width"))) and \
            manifest.has("focus_border_expand_margin_left") and \
            manifest.has("focus_border_expand_margin_top") and \
            manifest.has("focus_border_expand_margin_right") and \
            manifest.has("focus_border_expand_margin_bottom"))
    
    assert((manifest.has("button_pressed_nine_patch") and \
            manifest.has("button_disabled_nine_patch") and \
            manifest.has("button_hover_nine_patch") and \
            manifest.has("button_normal_nine_patch") and \
            manifest.has("button_nine_patch_scale") and \
            manifest.has("button_nine_patch_border_width") and \
            manifest.has("button_nine_patch_margin_left") and \
            manifest.has("button_nine_patch_margin_top") and \
            manifest.has("button_nine_patch_margin_right") and \
            manifest.has("button_nine_patch_margin_bottom")) or \
            (manifest.has("button_corner_radius") and \
            manifest.has("button_corner_detail") and \
            manifest.has("button_shadow_size") and \
            manifest.has("button_border_width")))
    
    assert((manifest.has("dropdown_pressed_nine_patch") and \
            manifest.has("dropdown_disabled_nine_patch") and \
            manifest.has("dropdown_hover_nine_patch") and \
            manifest.has("dropdown_normal_nine_patch") and \
            manifest.has("dropdown_nine_patch_scale") and \
            manifest.has("dropdown_nine_patch_border_width") and \
            manifest.has("dropdown_nine_patch_margin_left") and \
            manifest.has("dropdown_nine_patch_margin_top") and \
            manifest.has("dropdown_nine_patch_margin_right") and \
            manifest.has("dropdown_nine_patch_margin_bottom")) or \
            (manifest.has("dropdown_corner_radius") and \
            manifest.has("dropdown_corner_detail") and \
            manifest.has("dropdown_shadow_size") and \
            manifest.has("dropdown_border_width")))
    
    assert((manifest.has("scroll_track_nine_patch") and \
            manifest.has("scroll_track_nine_patch_scale") and \
            manifest.has("scroll_track_nine_patch_margin_left") and \
            manifest.has("scroll_track_nine_patch_margin_top") and \
            manifest.has("scroll_track_nine_patch_margin_right") and \
            manifest.has("scroll_track_nine_patch_margin_bottom") and \
            manifest.has("scroll_grabber_pressed_nine_patch") and \
            manifest.has("scroll_grabber_hover_nine_patch") and \
            manifest.has("scroll_grabber_normal_nine_patch") and \
            manifest.has("scroll_grabber_nine_patch_scale") and \
            manifest.has("scroll_grabber_nine_patch_margin_left") and \
            manifest.has("scroll_grabber_nine_patch_margin_top") and \
            manifest.has("scroll_grabber_nine_patch_margin_right") and \
            manifest.has("scroll_grabber_nine_patch_margin_bottom")) or \
            (manifest.has("scroll_corner_radius") and \
            manifest.has("scroll_corner_detail") and \
            manifest.has("scroll_content_margin_left") and \
            manifest.has("scroll_content_margin_top") and \
            manifest.has("scroll_content_margin_right") and \
            manifest.has("scroll_content_margin_bottom") and \
            manifest.has("scroll_grabber_corner_radius") and \
            manifest.has("scroll_grabber_corner_detail")))
    
    assert((manifest.has("slider_track_nine_patch") and \
            manifest.has("slider_track_nine_patch_scale") and \
            manifest.has("slider_track_nine_patch_margin_left") and \
            manifest.has("slider_track_nine_patch_margin_top") and \
            manifest.has("slider_track_nine_patch_margin_right") and \
            manifest.has("slider_track_nine_patch_margin_bottom")) or \
            (manifest.has("slider_corner_radius") and \
            manifest.has("slider_corner_detail") and \
            manifest.has("slider_content_margin_left") and \
            manifest.has("slider_content_margin_top") and \
            manifest.has("slider_content_margin_right") and \
            manifest.has("slider_content_margin_bottom")))
    
    assert((manifest.has("overlay_panel_nine_patch") and \
            manifest.has("overlay_panel_nine_patch_scale") and \
            manifest.has("overlay_panel_nine_patch_border_width") and \
            manifest.has("overlay_panel_nine_patch_margin_left") and \
            manifest.has("overlay_panel_nine_patch_margin_top") and \
            manifest.has("overlay_panel_nine_patch_margin_right") and \
            manifest.has("overlay_panel_nine_patch_margin_bottom") and \
            manifest.has("overlay_panel_content_margin_left") and \
            manifest.has("overlay_panel_content_margin_top") and \
            manifest.has("overlay_panel_content_margin_right") and \
            manifest.has("overlay_panel_content_margin_bottom")) or \
            (manifest.has("overlay_panel_corner_radius") and \
            manifest.has("overlay_panel_corner_detail") and \
            manifest.has("overlay_panel_shadow_size") and \
            manifest.has("overlay_panel_shadow_offset") and \
            manifest.has("overlay_panel_border_width") and \
            manifest.has("overlay_panel_content_margin_left") and \
            manifest.has("overlay_panel_content_margin_top") and \
            manifest.has("overlay_panel_content_margin_right") and \
            manifest.has("overlay_panel_content_margin_bottom")))
    
    assert((manifest.has("notification_panel_nine_patch") and \
            manifest.has("notification_panel_nine_patch_scale") and \
            manifest.has("notification_panel_nine_patch_border_width") and \
            manifest.has("notification_panel_nine_patch_margin_left") and \
            manifest.has("notification_panel_nine_patch_margin_top") and \
            manifest.has("notification_panel_nine_patch_margin_right") and \
            manifest.has("notification_panel_nine_patch_margin_bottom") and \
            manifest.has("notification_panel_content_margin_left") and \
            manifest.has("notification_panel_content_margin_top") and \
            manifest.has("notification_panel_content_margin_right") and \
            manifest.has("notification_panel_content_margin_bottom")) or \
            (manifest.has("notification_panel_corner_radius") and \
            manifest.has("notification_panel_corner_detail") and \
            manifest.has("notification_panel_shadow_size") and \
            manifest.has("notification_panel_shadow_offset") and \
            manifest.has("notification_panel_border_width") and \
            manifest.has("notification_panel_content_margin_left") and \
            manifest.has("notification_panel_content_margin_top") and \
            manifest.has("notification_panel_content_margin_right") and \
            manifest.has("notification_panel_content_margin_bottom")))
    
    assert((manifest.has("header_panel_nine_patch") and \
            manifest.has("header_panel_nine_patch_scale") and \
            manifest.has("header_panel_nine_patch_border_width") and \
            manifest.has("header_panel_nine_patch_margin_left") and \
            manifest.has("header_panel_nine_patch_margin_top") and \
            manifest.has("header_panel_nine_patch_margin_right") and \
            manifest.has("header_panel_nine_patch_margin_bottom") and \
            manifest.has("header_panel_content_margin_left") and \
            manifest.has("header_panel_content_margin_top") and \
            manifest.has("header_panel_content_margin_right") and \
            manifest.has("header_panel_content_margin_bottom")) or \
            (manifest.has("header_panel_content_margin_left") and \
            manifest.has("header_panel_content_margin_top") and \
            manifest.has("header_panel_content_margin_right") and \
            manifest.has("header_panel_content_margin_bottom")))
    
    assert(manifest.has("hud_panel_nine_patch") and \
            manifest.has("hud_panel_nine_patch_scale") and \
            manifest.has("hud_panel_nine_patch_border_width") and \
            manifest.has("hud_panel_nine_patch_margin_left") and \
            manifest.has("hud_panel_nine_patch_margin_top") and \
            manifest.has("hud_panel_nine_patch_margin_right") and \
            manifest.has("hud_panel_nine_patch_margin_bottom") and \
            manifest.has("hud_panel_content_margin_left") and \
            manifest.has("hud_panel_content_margin_top") and \
            manifest.has("hud_panel_content_margin_right") and \
            manifest.has("hud_panel_content_margin_bottom"))
    
    assert(manifest.has("simple_transparent_black_panel_corner_radius") and \
            manifest.has("simple_transparent_black_panel_corner_detail") and \
            manifest.has("simple_transparent_black_panel_content_margin_left") and \
            manifest.has("simple_transparent_black_panel_content_margin_top") and \
            manifest.has("simple_transparent_black_panel_content_margin_right") and \
            manifest.has("simple_transparent_black_panel_content_margin_bottom"))


func configure_theme() -> void:
    transparent_panel_stylebox = \
            Sc.styles.create_stylebox_scalable(Color.transparent, false)
    
    if is_instance_valid(Sc.styles.overlay_panel_nine_patch):
        overlay_panel_stylebox = Sc.styles.create_stylebox_scalable({
            texture = Sc.styles.overlay_panel_nine_patch,
            texture_scale = Sc.styles.overlay_panel_nine_patch_scale,
            margin_left = \
                    Sc.styles.overlay_panel_nine_patch_margin_left,
            margin_top = \
                    Sc.styles.overlay_panel_nine_patch_margin_top,
            margin_right = \
                    Sc.styles.overlay_panel_nine_patch_margin_right,
            margin_bottom = \
                    Sc.styles.overlay_panel_nine_patch_margin_bottom,
            content_margin_left = \
                    Sc.styles.overlay_panel_content_margin_left,
            content_margin_top = \
                    Sc.styles.overlay_panel_content_margin_top,
            content_margin_right = \
                    Sc.styles.overlay_panel_content_margin_right,
            content_margin_bottom = \
                    Sc.styles.overlay_panel_content_margin_bottom,
        }, false)
    else:
        overlay_panel_stylebox = Sc.styles.create_stylebox_scalable({
            bg_color = Sc.palette.get_color("overlay_panel_background"),
            corner_radius = Sc.styles.overlay_panel_corner_radius,
            corner_detail = Sc.styles.overlay_panel_corner_detail,
            shadow_size = Sc.styles.overlay_panel_shadow_size,
            shadow_offset = Sc.styles.overlay_panel_shadow_offset,
            shadow_color = Sc.palette.get_color("shadow"),
            border_width = Sc.styles.overlay_panel_border_width,
            border_color = Sc.palette.get_color("overlay_panel_border"),
            content_margin_left = \
                    Sc.styles.overlay_panel_content_margin_left,
            content_margin_top = \
                    Sc.styles.overlay_panel_content_margin_top,
            content_margin_right = \
                    Sc.styles.overlay_panel_content_margin_right,
            content_margin_bottom = \
                    Sc.styles.overlay_panel_content_margin_bottom,
        }, false)
    
    if is_instance_valid(Sc.styles.notification_panel_nine_patch):
        notification_panel_stylebox = Sc.styles.create_stylebox_scalable({
            texture = Sc.styles.notification_panel_nine_patch,
            texture_scale = Sc.styles.notification_panel_nine_patch_scale,
            margin_left = \
                    Sc.styles.notification_panel_nine_patch_margin_left,
            margin_top = \
                    Sc.styles.notification_panel_nine_patch_margin_top,
            margin_right = \
                    Sc.styles.notification_panel_nine_patch_margin_right,
            margin_bottom = \
                    Sc.styles.notification_panel_nine_patch_margin_bottom,
            content_margin_left = \
                    Sc.styles.notification_panel_content_margin_left,
            content_margin_top = \
                    Sc.styles.notification_panel_content_margin_top,
            content_margin_right = \
                    Sc.styles.notification_panel_content_margin_right,
            content_margin_bottom = \
                    Sc.styles.notification_panel_content_margin_bottom,
        }, false)
    else:
        notification_panel_stylebox = Sc.styles.create_stylebox_scalable({
            bg_color = Sc.palette.get_color("notification_panel_background"),
            corner_radius = Sc.styles.notification_panel_corner_radius,
            corner_detail = Sc.styles.notification_panel_corner_detail,
            shadow_size = Sc.styles.notification_panel_shadow_size,
            shadow_offset = Sc.styles.notification_panel_shadow_offset,
            shadow_color = Sc.palette.get_color("shadow"),
            border_width = Sc.styles.notification_panel_border_width,
            border_color = Sc.palette.get_color("notification_panel_border"),
            content_margin_left = \
                    Sc.styles.notification_panel_content_margin_left,
            content_margin_top = \
                    Sc.styles.notification_panel_content_margin_top,
            content_margin_right = \
                    Sc.styles.notification_panel_content_margin_right,
            content_margin_bottom = \
                    Sc.styles.notification_panel_content_margin_bottom,
        }, false)
    
    if is_instance_valid(Sc.styles.header_panel_nine_patch):
        header_panel_stylebox = Sc.styles.create_stylebox_scalable({
            texture = Sc.styles.header_panel_nine_patch,
            texture_scale = Sc.styles.header_panel_nine_patch_scale,
            margin_left = Sc.styles.header_panel_nine_patch_margin_left,
            margin_top = Sc.styles.header_panel_nine_patch_margin_top,
            margin_right = Sc.styles.header_panel_nine_patch_margin_right,
            margin_bottom = Sc.styles.header_panel_nine_patch_margin_bottom,
            content_margin_left = Sc.styles.header_panel_content_margin_left,
            content_margin_top = Sc.styles.header_panel_content_margin_top,
            content_margin_right = Sc.styles.header_panel_content_margin_right,
            content_margin_bottom = Sc.styles.header_panel_content_margin_bottom,
        }, false)
    else:
        header_panel_stylebox = Sc.styles.create_stylebox_scalable({
            bg_color = Sc.palette.get_color("header_panel_background"),
            content_margin_left = Sc.styles.header_panel_content_margin_left,
            content_margin_top = Sc.styles.header_panel_content_margin_top,
            content_margin_right = Sc.styles.header_panel_content_margin_right,
            content_margin_bottom = Sc.styles.header_panel_content_margin_bottom,
        }, false)
    
    hud_panel_stylebox = Sc.styles.create_stylebox_scalable({
        texture = Sc.styles.hud_panel_nine_patch,
        texture_scale = Sc.styles.hud_panel_nine_patch_scale,
        margin_left = Sc.styles.hud_panel_nine_patch_margin_left,
        margin_top = Sc.styles.hud_panel_nine_patch_margin_top,
        margin_right = Sc.styles.hud_panel_nine_patch_margin_right,
        margin_bottom = Sc.styles.hud_panel_nine_patch_margin_bottom,
        content_margin_left = Sc.styles.hud_panel_content_margin_left,
        content_margin_top = Sc.styles.hud_panel_content_margin_top,
        content_margin_right = Sc.styles.hud_panel_content_margin_right,
        content_margin_bottom = Sc.styles.hud_panel_content_margin_bottom,
    }, false)
    
    simple_transparent_black_panel_stylebox = Sc.styles.create_stylebox_scalable({
        bg_color = Sc.palette.get_color("simple_transparent_black"),
        corner_radius = Sc.styles.simple_transparent_black_panel_corner_radius,
        corner_detail = Sc.styles.simple_transparent_black_panel_corner_detail,
        shadow_size = 0.0,
        shadow_offset = Vector2.ZERO,
        shadow_color = Sc.palette.get_color("transparent"),
        border_width = 0.0,
        border_color = Sc.palette.get_color("transparent"),
        content_margin_left = \
                Sc.styles.simple_transparent_black_panel_content_margin_left,
        content_margin_top = \
                Sc.styles.simple_transparent_black_panel_content_margin_top,
        content_margin_right = \
                Sc.styles.simple_transparent_black_panel_content_margin_right,
        content_margin_bottom = \
                Sc.styles.simple_transparent_black_panel_content_margin_bottom,
    }, false)
    
    _configure_theme_color(
            "font_color", "Label", Sc.palette.get_color("text"))
    _configure_theme_color(
            "font_color", "Button", Sc.palette.get_color("text"))
    _configure_theme_color(
            "font_color", "CheckBox", Sc.palette.get_color("text"))
    _configure_theme_color(
            "font_color", "ItemList", Sc.palette.get_color("text"))
    _configure_theme_color(
            "font_color", "OptionButton", Sc.palette.get_color("text"))
    _configure_theme_color(
            "font_color", "PopupMenu", Sc.palette.get_color("text"))
    _configure_theme_color(
            "font_color", "Tree", Sc.palette.get_color("text"))
    
    if is_instance_valid(Sc.styles.button_normal_nine_patch):
        _configure_theme_stylebox(
                "disabled", "Button", {
                    texture = Sc.styles.button_disabled_nine_patch,
                    texture_scale = Sc.styles.button_nine_patch_scale,
                    margin_left = Sc.styles.button_nine_patch_margin_left,
                    margin_top = Sc.styles.button_nine_patch_margin_top,
                    margin_right = Sc.styles.button_nine_patch_margin_right,
                    margin_bottom = Sc.styles.button_nine_patch_margin_bottom,
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "focus", "Button", {
                    texture = Sc.styles.focus_border_nine_patch,
                    texture_scale = Sc.styles.focus_border_nine_patch_scale,
                    margin_left = \
                            Sc.styles.focus_border_nine_patch_margin_left,
                    margin_top = \
                            Sc.styles.focus_border_nine_patch_margin_top,
                    margin_right = \
                            Sc.styles.focus_border_nine_patch_margin_right,
                    margin_bottom = \
                            Sc.styles.focus_border_nine_patch_margin_bottom,
                    expand_margin_left = \
                            Sc.styles.focus_border_expand_margin_left,
                    expand_margin_top = \
                            Sc.styles.focus_border_expand_margin_top,
                    expand_margin_right = \
                            Sc.styles.focus_border_expand_margin_right,
                    expand_margin_bottom = \
                            Sc.styles.focus_border_expand_margin_bottom,
                })
        _configure_theme_stylebox(
                "hover", "Button", {
                    texture = Sc.styles.button_hover_nine_patch,
                    texture_scale = Sc.styles.button_nine_patch_scale,
                    margin_left = Sc.styles.button_nine_patch_margin_left,
                    margin_top = Sc.styles.button_nine_patch_margin_top,
                    margin_right = Sc.styles.button_nine_patch_margin_right,
                    margin_bottom = Sc.styles.button_nine_patch_margin_bottom,
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "normal", "Button", {
                    texture = Sc.styles.button_normal_nine_patch,
                    texture_scale = Sc.styles.button_nine_patch_scale,
                    margin_left = Sc.styles.button_nine_patch_margin_left,
                    margin_top = Sc.styles.button_nine_patch_margin_top,
                    margin_right = Sc.styles.button_nine_patch_margin_right,
                    margin_bottom = Sc.styles.button_nine_patch_margin_bottom,
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "pressed", "Button", {
                    texture = Sc.styles.button_pressed_nine_patch,
                    texture_scale = Sc.styles.button_nine_patch_scale,
                    margin_left = Sc.styles.button_nine_patch_margin_left,
                    margin_top = Sc.styles.button_nine_patch_margin_top,
                    margin_right = Sc.styles.button_nine_patch_margin_right,
                    margin_bottom = Sc.styles.button_nine_patch_margin_bottom,
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
    else:
        _configure_theme_stylebox(
                "disabled", "Button", {
                    bg_color = Sc.palette.get_color("button_disabled"),
                    corner_radius = Sc.styles.button_corner_radius,
                    corner_detail = Sc.styles.button_corner_detail,
                    shadow_size = round(Sc.styles.button_shadow_size * 0.0),
                    shadow_color = Sc.palette.get_color("shadow"),
                    border_width = round(Sc.styles.button_border_width * 0.0),
                    border_color = Sc.palette.get_color("button_border"),
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "focus", "Button", {
                    bg_color = Color.transparent,
                    corner_radius = Sc.styles.focus_border_corner_radius,
                    corner_detail = Sc.styles.focus_border_corner_detail,
                    shadow_size = Sc.styles.focus_border_shadow_size,
                    shadow_color = Sc.palette.get_color("shadow"),
                    border_width = Sc.styles.focus_border_border_width,
                    border_color = Sc.palette.get_color("focus_border"),
                    expand_margin_left = \
                            Sc.styles.focus_border_expand_margin_left,
                    expand_margin_top = \
                            Sc.styles.focus_border_expand_margin_top,
                    expand_margin_right = \
                            Sc.styles.focus_border_expand_margin_right,
                    expand_margin_bottom = \
                            Sc.styles.focus_border_expand_margin_bottom,
                })
        _configure_theme_stylebox(
                "hover", "Button", {
                    bg_color = Sc.palette.get_color("button_hover"),
                    corner_radius = Sc.styles.button_corner_radius,
                    corner_detail = Sc.styles.button_corner_detail,
                    shadow_size = round(Sc.styles.button_shadow_size * 1.5),
                    shadow_color = Sc.palette.get_color("shadow"),
                    border_width = Sc.styles.button_border_width,
                    border_color = Sc.palette.get_color("button_border"),
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "normal", "Button", {
                    bg_color = Sc.palette.get_color("button_normal"),
                    corner_radius = Sc.styles.button_corner_radius,
                    corner_detail = Sc.styles.button_corner_detail,
                    shadow_size = Sc.styles.button_shadow_size,
                    shadow_color = Sc.palette.get_color("shadow"),
                    border_width = Sc.styles.button_border_width,
                    border_color = Sc.palette.get_color("button_border"),
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "pressed", "Button", {
                    bg_color = Sc.palette.get_color("button_pressed"),
                    corner_radius = Sc.styles.button_corner_radius,
                    corner_detail = Sc.styles.button_corner_detail,
                    shadow_size = round(Sc.styles.button_shadow_size * 0.2),
                    shadow_color = Sc.palette.get_color("shadow"),
                    border_width = Sc.styles.button_border_width,
                    border_color = Sc.palette.get_color("button_border"),
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
    
    if is_instance_valid(Sc.styles.dropdown_normal_nine_patch):
        _configure_theme_stylebox(
                "disabled", "OptionButton", {
                    texture = Sc.styles.dropdown_disabled_nine_patch,
                    texture_scale = Sc.styles.dropdown_nine_patch_scale,
                    margin_left = Sc.styles.dropdown_nine_patch_margin_left,
                    margin_top = Sc.styles.dropdown_nine_patch_margin_top,
                    margin_right = Sc.styles.dropdown_nine_patch_margin_right,
                    margin_bottom = Sc.styles.dropdown_nine_patch_margin_bottom,
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "focus", "OptionButton", {
                    texture = Sc.styles.focus_border_nine_patch,
                    texture_scale = Sc.styles.focus_border_nine_patch_scale,
                    margin_left = \
                            Sc.styles.focus_border_nine_patch_margin_left,
                    margin_top = \
                            Sc.styles.focus_border_nine_patch_margin_top,
                    margin_right = \
                            Sc.styles.focus_border_nine_patch_margin_right,
                    margin_bottom = \
                            Sc.styles.focus_border_nine_patch_margin_bottom,
                    expand_margin_left = \
                            Sc.styles.focus_border_expand_margin_left,
                    expand_margin_top = \
                            Sc.styles.focus_border_expand_margin_top,
                    expand_margin_right = \
                            Sc.styles.focus_border_expand_margin_right,
                    expand_margin_bottom = \
                            Sc.styles.focus_border_expand_margin_bottom,
                })
        _configure_theme_stylebox(
                "hover", "OptionButton", {
                    texture = Sc.styles.dropdown_hover_nine_patch,
                    texture_scale = Sc.styles.dropdown_nine_patch_scale,
                    margin_left = Sc.styles.dropdown_nine_patch_margin_left,
                    margin_top = Sc.styles.dropdown_nine_patch_margin_top,
                    margin_right = Sc.styles.dropdown_nine_patch_margin_right,
                    margin_bottom = Sc.styles.dropdown_nine_patch_margin_bottom,
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "normal", "OptionButton", {
                    texture = Sc.styles.dropdown_normal_nine_patch,
                    texture_scale = Sc.styles.dropdown_nine_patch_scale,
                    margin_left = Sc.styles.dropdown_nine_patch_margin_left,
                    margin_top = Sc.styles.dropdown_nine_patch_margin_top,
                    margin_right = Sc.styles.dropdown_nine_patch_margin_right,
                    margin_bottom = Sc.styles.dropdown_nine_patch_margin_bottom,
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "pressed", "OptionButton", {
                    texture = Sc.styles.dropdown_pressed_nine_patch,
                    texture_scale = Sc.styles.dropdown_nine_patch_scale,
                    margin_left = Sc.styles.dropdown_nine_patch_margin_left,
                    margin_top = Sc.styles.dropdown_nine_patch_margin_top,
                    margin_right = Sc.styles.dropdown_nine_patch_margin_right,
                    margin_bottom = Sc.styles.dropdown_nine_patch_margin_bottom,
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
    else:
        _configure_theme_stylebox(
                "disabled", "OptionButton", {
                    bg_color = Sc.palette.get_color("dropdown_disabled"),
                    corner_radius = Sc.styles.dropdown_corner_radius,
                    corner_detail = Sc.styles.dropdown_corner_detail,
                    shadow_size = Sc.styles.dropdown_shadow_size,
                    shadow_color = Sc.palette.get_color("shadow"),
                    border_width = Sc.styles.dropdown_border_width,
                    border_color = Sc.palette.get_color("dropdown_border"),
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "focus", "OptionButton", {
                    bg_color = Color.transparent,
                    corner_radius = Sc.styles.focus_border_corner_radius,
                    corner_detail = Sc.styles.focus_border_corner_detail,
                    shadow_size = Sc.styles.focus_border_shadow_size,
                    shadow_color = Sc.palette.get_color("shadow"),
                    border_width = Sc.styles.focus_border_border_width,
                    border_color = Sc.palette.get_color("focus_border"),
                    expand_margin_left = \
                            Sc.styles.focus_border_expand_margin_left,
                    expand_margin_top = \
                            Sc.styles.focus_border_expand_margin_top,
                    expand_margin_right = \
                            Sc.styles.focus_border_expand_margin_right,
                    expand_margin_bottom = \
                            Sc.styles.focus_border_expand_margin_bottom,
                })
        _configure_theme_stylebox(
                "hover", "OptionButton", {
                    bg_color = Sc.palette.get_color("dropdown_hover"),
                    corner_radius = Sc.styles.dropdown_corner_radius,
                    corner_detail = Sc.styles.dropdown_corner_detail,
                    shadow_size = Sc.styles.dropdown_shadow_size,
                    shadow_color = Sc.palette.get_color("shadow"),
                    border_width = Sc.styles.dropdown_border_width,
                    border_color = Sc.palette.get_color("dropdown_border"),
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "normal", "OptionButton", {
                    bg_color = Sc.palette.get_color("dropdown_normal"),
                    corner_radius = Sc.styles.dropdown_corner_radius,
                    corner_detail = Sc.styles.dropdown_corner_detail,
                    shadow_size = Sc.styles.dropdown_shadow_size,
                    shadow_color = Sc.palette.get_color("shadow"),
                    border_width = Sc.styles.dropdown_border_width,
                    border_color = Sc.palette.get_color("dropdown_border"),
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "pressed", "OptionButton", {
                    bg_color = Sc.palette.get_color("dropdown_pressed"),
                    corner_radius = Sc.styles.dropdown_corner_radius,
                    corner_detail = Sc.styles.dropdown_corner_detail,
                    shadow_size = Sc.styles.dropdown_shadow_size,
                    shadow_color = Sc.palette.get_color("shadow"),
                    border_width = Sc.styles.dropdown_border_width,
                    border_color = Sc.palette.get_color("dropdown_border"),
                    content_margin_left = Sc.styles.button_content_margin_left,
                    content_margin_top = Sc.styles.button_content_margin_top,
                    content_margin_right = Sc.styles.button_content_margin_right,
                    content_margin_bottom = Sc.styles.button_content_margin_bottom,
                })
    
    if is_instance_valid(Sc.styles.scroll_track_nine_patch):
        _configure_theme_stylebox(
                "scroll", "HScrollBar", {
                    texture = Sc.styles.scroll_track_nine_patch,
                    texture_scale = Sc.styles.scroll_track_nine_patch_scale,
                    margin_left = Sc.styles.scroll_track_nine_patch_margin_left,
                    margin_top = Sc.styles.scroll_track_nine_patch_margin_top,
                    margin_right = Sc.styles.scroll_track_nine_patch_margin_right,
                    margin_bottom = Sc.styles.scroll_track_nine_patch_margin_bottom,
                })
        _configure_theme_stylebox(
                "grabber", "HScrollBar", {
                    texture = Sc.styles.scroll_grabber_normal_nine_patch,
                    texture_scale = Sc.styles.scroll_grabber_nine_patch_scale,
                    margin_left = Sc.styles.scroll_grabber_nine_patch_margin_left,
                    margin_top = Sc.styles.scroll_grabber_nine_patch_margin_top,
                    margin_right = Sc.styles.scroll_grabber_nine_patch_margin_right,
                    margin_bottom = Sc.styles.scroll_grabber_nine_patch_margin_bottom,
                })
        _configure_theme_stylebox(
                "grabber_highlight", "HScrollBar", {
                    texture = Sc.styles.scroll_grabber_hover_nine_patch,
                    texture_scale = Sc.styles.scroll_grabber_nine_patch_scale,
                    margin_left = Sc.styles.scroll_grabber_nine_patch_margin_left,
                    margin_top = Sc.styles.scroll_grabber_nine_patch_margin_top,
                    margin_right = Sc.styles.scroll_grabber_nine_patch_margin_right,
                    margin_bottom = Sc.styles.scroll_grabber_nine_patch_margin_bottom,
                })
        _configure_theme_stylebox(
                "grabber_pressed", "HScrollBar", {
                    texture = Sc.styles.scroll_grabber_pressed_nine_patch,
                    texture_scale = Sc.styles.scroll_grabber_nine_patch_scale,
                    margin_left = Sc.styles.scroll_grabber_nine_patch_margin_left,
                    margin_top = Sc.styles.scroll_grabber_nine_patch_margin_top,
                    margin_right = Sc.styles.scroll_grabber_nine_patch_margin_right,
                    margin_bottom = Sc.styles.scroll_grabber_nine_patch_margin_bottom,
                })
        
        _configure_theme_stylebox(
                "scroll", "VScrollBar", {
                    texture = Sc.styles.scroll_track_nine_patch,
                    texture_scale = Sc.styles.scroll_track_nine_patch_scale,
                    margin_left = Sc.styles.scroll_track_nine_patch_margin_left,
                    margin_top = Sc.styles.scroll_track_nine_patch_margin_top,
                    margin_right = Sc.styles.scroll_track_nine_patch_margin_right,
                    margin_bottom = Sc.styles.scroll_track_nine_patch_margin_bottom,
                })
        _configure_theme_stylebox(
                "grabber", "VScrollBar", {
                    texture = Sc.styles.scroll_grabber_normal_nine_patch,
                    texture_scale = Sc.styles.scroll_grabber_nine_patch_scale,
                    margin_left = Sc.styles.scroll_grabber_nine_patch_margin_left,
                    margin_top = Sc.styles.scroll_grabber_nine_patch_margin_top,
                    margin_right = Sc.styles.scroll_grabber_nine_patch_margin_right,
                    margin_bottom = Sc.styles.scroll_grabber_nine_patch_margin_bottom,
                })
        _configure_theme_stylebox(
                "grabber_highlight", "VScrollBar", {
                    texture = Sc.styles.scroll_grabber_hover_nine_patch,
                    texture_scale = Sc.styles.scroll_grabber_nine_patch_scale,
                    margin_left = Sc.styles.scroll_grabber_nine_patch_margin_left,
                    margin_top = Sc.styles.scroll_grabber_nine_patch_margin_top,
                    margin_right = Sc.styles.scroll_grabber_nine_patch_margin_right,
                    margin_bottom = Sc.styles.scroll_grabber_nine_patch_margin_bottom,
                })
        _configure_theme_stylebox(
                "grabber_pressed", "VScrollBar", {
                    texture = Sc.styles.scroll_grabber_pressed_nine_patch,
                    texture_scale = Sc.styles.scroll_grabber_nine_patch_scale,
                    margin_left = Sc.styles.scroll_grabber_nine_patch_margin_left,
                    margin_top = Sc.styles.scroll_grabber_nine_patch_margin_top,
                    margin_right = Sc.styles.scroll_grabber_nine_patch_margin_right,
                    margin_bottom = Sc.styles.scroll_grabber_nine_patch_margin_bottom,
                })
    else:
        _configure_theme_stylebox(
                "scroll", "HScrollBar", {
                    bg_color = Sc.palette.get_color("scroll_bar_background"),
                    corner_radius = Sc.styles.scroll_corner_radius,
                    corner_detail = Sc.styles.scroll_corner_detail,
                    content_margin_left = Sc.styles.scroll_content_margin_left,
                    content_margin_top = Sc.styles.scroll_content_margin_top,
                    content_margin_right = Sc.styles.scroll_content_margin_right,
                    content_margin_bottom = Sc.styles.scroll_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "grabber", "HScrollBar", {
                    bg_color = Sc.palette.get_color("scroll_bar_grabber_normal"),
                    corner_radius = Sc.styles.scroll_grabber_corner_radius,
                    corner_detail = Sc.styles.scroll_grabber_corner_detail,
                })
        _configure_theme_stylebox(
                "grabber_highlight", "HScrollBar", {
                    bg_color = Sc.palette.get_color("scroll_bar_grabber_hover"),
                    corner_radius = Sc.styles.scroll_grabber_corner_radius,
                    corner_detail = Sc.styles.scroll_grabber_corner_detail,
                })
        _configure_theme_stylebox(
                "grabber_pressed", "HScrollBar", {
                    bg_color = Sc.palette.get_color("scroll_bar_grabber_pressed"),
                    corner_radius = Sc.styles.scroll_grabber_corner_radius,
                    corner_detail = Sc.styles.scroll_grabber_corner_detail,
                })
        
        _configure_theme_stylebox(
                "scroll", "VScrollBar", {
                    bg_color = Sc.palette.get_color("scroll_bar_background"),
                    corner_radius = Sc.styles.scroll_corner_radius,
                    corner_detail = Sc.styles.scroll_corner_detail,
                    content_margin_left = Sc.styles.scroll_content_margin_left,
                    content_margin_top = Sc.styles.scroll_content_margin_top,
                    content_margin_right = Sc.styles.scroll_content_margin_right,
                    content_margin_bottom = Sc.styles.scroll_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "grabber", "VScrollBar", {
                    bg_color = Sc.palette.get_color("scroll_bar_grabber_normal"),
                    corner_radius = Sc.styles.scroll_grabber_corner_radius,
                    corner_detail = Sc.styles.scroll_grabber_corner_detail,
                })
        _configure_theme_stylebox(
                "grabber_highlight", "VScrollBar", {
                    bg_color = Sc.palette.get_color("scroll_bar_grabber_hover"),
                    corner_radius = Sc.styles.scroll_grabber_corner_radius,
                    corner_detail = Sc.styles.scroll_grabber_corner_detail,
                })
        _configure_theme_stylebox(
                "grabber_pressed", "VScrollBar", {
                    bg_color = Sc.palette.get_color("scroll_bar_grabber_pressed"),
                    corner_radius = Sc.styles.scroll_grabber_corner_radius,
                    corner_detail = Sc.styles.scroll_grabber_corner_detail,
                })
    
    if is_instance_valid(Sc.styles.slider_track_nine_patch):
        _configure_theme_stylebox(
                "slider", "HSlider", {
                    texture = Sc.styles.slider_track_nine_patch,
                    texture_scale = Sc.styles.slider_track_nine_patch_scale,
                    margin_left = Sc.styles.slider_track_nine_patch_margin_left,
                    margin_top = Sc.styles.slider_track_nine_patch_margin_top,
                    margin_right = Sc.styles.slider_track_nine_patch_margin_right,
                    margin_bottom = Sc.styles.slider_track_nine_patch_margin_bottom,
                })
        _configure_theme_stylebox(
                "slider", "VSlider", {
                    texture = Sc.styles.slider_track_nine_patch,
                    texture_scale = Sc.styles.slider_track_nine_patch_scale,
                    margin_left = Sc.styles.slider_track_nine_patch_margin_left,
                    margin_top = Sc.styles.slider_track_nine_patch_margin_top,
                    margin_right = Sc.styles.slider_track_nine_patch_margin_right,
                    margin_bottom = Sc.styles.slider_track_nine_patch_margin_bottom,
                })
    else:
        _configure_theme_stylebox(
                "slider", "HSlider", {
                    bg_color = Sc.palette.get_color("slider_background"),
                    corner_radius = Sc.styles.slider_corner_radius,
                    corner_detail = Sc.styles.slider_corner_detail,
                    content_margin_left = Sc.styles.slider_content_margin_left,
                    content_margin_top = Sc.styles.slider_content_margin_top,
                    content_margin_right = Sc.styles.slider_content_margin_right,
                    content_margin_bottom = Sc.styles.slider_content_margin_bottom,
                })
        _configure_theme_stylebox(
                "slider", "VSlider", {
                    bg_color = Sc.palette.get_color("slider_background"),
                    corner_radius = Sc.styles.slider_corner_radius,
                    corner_detail = Sc.styles.slider_corner_detail,
                    content_margin_left = Sc.styles.slider_content_margin_left,
                    content_margin_top = Sc.styles.slider_content_margin_top,
                    content_margin_right = Sc.styles.slider_content_margin_right,
                    content_margin_bottom = Sc.styles.slider_content_margin_bottom,
                })
    
    _configure_theme_stylebox(
            "grabber_area", "HSlider", Color.transparent)
    _configure_theme_stylebox(
            "grabber_area_highlight", "HSlider", Color.transparent)
    _configure_theme_stylebox(
            "grabber_area", "VSlider", Color.transparent)
    _configure_theme_stylebox(
            "grabber_area_highlight", "VSlider", Color.transparent)
    
    _configure_theme_stylebox(
            "panel", "PopupMenu", Sc.styles.overlay_panel_stylebox)
    _configure_theme_stylebox(
            "panel", "Panel", Sc.palette.get_color("background"))
    _configure_theme_stylebox(
            "panel", "PanelContainer", Sc.palette.get_color("background"))
    _configure_theme_stylebox(
            "bg", "Tree", Color.transparent)
    
    _configure_theme_stylebox(
            "disabled", "CheckBox", Color.transparent)
    _configure_theme_stylebox(
            "focus", "CheckBox", Color.transparent)
    _configure_theme_stylebox(
            "hover", "CheckBox", Color.transparent)
    _configure_theme_stylebox(
            "hover_pressed", "CheckBox", Color.transparent)
    _configure_theme_stylebox(
            "normal", "CheckBox", Color.transparent)
    _configure_theme_stylebox(
            "pressed", "CheckBox", Color.transparent)
    
    if Sc.gui.theme.default_font == null:
        Sc.gui.theme.default_font = Sc.gui.fonts.main_m
    
    Sc.gui.theme.set_font("font", "TooltipLabel", Sc.gui.fonts.main_xs)
    _configure_theme_color( \
            "font_color", "TooltipLabel", Sc.palette.get_color("tooltip"))
    _configure_theme_stylebox( \
            "panel", "TooltipPanel", Sc.palette.get_color("tooltip_bg"))


func _configure_theme_color(
        name: String,
        type: String,
        color: Color) -> void:
    if !Sc.gui.theme.has_color(name, type):
        Sc.gui.theme.set_color(name, type, color)


func _configure_theme_stylebox(
        name: String,
        type: String,
        config) -> void:
    if !Sc.gui.theme.has_stylebox(name, type):
        var stylebox: StyleBox = \
                Sc.styles.create_stylebox_scalable(config, false)
        Sc.gui.theme.set_stylebox(name, type, stylebox)
    else:
        var old: StyleBox = Sc.gui.theme.get_stylebox(name, type)
        if !(old is StyleBoxFlatScalable or \
                old is StyleBoxTextureScalable):
            var new: StyleBox = Sc.styles.create_stylebox_scalable(old, false)
            Sc.gui.theme.set_stylebox(name, type, new)


func create_stylebox_scalable(
        config,
        has_local_lifecycle: bool) -> StyleBox:
    if config is Color:
        var stylebox := StyleBoxFlatScalable.new()
        stylebox.bg_color = config
        stylebox.has_local_lifecycle = has_local_lifecycle
        stylebox.ready()
        return stylebox
    elif config is Dictionary:
        if config.has("texture"):
            return _create_stylebox_texture_scalable_from_config(
                    config, has_local_lifecycle)
        else:
            return _create_stylebox_flat_scalable_from_config(
                    config, has_local_lifecycle)
    elif config is StyleBoxTexture:
        return _create_stylebox_texture_scalable_from_stylebox(
                config, has_local_lifecycle)
    elif config is StyleBox:
        return _create_stylebox_flat_scalable_from_stylebox(
                config, has_local_lifecycle)
    else:
        Sc.logger.error("ScaffolderStyles.create_stylebox_scalable")
        return null


func _create_stylebox_texture_scalable_from_config(
        config: Dictionary,
        has_local_lifecycle: bool) -> StyleBoxTextureScalable:
    var stylebox := StyleBoxTextureScalable.new()
    stylebox.texture = config.texture
    
    if config.has("texture_scale"):
        stylebox.initial_texture_scale = config.texture_scale
    if config.has("margin_left"):
        stylebox.margin_bottom = config.margin_bottom
        stylebox.margin_left = config.margin_left
        stylebox.margin_right = config.margin_right
        stylebox.margin_top = config.margin_top
    if config.has("expand_margin_left"):
        stylebox.expand_margin_bottom = config.expand_margin_bottom
        stylebox.expand_margin_left = config.expand_margin_left
        stylebox.expand_margin_right = config.expand_margin_right
        stylebox.expand_margin_top = config.expand_margin_top
    if config.has("content_margin_left"):
        stylebox.content_margin_bottom = config.content_margin_bottom
        stylebox.content_margin_left = config.content_margin_left
        stylebox.content_margin_right = config.content_margin_right
        stylebox.content_margin_top = config.content_margin_top
    else:
        # Setting content-margin to 0 is important for preventing buttons from
        # forcing an undesirable min height.
        stylebox.content_margin_bottom = 0
        stylebox.content_margin_left = 0
        stylebox.content_margin_right = 0
        stylebox.content_margin_top = 0
    
    stylebox.has_local_lifecycle = has_local_lifecycle
    
    stylebox.ready()
    
    return stylebox


func _create_stylebox_texture_scalable_from_stylebox(
        old: StyleBoxTexture,
        has_local_lifecycle: bool) -> StyleBoxTextureScalable:
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
    
    if old is StyleBoxTextureScalable and \
            is_instance_valid(old.initial_texture):
        new.texture = old.initial_texture
        new.content_margin_left = old.initial_content_margin_left
        new.content_margin_top = old.initial_content_margin_top
        new.content_margin_right = old.initial_content_margin_right
        new.content_margin_bottom = old.initial_content_margin_bottom
        new.expand_margin_left = old.initial_expand_margin_left
        new.expand_margin_top = old.initial_expand_margin_top
        new.expand_margin_right = old.initial_expand_margin_right
        new.expand_margin_bottom = old.initial_expand_margin_bottom
        new.margin_left = old.initial_margin_left
        new.margin_top = old.initial_margin_top
        new.margin_right = old.initial_margin_right
        new.margin_bottom = old.initial_margin_bottom
        new.initial_texture_scale = old.initial_texture_scale
    
    new.has_local_lifecycle = has_local_lifecycle
    
    new.ready()
    
    return new


func _create_stylebox_flat_scalable_from_config(
        config: Dictionary,
        has_local_lifecycle: bool) -> StyleBoxFlatScalable:
    var stylebox: StyleBoxFlatScalable
    if config.has("stylebox"):
        stylebox = _create_stylebox_flat_scalable_from_stylebox(
                config.stylebox, has_local_lifecycle)
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
    if config.has("content_margin_left"):
        stylebox.content_margin_left = config.content_margin_left
        stylebox.content_margin_top = config.content_margin_top
        stylebox.content_margin_right = config.content_margin_right
        stylebox.content_margin_bottom = config.content_margin_bottom
    if config.has("corner_detail"):
        stylebox.corner_detail = config.corner_detail
    if config.has("corner_radius"):
        stylebox.corner_radius_top_left = config.corner_radius
        stylebox.corner_radius_top_right = config.corner_radius
        stylebox.corner_radius_bottom_left = config.corner_radius
        stylebox.corner_radius_bottom_right = config.corner_radius
    if config.has("expand_margin_left"):
        stylebox.expand_margin_left = config.expand_margin_left
        stylebox.expand_margin_top = config.expand_margin_top
        stylebox.expand_margin_right = config.expand_margin_right
        stylebox.expand_margin_bottom = config.expand_margin_bottom
    if config.has("shadow_color"):
        stylebox.shadow_color = config.shadow_color
    if config.has("shadow_offset"):
        stylebox.shadow_offset = config.shadow_offset
    if config.has("shadow_size"):
        stylebox.shadow_size = config.shadow_size
    
    stylebox.has_local_lifecycle = has_local_lifecycle
    
    stylebox.ready()
    
    return stylebox


func _create_stylebox_flat_scalable_from_stylebox(
        old: StyleBox,
        has_local_lifecycle: bool) -> StyleBoxFlatScalable:
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
    
    new.has_local_lifecycle = has_local_lifecycle
    
    new.ready()
    
    return new

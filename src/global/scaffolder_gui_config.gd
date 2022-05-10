tool
class_name ScaffolderGuiConfig
extends Node


# --- Constants ---

const GUI_COLLISION_LAYER_BIT := 30
const GUI_COLLISION_LAYER := 1 << GUI_COLLISION_LAYER_BIT

const ACCORDION_PANEL_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/accordion_panel.tscn")
const CENTERED_PANEL_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/centered_panel.tscn")
const FULL_SCREEN_PANEL_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/full_screen_panel.tscn")
const SCAFFOLDER_BUTTON_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/scaffolder_button.tscn")
const SCAFFOLDER_CHECK_BOX_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/scaffolder_check_box.tscn")
const SCAFFOLDER_H_SEPARATOR := preload( \
        "res://addons/scaffolder/src/gui/widgets/scaffolder_h_separator.tscn")
const SCAFFOLDER_V_SEPARATOR := preload( \
        "res://addons/scaffolder/src/gui/widgets/scaffolder_v_separator.tscn")
const SCAFFOLDER_LABEL_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/scaffolder_label.tscn")
const SCAFFOLDER_LABEL_LINK_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/scaffolder_label_link.tscn")
const SCAFFOLDER_PROGRESS_BAR_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/scaffolder_progress_bar.tscn")
const SCAFFOLDER_SLIDER_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/scaffolder_slider.tscn")
const SCAFFOLDER_TEXTURE_BUTTON_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/scaffolder_texture_button.tscn")
const SCAFFOLDER_TEXTURE_LINK_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/scaffolder_texture_link.tscn")
const SCAFFOLDER_TEXTURE_RECT_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/scaffolder_texture_rect.tscn")
const SPACER_SCENE := preload( \
        "res://addons/scaffolder/src/gui/widgets/spacer.tscn")

const WELCOME_PANEL_PATH := \
        "res://addons/scaffolder/src/gui/welcome_panel.tscn"
const DEBUG_PANEL_PATH := \
        "res://addons/scaffolder/src/gui/debug_panel.tscn"
const DEFAULT_HUD_KEY_VALUE_BOX_PATH := \
        "res://addons/scaffolder/src/gui/hud/hud_key_value_box.tscn"
const DEFAULT_HUD_KEY_VALUE_LIST_PATH := \
        "res://addons/scaffolder/src/gui/hud/hud_key_value_list.tscn"

const MIN_GUI_SCALE := 0.2

# Useful for getting screenshots at specific resolutions.
const SCREEN_RESOLUTIONS := {
    # Should match Project Settings > Display > Window > Size > Width/Height
    default = Vector2(1024, 768),
    full_screen = Vector2.INF,
    play_store = Vector2(3840, 2160),
    iphone_6_5 = Vector2(2778, 1284),
    iphone_5_5 = Vector2(2208, 1242),
    ipad_12_9 = Vector2(2732, 2048),
    google_ads_landscape = Vector2(1024, 768),
    google_ads_portrait = Vector2(768, 1024),
    youtube = Vector2(3200, 1800),
}

# --- Static configuration state ---

var default_pc_game_area_size: Vector2
var default_mobile_game_area_size: Vector2

var aspect_ratio_max: float
var aspect_ratio_min: float

var debug_window_size: Vector2
var moves_debug_game_window_to_other_monitor: bool

var button_height := 56.0
var button_width := 230.0
var screen_body_width := 460.0

var is_data_deletion_button_shown: bool

var is_suggested_button_shine_line_shown := true
var is_suggested_button_color_pulse_shown := true

var input_vibrate_duration := 0.01

var display_resize_throttle_interval := 0.1

var recent_gesture_events_for_debugging_buffer_size := 1000

var display_time_type := TimeType.PLAY_PHYSICS_SCALED

var third_party_license_text: String
var special_thanks_text: String

var main_menu_image_scale: float
var game_over_image_scale: float
var loading_image_scale: float

var main_menu_image_scene: PackedScene
var game_over_image_scene: PackedScene
var loading_image_scene: PackedScene
var welcome_panel_scene: PackedScene
var debug_panel_scene: PackedScene
var info_panel_scene: PackedScene

var theme: Theme

var fonts: Dictionary

var fonts_manifest: Dictionary
var settings_item_manifest: Dictionary
var pause_item_manifest: Array
var game_over_item_manifest: Array
var level_select_item_manifest: Array
var hud_manifest: Dictionary
var welcome_panel_manifest: Dictionary
var screen_manifest: Dictionary

# --- Derived configuration ---

var is_special_thanks_shown: bool
var is_third_party_licenses_shown: bool
var is_rate_app_shown: bool
var is_support_shown: bool
var is_gesture_logging_supported: bool
var is_developer_logo_shown: bool
var is_developer_splash_shown: bool
var is_main_menu_image_shown: bool
var is_game_over_image_shown: bool
var is_loading_image_shown: bool
var does_app_contain_welcome_panel: bool
var is_welcome_panel_shown: bool
var font_size_overrides: Dictionary
var original_font_dimensions: Dictionary
var splash_scale: float

# --- Global state ---

var game_area_region: Rect2
var previous_scale := 1.0
var scale := 1.0

var is_giving_haptic_feedback: bool
var is_debug_panel_shown: bool setget \
        _set_is_debug_panel_shown, _get_is_debug_panel_shown
var is_debug_time_shown: bool
var is_player_interaction_enabled := true

var debug_panel: DebugPanel
var hud: ScaffolderHud
var welcome_panel: WelcomePanel
var gesture_record: GestureRecord

# Dictionary<Object, bool>
var guis_to_scale := {}
# Array<Node>
var active_overlays := []
# Dictionary<Texture, Dictionary<Vector2, Texture>>
var original_texture_to_size_to_scaled_texture := {}

# ---


func _init() -> void:
    Sc.logger.on_global_init(self, "ScaffolderGuiConfig")


func _amend_manifest(manifest: Dictionary) -> void:
    # Configure settings-screen enablement items for each HUD key-value-list
    # item.
    for item_config in manifest.hud_manifest.hud_key_value_list_item_manifest:
        if !item_config.has("settings_group_key"):
            continue
        assert(manifest.settings_item_manifest.groups.has(
                item_config.settings_group_key))
        var settings_group: Dictionary = manifest.settings_item_manifest \
                .groups[item_config.settings_group_key]
        if !settings_group.has("hud_enablement_items"):
            settings_group.hud_enablement_items = []
        settings_group.hud_enablement_items.push_back(item_config)


func _parse_manifest(manifest: Dictionary) -> void:
    _amend_manifest(manifest)
    
    if Engine.editor_hint:
        # Duplicate the theme, so that we don't save changes to a file.
        # NOTE: This has a strange side-effect of messing-up scroll-bar
        #       positioning. For some reason, the scrollbar will be resized
        #       correctly, but not repositioned for it's new size.
        self.theme = manifest.theme.duplicate()
    else:
        self.theme = manifest.theme
    
    self.default_pc_game_area_size = manifest.default_pc_game_area_size
    self.default_mobile_game_area_size = manifest.default_mobile_game_area_size
    self.aspect_ratio_max = manifest.aspect_ratio_max
    self.aspect_ratio_min = manifest.aspect_ratio_min
    self.debug_window_size = manifest.debug_window_size
    self.moves_debug_game_window_to_other_monitor = \
            manifest.moves_debug_game_window_to_other_monitor
    self.is_data_deletion_button_shown = manifest.is_data_deletion_button_shown
    self.is_suggested_button_shine_line_shown = \
            manifest.is_suggested_button_shine_line_shown
    self.is_suggested_button_color_pulse_shown = \
            manifest.is_suggested_button_color_pulse_shown
    
    self.settings_item_manifest = manifest.settings_item_manifest
    self.pause_item_manifest = manifest.pause_item_manifest
    self.game_over_item_manifest = manifest.game_over_item_manifest
    self.level_select_item_manifest = manifest.level_select_item_manifest
    self.screen_manifest = manifest.screen_manifest
    self.welcome_panel_manifest = manifest.welcome_panel_manifest
    self.hud_manifest = manifest.hud_manifest
    self.fonts_manifest = manifest.fonts_manifest
    self.fonts = manifest.fonts_manifest.fonts
    self.third_party_license_text = \
            manifest.third_party_license_text.strip_edges()
    self.special_thanks_text = manifest.special_thanks_text.strip_edges()
    
    if manifest.has("main_menu_image_scale"):
        self.main_menu_image_scale = manifest.main_menu_image_scale
    if manifest.has("game_over_image_scale"):
        self.game_over_image_scale = manifest.game_over_image_scale
    if manifest.has("loading_image_scale"):
        self.loading_image_scale = manifest.loading_image_scale
    
    if manifest.has("main_menu_image_scene"):
        self.main_menu_image_scene = manifest.main_menu_image_scene
    if manifest.has("game_over_image_scene"):
        self.game_over_image_scene = manifest.game_over_image_scene
    if manifest.has("loading_image_scene"):
        self.loading_image_scene = manifest.loading_image_scene
    if manifest.has("welcome_panel_scene"):
        self.welcome_panel_scene = manifest.welcome_panel_scene
    if manifest.has("debug_panel_scene"):
        self.debug_panel_scene = manifest.debug_panel_scene
    if manifest.has("info_panel_scene"):
        self.info_panel_scene = manifest.info_panel_scene
    
    if manifest.has("button_height"):
        self.button_height = manifest.button_height
    if manifest.has("button_width"):
        self.button_width = manifest.button_width
    if manifest.has("screen_body_width"):
        self.screen_body_width = manifest.screen_body_width
    if manifest.has("input_vibrate_duration"):
        self.input_vibrate_duration = \
                manifest.input_vibrate_duration
    if manifest.has("display_resize_throttle_interval"):
        self.display_resize_throttle_interval = \
                manifest.display_resize_throttle_interval
    if manifest.has("recent_gesture_events_for_debugging_buffer_size"):
        self.recent_gesture_events_for_debugging_buffer_size = \
                manifest.recent_gesture_events_for_debugging_buffer_size
    if manifest.has("display_time_type"):
        self.display_time_type = manifest.display_time_type
    
    if fonts_manifest.has("sizes"):
        if Sc.device.get_is_mobile_device():
            if fonts_manifest.sizes.has("mobile"):
                self.font_size_overrides = fonts_manifest.sizes.mobile
        else:
            if fonts_manifest.sizes.has("pc"):
                self.font_size_overrides = fonts_manifest.sizes.pc
    
    if Sc.device.get_is_mobile_device():
        if manifest.has("splash_scale_mobile"):
            self.splash_scale = manifest.splash_scale_mobile
    else:
        if manifest.has("splash_scale_pc"):
            self.splash_scale = manifest.splash_scale_pc
    
    self.is_special_thanks_shown = !self.special_thanks_text.empty()
    self.is_third_party_licenses_shown = !self.third_party_license_text.empty()
    self.is_rate_app_shown = \
            !Sc.metadata.android_app_store_url.empty() and \
            !Sc.metadata.ios_app_store_url.empty()
    self.is_support_shown = \
            !Sc.metadata.support_url.empty() and \
            !Sc.metadata.app_id_query_param.empty()
    self.is_developer_logo_shown = Sc.images.developer_logo != null
    self.is_developer_splash_shown = \
            Sc.images.developer_splash != null and \
            Sc.audio_manifest.developer_splash_sound != ""
    self.is_main_menu_image_shown = self.main_menu_image_scene != null
    self.is_game_over_image_shown = self.game_over_image_scene != null
    self.is_loading_image_shown = self.loading_image_scene != null
    self.does_app_contain_welcome_panel = self.welcome_panel_scene != null
    self.is_gesture_logging_supported = \
            !Sc.metadata.log_gestures_url.empty() and \
            !Sc.metadata.app_id_query_param.empty()
    
    _record_original_font_dimensions()
    
    _initialize_hud_key_value_list_item_enablement()
    
    if !Sc.metadata.uses_level_scores:
        for manifest in [
                    pause_item_manifest,
                    game_over_item_manifest,
                    level_select_item_manifest,
                ]:
            manifest.erase(ScoreControlRow)
            manifest.erase(HighScoreControlRow)


func add_gui_to_scale(gui) -> void:
    guis_to_scale[gui] = true
    Sc.gui._scale_gui_for_current_screen_size(gui)


func remove_gui_to_scale(gui) -> void:
    guis_to_scale.erase(gui)


func _set_is_debug_panel_shown(is_visible: bool) -> void:
    is_debug_panel_shown = is_visible
    if debug_panel != null:
        debug_panel.visible = is_visible


func _get_is_debug_panel_shown() -> bool:
    return is_debug_panel_shown


func _record_original_font_dimensions() -> void:
    for font_name in fonts:
        var scale: float = \
                float(font_size_overrides[font_name]) / \
                        fonts[font_name].size if \
                font_size_overrides.has(font_name) else \
                1.0
        
        var dimensions := {}
        original_font_dimensions[font_name] = dimensions
        for dimension_name in [
                    "size",
                    "extra_spacing_top",
                    "extra_spacing_bottom",
                    "extra_spacing_char",
                    "extra_spacing_space",
                ]:
             dimensions[dimension_name] = \
                    fonts[font_name].get(dimension_name) * scale


func _initialize_hud_key_value_list_item_enablement() -> void:
    for item_config in hud_manifest.hud_key_value_list_item_manifest:
        item_config.settings_key = _get_key_value_item_enabled_settings_key(
                item_config.settings_enablement_label)
        item_config.enabled = Sc.save_state.get_setting(
                item_config.settings_key,
                item_config.enabled_by_default)


func _get_key_value_item_enabled_settings_key(
        settings_enablement_label: String) -> String:
    return settings_enablement_label.replace(" ", "_") + "_hud"


func font_size_to_string(size: int) -> String:
    match size:
        FontSize.XS:
            return "Xs"
        FontSize.S:
            return "S"
        FontSize.M:
            return "M"
        FontSize.L:
            return "L"
        FontSize.XL:
            return "Xl"
        _:
            Sc.logger.error("ScaffolderGuiConfig.font_size_to_string")
            return ""


func string_to_font_size(string: String) -> int:
    match string:
        "Xs":
            return FontSize.XS
        "S":
            return FontSize.S
        "M":
            return FontSize.M
        "L":
            return FontSize.L
        "Xl":
            return FontSize.XL
        _:
            Sc.logger.error("ScaffolderGuiConfig.string_to_font_size")
            return FontSize.M


func get_font(
        size,
        is_header := false,
        is_bold := false,
        is_italic := false) -> Font:
    var context_part := \
            "header" if \
            is_header else \
            "main"
    var bold_part := \
            "_bold" if \
            is_bold else \
            ""
    var italic_part := \
            "_italic" if \
            is_italic else \
            ""
    var size_string: String = \
            size if \
            size is String else \
            Sc.gui.font_size_to_string(size)
    var size_part := "_" + size_string.to_lower()
    var font_key := context_part + size_part + bold_part + italic_part
    return Sc.gui.fonts[font_key]


func _update_font_sizes() -> void:
    # First, update the fonts that don't have size overrides.
    for font_name in Sc.gui.fonts:
        if Sc.gui.font_size_overrides.has(font_name):
            continue
        _update_sizes_for_font(font_name)
    
    # Second, update the fonts with size overrides.
    for font_name in Sc.gui.font_size_overrides:
        _update_sizes_for_font(font_name)


func _update_sizes_for_font(font_name: String) -> void:
    var original_dimensions: Dictionary = \
            Sc.gui.original_font_dimensions[font_name]
    for dimension_name in original_dimensions:
        Sc.gui.fonts[font_name].set(
                dimension_name,
                original_dimensions[dimension_name] * Sc.gui.scale)


func _update_game_area_region_and_gui_scale() -> void:
    var viewport_size: Vector2 = Sc.device.get_viewport_size()
    var aspect_ratio := viewport_size.x / viewport_size.y
    var game_area_position := Vector2.INF
    var game_area_size := Vector2.INF
    
    if !Sc.metadata.is_app_configured:
        game_area_size = viewport_size
        game_area_position = Vector2.ZERO
    if aspect_ratio < Sc.gui.aspect_ratio_min:
        # Show vertical margin around game area.
        game_area_size = Vector2(
                viewport_size.x,
                viewport_size.x / Sc.gui.aspect_ratio_min)
        game_area_position = Vector2(
                0.0,
                (viewport_size.y - game_area_size.y) * 0.5)
    elif aspect_ratio > Sc.gui.aspect_ratio_max:
        # Show horizontal margin around game area.
        game_area_size = Vector2(
                viewport_size.y * Sc.gui.aspect_ratio_max,
                viewport_size.y)
        game_area_position = Vector2(
                (viewport_size.x - game_area_size.x) * 0.5,
                0.0)
    else:
        # Show no margins around game area.
        game_area_size = viewport_size
        game_area_position = Vector2.ZERO
    
    Sc.gui.game_area_region = Rect2(game_area_position, game_area_size)
    
    if Sc.metadata.is_app_configured:
        var default_game_area_size: Vector2 = \
                Sc.gui.default_mobile_game_area_size if \
                Sc.device.get_is_mobile_device() else \
                Sc.gui.default_pc_game_area_size
        var default_aspect_ratio: float = \
                default_game_area_size.x / default_game_area_size.y
        Sc.gui.previous_scale = Sc.gui.scale
        Sc.gui.scale = \
                viewport_size.x / default_game_area_size.x if \
                aspect_ratio < default_aspect_ratio else \
                viewport_size.y / default_game_area_size.y
        Sc.gui.scale = \
                max(Sc.gui.scale, Sc.gui.MIN_GUI_SCALE)


func _scale_guis() -> void:
    if Sc.gui.previous_scale != Sc.gui.scale:
        original_texture_to_size_to_scaled_texture.clear()
        
        for gui in Sc.gui.guis_to_scale:
            assert(is_instance_valid(gui))
            Sc.gui._scale_gui_for_current_screen_size(gui)


# Automatically resize the gui to adapt to different screen sizes.
func _scale_gui_for_current_screen_size(gui) -> void:
    if !is_instance_valid(gui) or \
            !Sc.gui.guis_to_scale.has(gui):
        Sc.logger.error("ScaffolderGuiConfig._scale_gui_for_current_screen_size")
        return
    
    Sc.gui.scale_gui_recursively(gui)


func scale_gui_recursively(gui) -> void:
    if gui.has_method("_on_gui_scale_changed"):
        var handled: bool = gui._on_gui_scale_changed()
        if handled:
            return
    
    assert(gui is Control)
    var control: Control = gui
    var scale: float = Sc.gui.scale
    
    Sc.gui._record_gui_original_simple_dimensions(control)
    
    if control is VBoxContainer or \
            control is HBoxContainer:
        var original_separation: float = \
                control.get_meta("sc_separation") if \
                control.has_meta("sc_separation") else \
                INF
        var separation := round(original_separation * scale)
        control.add_constant_override("separation", separation)
    
    if control is MarginContainer:
        var original_margin_right: float = \
                control.get_meta("sc_margin_right") if \
                control.has_meta("sc_margin_right") else \
                INF
        var original_margin_top: float = \
                control.get_meta("sc_margin_top") if \
                control.has_meta("sc_margin_top") else \
                INF
        var original_margin_left: float = \
                control.get_meta("sc_margin_left") if \
                control.has_meta("sc_margin_left") else \
                INF
        var original_margin_bottom: float = \
                control.get_meta("sc_margin_bottom") if \
                control.has_meta("sc_margin_bottom") else \
                INF
        var margin_right := round(original_margin_right * scale)
        control.add_constant_override("margin_right", margin_right)
        var margin_top := round(original_margin_top * scale)
        control.add_constant_override("margin_top", margin_top)
        var margin_left := round(original_margin_left * scale)
        control.add_constant_override("margin_left", margin_left)
        var margin_bottom := round(original_margin_bottom * scale)
        control.add_constant_override("margin_bottom", margin_bottom)
    
    if control.has_meta("sc_rect_min_size"):
        control.rect_min_size = Sc.utils \
                .round_vector(control.get_meta("sc_rect_min_size") * scale)
    if control.has_meta("sc_rect_size"):
        control.rect_size = Sc.utils \
                .round_vector(control.get_meta("sc_rect_size") * scale)
    if control.has_meta("sc_rect_scale"):
        control.rect_scale = Sc.utils \
                .round_vector(control.get_meta("sc_rect_scale") * scale)
    
    for child in control.get_children():
        if child is Control:
            scale_gui_recursively(child)


func _record_gui_original_simple_dimensions(control: Control) -> void:
    if control is VBoxContainer or \
            control is HBoxContainer:
        if !control.has_meta("sc_separation"):
            control.set_meta(
                    "sc_separation",
                    control.get_constant("separation"))
    if control is MarginContainer:
        if !control.has_meta("sc_margin_right"):
            control.set_meta(
                    "sc_margin_right",
                    control.get_constant("margin_right"))
        if !control.has_meta("sc_margin_top"):
            control.set_meta(
                    "sc_margin_top",
                    control.get_constant("margin_top"))
        if !control.has_meta("sc_margin_left"):
            control.set_meta(
                    "sc_margin_left",
                    control.get_constant("margin_left"))
        if !control.has_meta("sc_margin_bottom"):
            control.set_meta(
                    "sc_margin_bottom",
                    control.get_constant("margin_bottom"))


func record_gui_original_size_recursively(control: Control) -> void:
    if control.rect_min_size != Vector2.ZERO:
        control.set_meta(
                "sc_rect_min_size",
                control.rect_min_size)
    if control.rect_size != Vector2.ZERO:
        control.set_meta(
                "sc_rect_size",
                control.rect_size)
    
    for child in control.get_children():
        if child is Control and \
                !child.has_method("_on_gui_scale_changed"):
            record_gui_original_size_recursively(child)


func get_scaled_texture(
        original_texture: Texture,
        scale: float) -> Texture:
    if !original_texture_to_size_to_scaled_texture.has(original_texture):
        original_texture_to_size_to_scaled_texture[original_texture] = {}
    var size_to_scaled_texture: Dictionary = \
            original_texture_to_size_to_scaled_texture[original_texture]
    
    var original_image: Image = original_texture.get_data()
    var new_size: Vector2 = \
            Sc.utils.floor_vector(original_image.get_size() * scale)
    
    if !size_to_scaled_texture.has(new_size):
        var new_image: Image = original_texture.duplicate().get_data()
        new_image.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)
        var new_texture := ImageTexture.new()
        new_texture.create_from_image(new_image)
        
        size_to_scaled_texture[new_size] = new_texture
    
    return size_to_scaled_texture[new_size]

tool
class_name ScaffolderHud
extends Node2D


signal radial_menu_opened()
signal radial_menu_closed()

const _HUD_FADE_DURATION := 0.35
const _HUD_FADE_OUT_OPACITY := 0.4

const _REGION_FADE_DURATION := 0.25
const _REGION_FADE_OUT_OPACITY := 0.25

var radial_menu_class: Script
var radial_menu_label_scene: PackedScene
var radial_menu_item_hovered_scale: float
var radial_menu_radius: float
var radial_menu_item_radius: float
var radial_menu_open_duration: float
var radial_menu_close_duration: float
var radial_menu_item_hover_duration: float
var radial_menu_closed_item_angular_offset: float
var radial_menu_item_normal_color_modulate: ColorConfig
var radial_menu_item_hover_color_modulate: ColorConfig
var radial_menu_item_disabled_color_modulate: ColorConfig

var is_key_value_list_consolidated: bool

var fadable_container: Node2D

var hud_key_value_list: HudKeyValueList

var _previous_radial_menu: RadialMenu
var _radial_menu: RadialMenu

# Dictionary<CanvasItem, ScaffolderTween>
var _fade_tweens := {}

var _is_faded_out := false


func _ready() -> void:
    assert(Sc.gui.hud_manifest.has("hud_key_value_box_size"))
    assert(Sc.gui.hud_manifest.has("hud_key_value_list_item_manifest"))
    assert(Sc.gui.hud_manifest.has("hud_key_value_box_scene"))
    assert(Sc.gui.hud_manifest.has("hud_custom_value_box_scene"))
    assert(Sc.gui.hud_manifest.has("hud_key_value_list_scene"))
    
    self.radial_menu_class = \
            Sc.gui.hud_manifest.radial_menu_class
    self.radial_menu_label_scene = \
            Sc.gui.hud_manifest.radial_menu_label_scene
    self.radial_menu_item_hovered_scale = \
            Sc.gui.hud_manifest.radial_menu_item_hovered_scale
    self.radial_menu_radius = \
            Sc.gui.hud_manifest.radial_menu_radius
    self.radial_menu_item_radius = \
            Sc.gui.hud_manifest.radial_menu_item_radius
    self.radial_menu_open_duration = \
            Sc.gui.hud_manifest.radial_menu_open_duration
    self.radial_menu_close_duration = \
            Sc.gui.hud_manifest.radial_menu_close_duration
    self.radial_menu_item_hover_duration = \
            Sc.gui.hud_manifest.radial_menu_item_hover_duration
    self.radial_menu_closed_item_angular_offset = \
            Sc.gui.hud_manifest.radial_menu_closed_item_angular_offset
    self.radial_menu_item_normal_color_modulate = \
            Sc.gui.hud_manifest.radial_menu_item_normal_color_modulate
    self.radial_menu_item_hover_color_modulate = \
            Sc.gui.hud_manifest.radial_menu_item_hover_color_modulate
    self.radial_menu_item_disabled_color_modulate = \
            Sc.gui.hud_manifest.radial_menu_item_disabled_color_modulate
    
    self.is_key_value_list_consolidated = \
            Sc.gui.hud_manifest.is_key_value_list_consolidated
    
    var is_hud_key_value_list_shown: bool = false
    for item_config in Sc.gui.hud_manifest.hud_key_value_list_item_manifest:
        if item_config.enabled:
            is_hud_key_value_list_shown = true
            break
    
    fadable_container = Node2D.new()
    add_child(fadable_container)
    
    if is_hud_key_value_list_shown:
        hud_key_value_list = Sc.utils.add_scene(
                fadable_container,
                Sc.gui.hud_manifest.hud_key_value_list_scene,
                true,
                true)
        _set_up_fade_tween_for_region_mouse_over(hud_key_value_list)
    
    _fade_tweens[fadable_container] = ScaffolderTween.new(self)


func open_radial_menu(
        radial_menu_class: Script,
        items: Array,
        position: Vector2,
        metadata = null) -> RadialMenu:
    if is_instance_valid(_previous_radial_menu):
        _previous_radial_menu._destroy()
        _previous_radial_menu = null
    if is_instance_valid(_radial_menu):
        _radial_menu.close()
        _previous_radial_menu = _radial_menu
        
    _radial_menu = radial_menu_class.new()
    _radial_menu.metadata = metadata
    _radial_menu.set_items(items)
    _radial_menu.connect("closed", self, "_on_radial_menu_closed")
    add_child(_radial_menu)
    _radial_menu.open(position)
    
    Sc.slow_motion.time_scale = Sc.slow_motion.gui_mode_time_scale
    Sc.slow_motion.set_slow_motion_enabled(true)
    
    emit_signal("radial_menu_opened")
    
    return _radial_menu


func close_radial_menu() -> void:
    if is_instance_valid(_radial_menu):
        _radial_menu.close()
        _previous_radial_menu = _radial_menu


func _on_radial_menu_closed() -> void:
    Sc.slow_motion.set_slow_motion_enabled(false)
    Sc.slow_motion.time_scale = Sc.slow_motion.default_time_scale
    emit_signal("radial_menu_closed")


func get_is_radial_menu_open() -> bool:
    return is_instance_valid(_radial_menu) and \
            !_radial_menu._destroyed


func _set_up_fade_tween_for_region_mouse_over(region: Control) -> void:
    _fade_tweens[region] = ScaffolderTween.new(region)
    region.connect(
            "mouse_entered", self, "_on_touch_entered_region", [region])
    region.connect(
            "mouse_exited", self, "_on_touch_exited_region", [region])


func _on_touch_entered_region(region: Control) -> void:
    _trigger_fade_transition(
        region,
        _REGION_FADE_OUT_OPACITY,
        _REGION_FADE_DURATION)


func _on_touch_exited_region(region: Control) -> void:
    _trigger_fade_transition(
        region,
        1.0,
        _REGION_FADE_DURATION)


func _trigger_fade_transition(
        region: CanvasItem,
        end_opacity: float,
        duration: float) -> void:
    var tween: ScaffolderTween = _fade_tweens[region]
    tween.stop_all()
    tween.interpolate_property(
        region,
        "modulate:a",
        region.modulate.a,
        end_opacity,
        duration)
    tween.start()


func fade(fading_out: bool) -> void:
    if fading_out == _is_faded_out:
        # No change.
        return
    _is_faded_out = fading_out
    var end_opacity := \
            _HUD_FADE_OUT_OPACITY if \
            fading_out else \
            1.0
    _trigger_fade_transition(fadable_container, end_opacity, _HUD_FADE_DURATION)


func _destroy() -> void:
    if is_instance_valid(hud_key_value_list):
        hud_key_value_list._destroy()
    if is_instance_valid(_previous_radial_menu):
        _previous_radial_menu._destroy()
    if is_instance_valid(_radial_menu):
        _radial_menu._destroy()
    if !is_queued_for_deletion():
        queue_free()

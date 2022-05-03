tool
class_name ScaffolderHud
extends Node2D


signal radial_menu_opened()
signal radial_menu_closed()

var radial_menu_class: Script
var radial_menu_item_hovered_scale: float
var radial_menu_radius: float
var radial_menu_item_radius: float
var radial_menu_open_duration: float
var radial_menu_close_duration: float
var radial_menu_item_hover_duration: float
var radial_menu_closed_item_angular_offset: float
var radial_menu_item_hover_outline_color: ColorConfig

var hud_key_value_list: HudKeyValueList

var _previous_radial_menu: RadialMenu
var _radial_menu: RadialMenu


func _ready() -> void:
    assert(Sc.gui.hud_manifest.has("hud_key_value_box_size"))
    assert(Sc.gui.hud_manifest.has("hud_key_value_list_item_manifest"))
    assert(Sc.gui.hud_manifest.has("hud_key_value_box_scene"))
    assert(Sc.gui.hud_manifest.has("hud_key_value_list_scene"))
    
    self.radial_menu_class = \
            Sc.gui.hud_manifest.radial_menu_class
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
    self.radial_menu_item_hover_outline_color = \
            Sc.gui.hud_manifest.radial_menu_item_hover_outline_color
    
    var is_hud_key_value_list_shown: bool = false
    for item_config in Sc.gui.hud_manifest.hud_key_value_list_item_manifest:
        if item_config.enabled:
            is_hud_key_value_list_shown = true
            break
    
    if is_hud_key_value_list_shown:
        hud_key_value_list = Sc.utils.add_scene(
                self,
                Sc.gui.hud_manifest.hud_key_value_list_scene,
                true,
                true)


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


func clase_radial_menu() -> void:
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


func _destroy() -> void:
    if is_instance_valid(hud_key_value_list):
        hud_key_value_list._destroy()
    if is_instance_valid(_previous_radial_menu):
        _previous_radial_menu._destroy()
    if is_instance_valid(_radial_menu):
        _radial_menu._destroy()
    if !is_queued_for_deletion():
        queue_free()

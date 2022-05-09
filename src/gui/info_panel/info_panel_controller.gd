tool
class_name InfoPanelController
extends Node


signal opened(data)
signal closed(data)

var fade_in_duration := 0.15
var fade_out_duration := 0.3

var opacity := 0.9

var slide_in_distance := 110.0

var min_depth := 500.0

var content_margin := 12.0
var past_screen_edge_overhang := 4.0

var _active_panel: Control
var _next_panel: Control


func _parse_manifest(manifest: Dictionary) -> void:
    if manifest.has("fade_in_duration"):
        self.fade_in_duration = manifest.fade_in_duration
    if manifest.has("fade_out_duration"):
        self.fade_out_duration = manifest.fade_out_duration
    
    if manifest.has("opacity"):
        self.opacity = manifest.opacity
    
    if manifest.has("slide_in_distance"):
        self.slide_in_distance = manifest.slide_in_distance
    
    if manifest.has("min_depth"):
        self.min_depth = manifest.min_depth
    
    if manifest.has("content_margin"):
        self.content_margin = manifest.content_margin
    if manifest.has("past_screen_edge_overhang"):
        self.past_screen_edge_overhang = manifest.past_screen_edge_overhang


func show_panel(data: InfoPanelData) -> void:
    var container: CanvasLayer = Sc.canvas_layers.layers["in_game_dialog"]
    var panel: Control = Sc.gui.info_panel_scene.instance()
    container.add_child(panel)
    container.move_child(panel, 0)
    panel.connect("fade_out_started", self, "_on_fade_out_started", [panel])
    panel.connect("faded_out", self, "_on_faded_out", [panel])
    panel.set_up(data)
    if is_instance_valid(_active_panel):
        _next_panel = panel
        _active_panel.close()
    else:
        _active_panel = panel
        _active_panel.open()


func close_panel() -> void:
    if is_instance_valid(_active_panel):
        _active_panel.close()


func get_is_open() -> bool:
    if is_instance_valid(_active_panel):
        return _active_panel.is_open
    else:
        return false


func get_current_data() -> InfoPanelData:
    if is_instance_valid(_active_panel):
        return _active_panel._data
    else:
        return null


func get_is_transitioning() -> bool:
    if is_instance_valid(_active_panel):
        return _active_panel.get_is_transitioning()
    else:
        return false


func _on_fade_out_started(panel: Control) -> void:
    pass


func _on_faded_out(panel: Control) -> void:
    panel._destroy()
    if panel == _active_panel and \
            is_instance_valid(_next_panel):
        _active_panel = _next_panel
        _next_panel = null
        _active_panel.open()

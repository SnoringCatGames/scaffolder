tool
class_name ScaffolderCameraManifest
extends Node


signal manually_zoomed
signal manually_panned

signal zoomed
signal panned

var default_camera_class: Script = StaticCamera
var snaps_camera_back_to_character := true

var smoothing_speed: float
var gui_camera_zoom_factor := 1.0

var manual_zoom_key_step_ratio := 1.08
var manual_pan_key_step_distance := 8.0
var zoom_transition_duration := 0.3
var offset_transition_duration := 0.8

var camera_min_zoom := 0.01
var camera_max_zoom := 1.0
var camera_also_limits_max_zoom_to_level_bounds := true
var camera_zoom_speed_multiplier := 1.08

var swipe_pan_speed_multiplier := 1.5
var swipe_pinch_zoom_speed_multiplier := 1.0
var swipe_max_pan_speed := 1000.0
var swipe_pan_continuation_deceleration := -6000.0
var swipe_zoom_continuation_deceleration := -6000.0
var swipe_pan_continuation_min_speed := 0.2
var swipe_zoom_continuation_min_speed := 0.001

var manual_zoom := 1.0 setget _set_manual_zoom
var manual_offset := Vector2.ZERO setget _set_manual_offset


func _destroy() -> void:
    pass


func _parse_manifest(manifest: Dictionary) -> void:
    if manifest.has("default_camera_class"):
        self.default_camera_class = manifest.default_camera_class
    if manifest.has("snaps_camera_back_to_character"):
        self.snaps_camera_back_to_character = \
                manifest.snaps_camera_back_to_character
    
    if manifest.has("smoothing_speed"):
        self.smoothing_speed = manifest.smoothing_speed
    if manifest.has("gui_camera_zoom_factor"):
        self.gui_camera_zoom_factor = manifest.gui_camera_zoom_factor
    
    if manifest.has("manual_zoom_key_step_ratio"):
        self.manual_zoom_key_step_ratio = \
                manifest.manual_zoom_key_step_ratio
    if manifest.has("manual_pan_key_step_distance"):
        self.manual_pan_key_step_distance = \
                manifest.manual_pan_key_step_distance
    if manifest.has("zoom_transition_duration"):
        self.zoom_transition_duration = \
                manifest.zoom_transition_duration
    if manifest.has("offset_transition_duration"):
        self.offset_transition_duration = \
                manifest.offset_transition_duration
    
    if manifest.has("camera_min_zoom"):
        self.camera_min_zoom = \
                manifest.camera_min_zoom
    if manifest.has("camera_max_zoom"):
        self.camera_max_zoom = \
                manifest.camera_max_zoom
    if manifest.has("camera_also_limits_max_zoom_to_level_bounds"):
        self.camera_also_limits_max_zoom_to_level_bounds = \
                manifest.camera_also_limits_max_zoom_to_level_bounds
    if manifest.has("camera_zoom_speed_multiplier"):
        self.camera_zoom_speed_multiplier = \
                manifest.camera_zoom_speed_multiplier
    
    if manifest.has("swipe_pan_speed_multiplier"):
        self.swipe_pan_speed_multiplier = \
                manifest.swipe_pan_speed_multiplier
    if manifest.has("swipe_pinch_zoom_speed_multiplier"):
        self.swipe_pinch_zoom_speed_multiplier = \
                manifest.swipe_pinch_zoom_speed_multiplier
    if manifest.has("swipe_max_pan_speed"):
        self.swipe_max_pan_speed = \
                manifest.swipe_max_pan_speed
    if manifest.has("swipe_pan_continuation_deceleration"):
        self.swipe_pan_continuation_deceleration = \
                manifest.swipe_pan_continuation_deceleration
    if manifest.has("swipe_zoom_continuation_deceleration"):
        self.swipe_zoom_continuation_deceleration = \
                manifest.swipe_zoom_continuation_deceleration
    if manifest.has("swipe_pan_continuation_min_speed"):
        self.swipe_pan_continuation_min_speed = \
                manifest.swipe_pan_continuation_min_speed
    if manifest.has("swipe_zoom_continuation_min_speed"):
        self.swipe_zoom_continuation_min_speed = \
                manifest.swipe_zoom_continuation_min_speed


func _set_manual_zoom(value: float) -> void:
    var previous_manual_zoom := manual_zoom
    manual_zoom = value
    _update_active_camera()
    if manual_zoom != previous_manual_zoom:
        emit_signal("manually_zoomed")
        emit_signal("zoomed")


func _set_manual_offset(value: Vector2) -> void:
    var previous_manual_offset := manual_offset
    manual_offset = value
    _update_active_camera()
    if manual_offset != previous_manual_offset:
        emit_signal("manually_panned")
        emit_signal("panned")


func _update_active_camera() -> void:
    if is_instance_valid(Sc.level) and is_instance_valid(Sc.level.camera):
        Sc.level.camera._update_offset_and_zoom()

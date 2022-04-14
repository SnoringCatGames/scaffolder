tool
class_name ScaffolderCameraManifest
extends Node


var controller: CameraController

var default_camera_pan_controller_class: Script
var snaps_camera_back_to_character := true

var manual_zoom_key_step_ratio := 1.08
var manual_pan_key_step_distance := 8.0
var zoom_transition_duration := 0.3
var offset_transition_duration := 0.8

var pan_controller_min_zoom := 0.01
var pan_controller_max_zoom := 1.0
var pan_controller_also_limits_max_zoom_to_level_bounds := true
var pan_controller_zoom_speed_multiplier := 1.08

var swipe_pan_speed_multiplier := 1.5
var swipe_pinch_zoom_speed_multiplier := 1.0
var swipe_max_pan_speed := 1000.0
var swipe_pan_continuation_deceleration := -6000.0
var swipe_zoom_continuation_deceleration := -6000.0
var swipe_pan_continuation_min_speed := 0.2
var swipe_zoom_continuation_min_speed := 0.001


func _destroy() -> void:
    if is_instance_valid(controller):
        controller.queue_free()


func _parse_manifest(manifest: Dictionary) -> void:
    if manifest.has("default_camera_pan_controller_class"):
        self.default_camera_pan_controller_class = \
                manifest.default_camera_pan_controller_class
    if manifest.has("snaps_camera_back_to_character"):
        self.snaps_camera_back_to_character = \
                manifest.snaps_camera_back_to_character
    
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
    
    if manifest.has("pan_controller_min_zoom"):
        self.pan_controller_min_zoom = \
                manifest.pan_controller_min_zoom
    if manifest.has("pan_controller_max_zoom"):
        self.pan_controller_max_zoom = \
                manifest.pan_controller_max_zoom
    if manifest.has("pan_controller_also_limits_max_zoom_to_level_bounds"):
        self.pan_controller_also_limits_max_zoom_to_level_bounds = \
                manifest.pan_controller_also_limits_max_zoom_to_level_bounds
    if manifest.has("pan_controller_zoom_speed_multiplier"):
        self.pan_controller_zoom_speed_multiplier = \
                manifest.pan_controller_zoom_speed_multiplier
    
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
    
    if manifest.has("camera_controller_class"):
        self.controller = manifest.camera_controller_class.new()
        assert(self.controller is CameraController)
    else:
        self.controller = CameraController.new()
    add_child(self.controller)

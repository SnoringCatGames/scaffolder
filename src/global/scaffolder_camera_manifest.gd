tool
class_name ScaffolderCameraManifest
extends Node


var controller: CameraController

var default_camera_pan_controller_class: Script
var snaps_camera_back_to_character := true


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
    
    if manifest.has("camera_controller_class"):
        self.controller = manifest.camera_controller_class.new()
        assert(self.controller is CameraController)
    else:
        self.controller = CameraController.new()
    add_child(self.controller)

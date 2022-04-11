tool
class_name ScaffolderCameraManifest
extends Node


var default_camera_pan_controller_class: Script
var snaps_camera_back_to_character := true


func _parse_manifest(manifest: Dictionary) -> void:
    if manifest.has("default_camera_pan_controller_class"):
        self.default_camera_pan_controller_class = \
                manifest.default_camera_pan_controller_class
    if manifest.has("snaps_camera_back_to_character"):
        self.snaps_camera_back_to_character = \
                manifest.snaps_camera_back_to_character

tool
class_name ScaffolderBackground
extends ParallaxBackground


var current_zoom_factor := 1.0

export var image_size := Vector2(1024, 1024) setget _set_image_size


func _ready() -> void:
    Sc.camera.connect("zoomed", self, "_on_zoomed")


func _update_layers() -> void:
    var zoom_factor := \
            1.0 if scroll_ignore_camera_zoom else current_zoom_factor
    for layer in Sc.utils.get_children_by_type(self, ParallaxLayer):
        layer.motion_mirroring = image_size * 2.0 * zoom_factor
        # TODO: Fix the motion offset.
#        layer.motion_offset = ...
    for sprite in Sc.utils.get_children_by_type(self, Sprite, true):
        sprite.region_enabled = true
        sprite.region_rect.size = image_size * 2.0 * zoom_factor


func _on_zoomed() -> void:
    var next_zoom_factor := max(floor(Sc.level.camera.zoom.x / 0.5), 0.5) * 2.0
    if next_zoom_factor != current_zoom_factor:
        current_zoom_factor = next_zoom_factor
        if !scroll_ignore_camera_zoom:
            _update_layers()


func _set_image_size(value: Vector2) -> void:
    image_size = value
    _update_layers()

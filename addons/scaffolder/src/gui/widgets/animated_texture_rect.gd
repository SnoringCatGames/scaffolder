tool
class_name AnimatedTextureRect, \
"res://addons/scaffolder/assets/images/editor_icons/animated_texture_rect.png"
extends Control


export var frames: SpriteFrames setget _set_frames
export var original_frame_size := Vector2.ZERO setget _set_original_frame_size
export var texture_scale := 1.0 setget _set_texture_scale
export var speed_scale := 1.0 setget _set_speed_scale
export var playing := true setget _set_playing
export var offset := Vector2.ZERO setget _set_offset
export var flip_h := false setget _set_flip_h
export var flip_v := false setget _set_flip_v
export var frame: int setget _set_frame,_get_frame

var _is_ready := false

var _configuration_warning := ""


func _ready() -> void:
    _is_ready = true
    _update()


func _on_gui_scale_changed() -> bool:
    _update()
    return true


func _update() -> void:
    if !_is_ready:
        return
    
    if !is_instance_valid(frames):
        _configuration_warning = "A SpriteFrames property must be defined"
        update_configuration_warning()
        return
    else:
        _configuration_warning = ""
        update_configuration_warning()
    
    $AnimatedSprite.frames = frames
    $AnimatedSprite.scale = Vector2.ONE * texture_scale * Sc.gui.scale
    $AnimatedSprite.speed_scale = speed_scale
    $AnimatedSprite.playing = playing
    $AnimatedSprite.offset = offset
    $AnimatedSprite.flip_h = flip_h
    $AnimatedSprite.flip_v = flip_v
    
    var size: Vector2 = original_frame_size * texture_scale * Sc.gui.scale
    rect_min_size = size
    rect_size = size


func _set_frames(value: SpriteFrames) -> void:
    frames = value
    _update()


func _set_original_frame_size(value: Vector2) -> void:
    original_frame_size = value
    _update()


func _set_texture_scale(value: float) -> void:
    texture_scale = value
    _update()


func _set_speed_scale(value: float) -> void:
    speed_scale = value
    _update()


func _set_playing(value: bool) -> void:
    playing = value
    _update()


func _set_offset(value: Vector2) -> void:
    offset = value
    _update()


func _set_flip_h(value: bool) -> void:
    flip_h = value
    _update()


func _set_flip_v(value: bool) -> void:
    flip_v = value
    _update()


func _set_frame(value: int) -> void:
    $AnimatedSprite.frame = value


func _get_frame() -> int:
    return $AnimatedSprite.frame


func _get_configuration_warning() -> String:
    return _configuration_warning

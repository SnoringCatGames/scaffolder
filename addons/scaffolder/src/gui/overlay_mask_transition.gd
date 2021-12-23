class_name OverlayMaskTransition
extends Node


signal completed(transition)

var SHADER := preload( \
        "res://addons/scaffolder/src/gui/overlay_mask_transition.shader")

var _tween_id: int
var is_transitioning := false

var duration := INF

var fade_in_texture: Texture setget _set_fade_in_texture
var fade_out_texture: Texture setget _set_fade_out_texture
var fade_in_easing := "ease_out"
var fade_out_easing := "ease_in"
var color := Color.black setget _set_color
var pixel_snap := true setget _set_pixel_snap
var smooth_size := 0.0 setget _set_smooth_size

var color_rect: ColorRect
var material: ShaderMaterial

var transition: ScreenTransition


func _init() -> void:
    name = "OverlayMaskTransition"


func _ready() -> void:
    material = ShaderMaterial.new()
    material.shader = SHADER
    
    material.set_shader_param("smooth_size", smooth_size)
    material.set_shader_param("pixel_snap", pixel_snap)
    
    _set_cutoff(0)
    
    Sc.device.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _on_resized() -> void:
    if !is_instance_valid(fade_in_texture):
        return
    
    var viewport_size: Vector2 = Sc.device.get_viewport_size()
    var mask_size: Vector2 = fade_in_texture.get_size()
    
    var viewport_aspect := viewport_size.x / viewport_size.y
    var mask_aspect := mask_size.x / mask_size.y
    var mask_scale: Vector2
    var mask_offset: Vector2
    if viewport_aspect > mask_aspect:
        mask_scale = Vector2(1, mask_aspect / viewport_aspect)
        mask_offset = Vector2(
                0,
                (viewport_aspect - mask_aspect) / viewport_aspect / 2.0)
    else:
        mask_scale = Vector2(viewport_aspect / mask_aspect, 1)
        mask_offset = Vector2(
                (mask_aspect - viewport_aspect) / mask_aspect / 2.0,
                0)
    material.set_shader_param("mask_scale", mask_scale)
    material.set_shader_param("mask_offset", mask_offset)
    
    if is_instance_valid(color_rect):
        color_rect.rect_size = viewport_size


func start(transition: ScreenTransition) -> void:
    self.duration = transition.duration
    self.transition = transition
    is_transitioning = true
    color_rect = ColorRect.new()
    color_rect.rect_size = Sc.device.get_viewport_size()
    color_rect.color = color
    color_rect.material = material
    Sc.canvas_layers.layers.top.add_child(color_rect)
    _fade_out()


func _fade_out() -> void:
    Sc.time.clear_tween(_tween_id)
    _set_mask(fade_out_texture)
    _tween_id = Sc.time.tween_method(
            self,
            "_set_cutoff",
            1.0,
            0.0,
            duration / 2.0,
            fade_out_easing,
            0.0,
            TimeType.APP_PHYSICS,
            funcref(self, "_fade_in"))


func _fade_in() -> void:
    Sc.time.clear_tween(_tween_id)
    _set_mask(fade_in_texture)
    _tween_id = Sc.time.tween_method(
            self,
            "_set_cutoff",
            0.0,
            1.0,
            duration / 2.0,
            fade_in_easing,
            0.0,
            TimeType.APP_PHYSICS,
            funcref(self, "_on_tween_complete"))


func _set_mask(value: Texture) -> void:
    material.set_shader_param("mask", value)
    material.set_shader_param("mask_size", value.get_size())


func _set_cutoff(value: float) -> void:
    material.set_shader_param("cutoff", value)


func stop(triggers_completed := false) -> bool:
    if !is_transitioning:
        return false
    Sc.time.clear_tween(_tween_id)
    is_transitioning = false
    if is_instance_valid(color_rect):
        color_rect.queue_free()
        color_rect = null
    if triggers_completed:
        emit_signal("completed", transition)
    return true


func _on_tween_complete() -> void:
    is_transitioning = false
    if is_instance_valid(color_rect):
        color_rect.queue_free()
        color_rect = null
    emit_signal("completed", transition)


func _set_fade_in_texture(value: Texture) -> void:
    fade_in_texture = value
    if is_instance_valid(material):
        _on_resized()


func _set_fade_out_texture(value: Texture) -> void:
    fade_out_texture = value


func _set_color(value: Color) -> void:
    color = value
    if is_instance_valid(color_rect):
        color_rect.color = color


func _set_pixel_snap(value: bool) -> void:
    pixel_snap = value
    if is_instance_valid(material):
        material.set_shader_param("pixel_snap", pixel_snap)


func _set_smooth_size(value: float) -> void:
    smooth_size = value
    if is_instance_valid(material):
        material.set_shader_param("smooth_size", smooth_size)

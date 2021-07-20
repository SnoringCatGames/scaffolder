class_name ScreenMaskTransition
extends Node


signal completed(transition)

var SHADER := \
        preload("res://addons/scaffolder/src/gui/screen_mask_transition.shader")

var _tween_id: int
var is_transitioning := false

var texture: Texture setget _set_texture
var easing := "ease_in"
var pixel_snap := true setget _set_pixel_snap
var smooth_size := 0.0 setget _set_smooth_size

var sprite: Sprite
var material: ShaderMaterial
var mask_texture: ImageTexture

var active_screen_container: ScreenContainer
var transition: ScreenTransition


func _init() -> void:
    name = "ScreenMaskTransition"


func _ready() -> void:
    material = ShaderMaterial.new()
    material.shader = SHADER
    
    material.set_shader_param("smooth_size", smooth_size)
    material.set_shader_param("pixel_snap", pixel_snap)
    if is_instance_valid(mask_texture):
        material.set_shader_param("mask", mask_texture)
        material.set_shader_param("mask_size", mask_texture.get_size())
    
    _set_cutoff(0)
    
    Sc.device.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _on_resized() -> void:
    if !is_instance_valid(mask_texture):
        return
    
    var viewport_size: Vector2 = Sc.device.get_viewport_size()
    var mask_size := mask_texture.get_size()
    
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
    
    if is_instance_valid(sprite):
        sprite.scale = viewport_size / mask_size


func start(
        active_screen_container: ScreenContainer,
        is_fading_in: bool,
        transition: ScreenTransition) -> void:
    self.active_screen_container = active_screen_container
    self.transition = transition
    
    is_transitioning = true
    
    var screenshot_image := get_viewport().get_texture().get_data()
    var screenshot_texture := ImageTexture.new()
    screenshot_texture.create_from_image(screenshot_image)
    sprite = Sprite.new()
    sprite.texture = screenshot_texture
    sprite.material = material
    sprite.centered = false
    sprite.flip_v = true
    sprite.scale = Sc.device.get_viewport_size() / sprite.texture.get_size()
    Sc.canvas_layers.layers.top.add_child(sprite)
    
    # Fading-in isn't currently supported (we would need to get a screenshot of
    # the new screen that has yet to be shown).
    assert(!is_fading_in)
    var start_cutoff := 0.0
    var end_cutoff := 1.0
    
    Sc.time.clear_tween(_tween_id)
    
    _tween_id = Sc.time.tween_method(
            self,
            "_set_cutoff",
            start_cutoff,
            end_cutoff,
            transition.duration,
            easing,
            0.0,
            TimeType.APP_PHYSICS,
            funcref(self, "_on_tween_complete"))


func _set_cutoff(value: float) -> void:
    material.set_shader_param(
            "cutoff",
            value)


func stop(triggers_completed := false) -> bool:
    if !is_transitioning:
        return false
    Sc.time.clear_tween(_tween_id)
    is_transitioning = false
    if is_instance_valid(sprite):
        sprite.queue_free()
        sprite = null
    if triggers_completed:
        emit_signal("completed", transition)
    return true


func _on_tween_complete() -> void:
    is_transitioning = false
    if is_instance_valid(sprite):
        sprite.queue_free()
        sprite = null
    emit_signal("completed", transition)


func _set_texture(value: Texture) -> void:
    texture = value
    
    if !is_instance_valid(texture):
        return
    
    var flipped_image: Image = texture.get_data()
    flipped_image.flip_y()
    mask_texture = ImageTexture.new()
    mask_texture.create_from_image(flipped_image)
    
    if is_instance_valid(material):
        material.set_shader_param("mask", mask_texture)
        material.set_shader_param("mask_size", mask_texture.get_size())
        _on_resized()


func _set_pixel_snap(value: bool) -> void:
    pixel_snap = value
    if is_instance_valid(material):
        material.set_shader_param("pixel_snap", pixel_snap)


func _set_smooth_size(value: float) -> void:
    smooth_size = value
    if is_instance_valid(material):
        material.set_shader_param("smooth_size", smooth_size)

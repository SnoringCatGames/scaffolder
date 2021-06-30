tool
class_name SplashScreen
extends Screen


export var texture: Texture

var _is_ready := false
var _scaffolder_texture_rect: ScaffolderTextureRect


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    _is_ready = true
    
    _scaffolder_texture_rect = Gs.utils.add_scene(
            self, Gs.gui.SCAFFOLDER_TEXTURE_RECT_SCENE, true, true)
    _on_resized()


func _on_resized() -> void:
    ._on_resized()
    _update()


func _update() -> void:
    if !_is_ready:
        return
    
    var viewport_size := get_viewport().size
    var texture_size := texture.get_size()
    var scale := viewport_size / texture_size
    if scale.x > scale.y:
        scale.x = scale.y
    else:
        scale.y = scale.x
    var position := -(texture_size * scale) / 2.0
    _scaffolder_texture_rect.texture = texture
    _scaffolder_texture_rect.texture_scale = scale
    _scaffolder_texture_rect.rect_position = position


func _set_texture(value: Texture) -> void:
    texture = value
    _update()

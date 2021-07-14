tool
class_name SplashScreen
extends Screen


export var texture: Texture

var _is_ready := false
var _scaffolder_texture_rect: ScaffolderTextureRect


func _ready() -> void:
    _is_ready = true
    
    _scaffolder_texture_rect = Gs.utils.add_scene(
            self, Gs.gui.SCAFFOLDER_TEXTURE_RECT_SCENE, true, true)
    _update()


func _on_gui_scale_changed() -> bool:
    _update()
    return true

func _update() -> void:
    if !_is_ready:
        return
    
    var scale: Vector2 = \
            get_viewport().size / texture.get_size() / Gs.gui.scale
    if scale.x > scale.y:
        scale.x = scale.y
    else:
        scale.y = scale.x
    
    _scaffolder_texture_rect.texture = texture
    _scaffolder_texture_rect.texture_scale = scale * Gs.gui.splash_scale


func _set_texture(value: Texture) -> void:
    texture = value
    _update()

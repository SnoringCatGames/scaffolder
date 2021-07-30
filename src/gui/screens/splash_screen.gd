tool
class_name SplashScreen
extends Screen


export var texture_key: String setget _set_texture_key

var _is_ready := false
var _scaffolder_texture_rect: ScaffolderTextureRect


func _ready() -> void:
    _is_ready = true
    
    _scaffolder_texture_rect = Sc.utils.add_scene(
            self, Sc.gui.SCAFFOLDER_TEXTURE_RECT_SCENE, true, true)
    _update()


func _on_gui_scale_changed() -> bool:
    _update()
    return true

func _update() -> void:
    if !_is_ready:
        return
    
    var texture: Texture = Sc.images.get(texture_key)
    var scale: Vector2 = \
            Sc.device.get_viewport_size() / texture.get_size() / Sc.gui.scale
    if scale.x > scale.y:
        scale.x = scale.y
    else:
        scale.y = scale.x
    
    _scaffolder_texture_rect.texture_key = texture_key
    _scaffolder_texture_rect.texture_scale = scale * Sc.gui.splash_scale


func _set_texture_key(value: String) -> void:
    texture_key = value
    assert(Sc.images.get(texture_key) is Texture)
    _update()

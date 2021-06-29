tool
class_name DeveloperSplashScreen
extends Screen


const SPLASH_IMAGE_SIZE_DEFAULT := Vector2(900, 835)


func _enter_tree() -> void:
    if Engine.editor_hint:
        var viewport_size := Vector2(1024, 768)
        var scale := viewport_size / SPLASH_IMAGE_SIZE_DEFAULT
        if scale.x > scale.y:
            scale.x = scale.y
        else:
            scale.y = scale.x
        var position := -SPLASH_IMAGE_SIZE_DEFAULT / 2
        $ScaffolderTextureRect.rect_scale = scale
        $ScaffolderTextureRect.rect_position = position
    else:
        _on_resized()
    $ScaffolderTextureRect.texture = Gs.app_metadata.developer_splash


func _on_resized() -> void:
    ._on_resized()
    var viewport_size := get_viewport().size
    var scale := viewport_size / SPLASH_IMAGE_SIZE_DEFAULT
    if scale.x > scale.y:
        scale.x = scale.y
    else:
        scale.y = scale.x
    var position := -(SPLASH_IMAGE_SIZE_DEFAULT * scale) / 2
    $ScaffolderTextureRect.rect_scale = scale
    $ScaffolderTextureRect.rect_position = position

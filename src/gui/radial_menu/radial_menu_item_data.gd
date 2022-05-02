class_name RadialMenuItemData
extends Reference


var texture: Texture
## -   Optional
## -   If omitted, then ShaderOutlineableSprite will be used instead.
var outlined_texture: Texture

var id = ""
var description := ""

var is_visible := true
var is_disabled := false

var _hover_progress := 0.0

var _menu
var _index: int
var _angle: float
var _control: ShapedLevelControl
var _sprite: OutlineableSprite
var _tween: ScaffolderTween


func _create_outlineable_sprite() -> OutlineableSprite:
    var sprite: OutlineableSprite
    if is_instance_valid(outlined_texture):
        sprite = TextureOutlineableSprite.new()
        sprite.normal_texture = texture
        sprite.outlined_texture = outlined_texture
    else:
        sprite = ShaderOutlineableSprite.new()
        sprite.texture = texture
    return sprite


func _interpolate_item_hover(progress: float) -> void:
    _menu._interpolate_item_hover(self, progress)

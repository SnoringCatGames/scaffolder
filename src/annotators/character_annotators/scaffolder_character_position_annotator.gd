class_name ScaffolderCharacterPositionAnnotator
extends Node2D


var CHARACTER_POSITION_COLOR: Color = Sc.colors.opacify(
        Sc.colors.character_position, ScaffolderColors.ALPHA_XXFAINT)
const CHARACTER_POSITION_RADIUS := 3.0

var COLLIDER_COLOR: Color = Sc.colors.opacify(
        Sc.colors.character_position, ScaffolderColors.ALPHA_XFAINT)
const COLLIDER_THICKNESS := 4.0

var character: ScaffolderCharacter
var previous_position: Vector2


func _init(character: ScaffolderCharacter) -> void:
    self.character = character


func _draw() -> void:
    _draw_character_position()
    _draw_collider_outline()


func _draw_character_position() -> void:
    draw_circle(
            character.position,
            CHARACTER_POSITION_RADIUS,
            CHARACTER_POSITION_COLOR)


func _draw_collider_outline() -> void:
    Sc.draw.draw_shape_outline(
            self,
            character.position,
            character.movement_params.collider_shape,
            character.movement_params.collider_rotation,
            COLLIDER_COLOR,
            COLLIDER_THICKNESS)


func check_for_update() -> void:
    if character.did_move_last_frame:
        previous_position = character.position
        update()

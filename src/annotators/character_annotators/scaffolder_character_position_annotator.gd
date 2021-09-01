class_name ScaffolderCharacterPositionAnnotator
extends Node2D


const POSITION_OPACITY := ScaffolderColors.ALPHA_XFAINT
const POSITION_RADIUS := 3.0

const COLLIDER_OPACITY := ScaffolderColors.ALPHA_FAINT
const COLLIDER_THICKNESS := 4.0

var character: ScaffolderCharacter
var previous_position: Vector2

var position_color: Color
var collider_color: Color


func _init(character: ScaffolderCharacter) -> void:
    self.character = character
    
    self.position_color = Color.from_hsv(
            character.position_annotation_color.h,
            0.7,
            0.9,
            POSITION_OPACITY)
    self.collider_color = Color.from_hsv(
            character.position_annotation_color.h,
            0.7,
            0.9,
            COLLIDER_OPACITY)


func _draw() -> void:
    _draw_character_position()
    _draw_collider_outline()


func _draw_character_position() -> void:
    draw_circle(
            character.position,
            POSITION_RADIUS,
            position_color)


func _draw_collider_outline() -> void:
    Sc.draw.draw_shape_outline(
            self,
            character.position,
            character.movement_params.collider_shape,
            character.movement_params.collider_rotation,
            collider_color,
            COLLIDER_THICKNESS)


func check_for_update() -> void:
    if character.did_move_last_frame:
        previous_position = character.position
        update()

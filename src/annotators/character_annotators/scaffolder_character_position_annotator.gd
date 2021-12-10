class_name ScaffolderCharacterPositionAnnotator
extends Node2D


var character: ScaffolderCharacter

var position_color: Color
var collider_color: Color


func _init(character: ScaffolderCharacter) -> void:
    self.character = character
    
    self.position_color = Color.from_hsv(
            character.position_annotation_color.h,
            0.7,
            0.9,
            Sc.ann_params.character_position_opacity)
    self.collider_color = Color.from_hsv(
            character.position_annotation_color.h,
            0.7,
            0.9,
            Sc.ann_params.character_collider_opacity)


func _draw() -> void:
    _draw_character_position()
    _draw_collider_outline()


func _draw_character_position() -> void:
    draw_circle(
            character.position,
            Sc.ann_params.character_position_radius,
            position_color)


func _draw_collider_outline() -> void:
    Sc.draw.draw_shape_outline(
            self,
            character.position,
            character.collider,
            collider_color,
            Sc.ann_params.character_collider_thickness)


func check_for_update() -> void:
    if character.did_move_last_frame:
        update()

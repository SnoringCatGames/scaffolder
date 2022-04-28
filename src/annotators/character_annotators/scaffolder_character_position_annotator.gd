class_name ScaffolderCharacterPositionAnnotator
extends Node2D


var character: ScaffolderCharacter

var position_color: Color
var collider_color: Color
var pointer_screen_radius_color: Color


func _init(character: ScaffolderCharacter) -> void:
    self.character = character
    
    var position_annotation_color: Color = \
            character.position_annotation_color.sample()
    self.position_color = Color.from_hsv(
            position_annotation_color.h,
            0.7,
            0.9,
            Sc.annotators.params.character_position_opacity)
    self.collider_color = Color.from_hsv(
            position_annotation_color.h,
            0.7,
            0.9,
            Sc.annotators.params.character_collider_opacity)
    self.pointer_screen_radius_color = Color.from_hsv(
            position_annotation_color.h,
            0.2,
            0.99,
            0.8)
    
    Sc.camera.connect("zoomed", self, "update")


func _draw() -> void:
    if !is_instance_valid(Sc.level):
        return
    _draw_character_position()
    _draw_collider_outline()
    _draw_pointer_detector_screen_radius()


func _draw_character_position() -> void:
    draw_circle(
            character.position,
            Sc.annotators.params.character_position_radius,
            position_color)


func _draw_collider_outline() -> void:
    Sc.draw.draw_shape_outline(
            self,
            character.position,
            character.collider,
            collider_color,
            Sc.annotators.params.character_collider_thickness)


func _draw_pointer_detector_screen_radius() -> void:
    if !character.detects_pointer:
        return
    var zoom: float = Sc.level.camera.zoom.x
    Sc.draw.draw_dashed_circle(
            self,
            character._pointer_detector.get_center_in_level_space(),
            character._pointer_detector.get_screen_radius_in_level_space(),
            pointer_screen_radius_color,
            8.0 * zoom,
            8.0 * zoom,
            4.0 * zoom,
            8.0 * zoom)


func check_for_update() -> void:
    if character.did_move_last_frame:
        update()

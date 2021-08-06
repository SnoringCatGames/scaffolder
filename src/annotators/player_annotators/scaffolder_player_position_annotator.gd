class_name ScaffolderPlayerPositionAnnotator
extends Node2D


var PLAYER_POSITION_COLOR: Color = Sc.colors.opacify(
        Sc.colors.player_position, ScaffolderColors.ALPHA_XXFAINT)
const PLAYER_POSITION_RADIUS := 3.0

var COLLIDER_COLOR: Color = Sc.colors.opacify(
        Sc.colors.player_position, ScaffolderColors.ALPHA_XFAINT)
const COLLIDER_THICKNESS := 4.0

var player: ScaffolderPlayer
var previous_position: Vector2


func _init(player: ScaffolderPlayer) -> void:
    self.player = player


func _draw() -> void:
    _draw_player_position()
    _draw_collider_outline()


func _draw_player_position() -> void:
    draw_circle(
            player.position,
            PLAYER_POSITION_RADIUS,
            PLAYER_POSITION_COLOR)


func _draw_collider_outline() -> void:
    Sc.draw.draw_shape_outline(
            self,
            player.position,
            player.movement_params.collider_shape,
            player.movement_params.collider_rotation,
            COLLIDER_COLOR,
            COLLIDER_THICKNESS)


func check_for_update() -> void:
    if player.did_move_last_frame:
        previous_position = player.position
        update()

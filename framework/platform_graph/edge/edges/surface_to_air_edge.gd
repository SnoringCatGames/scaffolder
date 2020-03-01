# Information for how to move from a surface to a position in the air.
extends Edge
class_name SurfaceToAirEdge

const NAME := "SurfaceToAirEdge"
const IS_TIME_BASED := true
const SURFACE_TYPE := SurfaceType.AIR
const ENTERS_AIR := true

func _init(start: PositionAlongSurface, end: Vector2, movement_params: MovementParams, \
        instructions: MovementInstructions) \
        .(NAME, IS_TIME_BASED, SURFACE_TYPE, ENTERS_AIR, start, \
        Edge.vector2_to_position_along_surface(end), movement_params, instructions) -> void:
    pass

func _calculate_distance(start: PositionAlongSurface, end: PositionAlongSurface, \
        instructions: MovementInstructions) -> float:
    return Edge.sum_distance_between_frames(instructions.frame_continuous_positions_from_steps)

func _calculate_duration(start: PositionAlongSurface, end: PositionAlongSurface, \
        instructions: MovementInstructions, movement_params: MovementParams, \
        distance: float) -> float:
    return instructions.duration

func _check_did_just_reach_destination(navigation_state: PlayerNavigationState, \
        surface_state: PlayerSurfaceState, playback) -> bool:
    return playback.is_finished

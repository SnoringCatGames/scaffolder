# Information for how to walk to and off the edge of a floor.
# 
# The instructions for this edge consist of a single sideways key press, with no corresponding
# release.
extends Edge
class_name FallFromFloorEdge

const NAME := "FallFromFloorEdge"
const IS_TIME_BASED := false

func _init(start: PositionAlongSurface, end: PositionAlongSurface, \
        calc_results: MovementCalcResults).(NAME, IS_TIME_BASED, start, end, \
        _calculate_instructions(start, end, calc_results)) -> void:
    pass

func _check_did_just_reach_destination(navigation_state: PlayerNavigationState, \
        surface_state: PlayerSurfaceState, playback) -> bool:
    return surface_state.just_entered_air

static func _calculate_instructions(start: PositionAlongSurface, \
        end: PositionAlongSurface, calc_results: MovementCalcResults) -> MovementInstructions:
    assert(start.surface.side == SurfaceSide.FLOOR)
    
    return null
    
    # FIXME: LEFT OFF HERE: ------------------------------------A
    # - Figure out what to do for FallFromFloorEdge.
    #   - We need to on-the-fly detect when the player has left the floor and entered the air.
    #   - We need to at-that-point start running the instructions for the fall trajectory.
    #   - So FallFromFloorEdge might need to be replaced with two edges? WalkOffFloorEdge, and AirToSurfaceEdge?
    
    
    # FIXME: ------------
    
#    var sideways_input_key := \
#            "move_right" if start.target_point.x < end.x else "move_left"
#    var instruction := MovementInstruction.new(sideways_input_key, 0.0, true)
#    var distance := start.target_point.distance_to(end)
#    return MovementInstructions.new([instruction], INF, distance)
    
    
    # FIXME: -----------
    
#    # Calculate the fall-trajectory instructions.
#    var instructions := \
#            MovementInstructionsUtils.convert_calculation_steps_to_movement_instructions( \
#                    start.target_point, end.target_point, calc_results, false, end.surface.side)
#    
#    # Calculate the wall-release instructions.
#    var sideways_input_key := \
#            "move_right" if start.surface.side == SurfaceSide.LEFT_WALL else "move_left"
#    var outward_press := MovementInstruction.new(sideways_input_key, 0.0, true)
#    var outward_release := MovementInstruction.new(sideways_input_key, 0.001, true)
#    instructions.instructions.push_front(outward_release)
#    instructions.instructions.push_front(outward_press)
#    
#    return instructions
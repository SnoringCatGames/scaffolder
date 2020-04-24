extends Reference
class_name EdgeMovementCalculator

# This is the minimum speed that we require edge calculations to have at the end of their jump
# trajectory when landing on a wall surface.
const MIN_LAND_ON_WALL_SPEED := 50.0

# The minimum land-on-wall horizontal speed is multiplied by this value when the player is likely
# to need more speed in order to land on the wall. In particular, this is used for positions at the
# bottom of walls, where the player might otherwise fall short.
const MIN_LAND_ON_WALL_EXTRA_SPEED_RATIO := 2.0

var name: String
var is_a_jump_calculator: bool

func _init( \
        name: String, \
        is_a_jump_calculator: bool) -> void:
    self.name = name
    self.is_a_jump_calculator = is_a_jump_calculator

func get_can_traverse_from_surface(surface: Surface) -> bool:
    Utils.error("abstract EdgeMovementCalculator.get_can_traverse_from_surface is not implemented")
    return false

func get_all_inter_surface_edges_from_surface( \
        collision_params: CollisionCalcParams, \
        edges_result: Array, \
        surfaces_in_fall_range_set: Dictionary, \
        surfaces_in_jump_range_set: Dictionary, \
        origin_surface: Surface) -> void:
    Utils.error("abstract EdgeMovementCalculator.get_all_inter_surface_edges_from_surface is not implemented")

func calculate_edge( \
        collision_params: CollisionCalcParams, \
        position_start: PositionAlongSurface, \
        position_end: PositionAlongSurface, \
        velocity_start := Vector2.INF, \
        needs_extra_jump_duration := false, \
        needs_extra_wall_land_horizontal_speed := false, \
        in_debug_mode := false) -> Edge:
    Utils.error("abstract EdgeMovementCalculator.calculate_edge is not implemented")
    return null

func optimize_edge_jump_position_for_path( \
        collision_params: CollisionCalcParams, \
        path: PlatformGraphPath, \
        edge_index: int, \
        previous_velocity_end_x: float, \
        previous_edge: IntraSurfaceEdge, \
        edge: Edge, \
        in_debug_mode: bool) -> void:
    # Do nothing by default. Sub-classes implement this as needed.
    pass

func optimize_edge_land_position_for_path( \
        collision_params: CollisionCalcParams, \
        path: PlatformGraphPath, \
        edge_index: int, \
        edge: Edge, \
        next_edge: IntraSurfaceEdge, \
        in_debug_mode: bool) -> void:
    # Do nothing by default. Sub-classes implement this as needed.
    pass

static func create_movement_calc_overall_params(
        collision_params: CollisionCalcParams, \
        origin_position: PositionAlongSurface, \
        destination_position: PositionAlongSurface, \
        can_hold_jump_button: bool, \
        velocity_start: Vector2, \
        needs_extra_jump_duration: bool, \
        needs_extra_wall_land_horizontal_speed: bool, \
        returns_invalid_waypoints: bool, \
        in_debug_mode: bool) -> MovementCalcOverallParams:
    # When landing on a wall, ensure that we end with velocity moving into the wall.
    var velocity_end_min_x := INF
    var velocity_end_max_x := INF
    if destination_position.surface != null:
        var min_land_on_wall_speed := \
                MIN_LAND_ON_WALL_SPEED * MIN_LAND_ON_WALL_EXTRA_SPEED_RATIO if \
                needs_extra_wall_land_horizontal_speed else \
                MIN_LAND_ON_WALL_SPEED
        if destination_position.surface.side == SurfaceSide.LEFT_WALL:
            velocity_end_min_x = -collision_params.movement_params.max_horizontal_speed_default
            velocity_end_max_x = -min_land_on_wall_speed
        if destination_position.surface.side == SurfaceSide.RIGHT_WALL:
            velocity_end_min_x = min_land_on_wall_speed
            velocity_end_max_x = collision_params.movement_params.max_horizontal_speed_default
    
    var terminals := WaypointUtils.create_terminal_waypoints( \
            origin_position, \
            destination_position, \
            collision_params.movement_params, \
            can_hold_jump_button, \
            velocity_start, \
            velocity_end_min_x, \
            velocity_end_max_x, \
            needs_extra_jump_duration, \
            returns_invalid_waypoints)
    if terminals.empty():
        return null
    
    var overall_calc_params := MovementCalcOverallParams.new( \
            collision_params, \
            origin_position, \
            destination_position, \
            terminals[0], \
            terminals[1], \
            velocity_start, \
            needs_extra_jump_duration, \
            needs_extra_wall_land_horizontal_speed, \
            can_hold_jump_button)
    overall_calc_params.in_debug_mode = in_debug_mode
    
    return overall_calc_params

static func should_skip_edge_calculation( \
        debug_state: Dictionary, \
        jump_position_or_surface, \
        land_position_or_surface) -> bool:
    if debug_state.in_debug_mode and debug_state.has("limit_parsing") and \
            debug_state.limit_parsing.has("edge"):
        var jump_surface: Surface = \
                jump_position_or_surface.surface if \
                jump_position_or_surface is PositionAlongSurface else \
                jump_position_or_surface
        var land_surface: Surface = \
                land_position_or_surface.surface if \
                land_position_or_surface is PositionAlongSurface else \
                land_position_or_surface
        var jump_target_point: Vector2 = \
                jump_position_or_surface.target_projection_onto_surface if \
                jump_position_or_surface is PositionAlongSurface else \
                Vector2.INF
        var land_target_point: Vector2 = \
                land_position_or_surface.target_projection_onto_surface if \
                land_position_or_surface is PositionAlongSurface else \
                Vector2.INF
        
        if debug_state.limit_parsing.edge.has("origin"):
            if jump_surface == null:
                # Ignore this if we expect to know the jump position, but don't.
                return false
            
            var debug_origin: Dictionary = debug_state.limit_parsing.edge.origin
            
            if (debug_origin.has("surface_side") and \
                    debug_origin.surface_side != jump_surface.side) or \
                    (debug_origin.has("surface_start_vertex") and \
                            debug_origin.surface_start_vertex != \
                                    jump_surface.first_point) or \
                    (debug_origin.has("surface_end_vertex") and \
                            debug_origin.surface_end_vertex != jump_surface.last_point):
                # Ignore anything except the origin surface that we're debugging.
                return true
            
            if debug_origin.has("position"):
                if !Geometry.are_points_equal_with_epsilon( \
                        jump_target_point, \
                        debug_origin.position, \
                        0.1):
                    # Ignore anything except the jump position that we're debugging.
                    return true
        
        if debug_state.limit_parsing.edge.has("destination"):
            if land_surface == null:
                # Ignore this if we expect to know the land position, but don't.
                return false
            
            var debug_destination: Dictionary = debug_state.limit_parsing.edge.destination
            
            if (debug_destination.has("surface_side") and \
                    debug_destination.surface_side != land_surface.side) or \
                    (debug_destination.has("surface_start_vertex") and \
                            debug_destination.surface_start_vertex != \
                                    land_surface.first_point) or \
                    (debug_destination.has("surface_end_vertex") and \
                            debug_destination.surface_end_vertex != \
                                    land_surface.last_point):
                # Ignore anything except the destination surface that we're debugging.
                return true
            
            if debug_destination.has("position"):
                if !Geometry.are_points_equal_with_epsilon( \
                        land_target_point, \
                        debug_destination.position, \
                        0.1):
                    # Ignore anything except the land position that we're debugging.
                    return true
    
    return false

static func optimize_edge_jump_position_for_path_helper( \
        collision_params: CollisionCalcParams, \
        path: PlatformGraphPath, \
        edge_index: int, \
        previous_velocity_end_x: float, \
        previous_edge: IntraSurfaceEdge, \
        edge: Edge, \
        in_debug_mode: bool, \
        edge_movement_calculator: EdgeMovementCalculator) -> void:
    # TODO: Refactor this to use a true binary search. Right now it is similar, but we never
    #       move backward once we find a working jump.
    var jump_ratios := [0.0, 0.5, 0.75, 0.875]
    
    var movement_params := collision_params.movement_params
    
    var previous_edge_displacement := previous_edge.end - previous_edge.start
    
    var is_horizontal_surface := \
            previous_edge.start_surface != null and \
            (previous_edge.start_surface.side == SurfaceSide.FLOOR or \
            previous_edge.start_surface.side == SurfaceSide.CEILING)
    
    if is_horizontal_surface:
        # Jumping from a floor or ceiling.
        
        var is_already_exceeding_max_speed_toward_displacement := \
                (previous_edge_displacement.x >= 0.0 and previous_velocity_end_x > \
                        movement_params.max_horizontal_speed_default) or \
                (previous_edge_displacement.x <= 0.0 and previous_velocity_end_x < \
                        -movement_params.max_horizontal_speed_default)
        
        var acceleration_x := movement_params.walk_acceleration if \
                previous_edge_displacement.x >= 0.0 else \
                -movement_params.walk_acceleration
        
        var jump_position: PositionAlongSurface
        var optimized_edge: Edge
        
        for i in range(jump_ratios.size()):
            if jump_ratios[i] == 0.0:
                jump_position = previous_edge.start_position_along_surface
            else:
                jump_position = MovementUtils.create_position_offset_from_target_point( \
                        Vector2(previous_edge.start.x + \
                                previous_edge_displacement.x * jump_ratios[i], 0.0), \
                        previous_edge.start_surface, \
                        movement_params.collider_half_width_height)
            
            # Calculate the start velocity to use according to the available ramp-up
            # distance and max speed.
            var velocity_start_x: float = MovementUtils.calculate_velocity_end_for_displacement( \
                    jump_position.target_point.x - previous_edge.start.x, \
                    previous_velocity_end_x, \
                    acceleration_x, \
                    movement_params.max_horizontal_speed_default)
            var velocity_start_y := movement_params.jump_boost
            var velocity_start = Vector2(velocity_start_x, velocity_start_y)
            
            optimized_edge = edge_movement_calculator.calculate_edge( \
                    collision_params, \
                    jump_position, \
                    edge.end_position_along_surface, \
                    velocity_start, \
                    edge.includes_extra_jump_duration, \
                    edge.includes_extra_wall_land_horizontal_speed, \
                    in_debug_mode)
            
            if optimized_edge != null:
                optimized_edge.is_optimized_for_path = true
                
                previous_edge = IntraSurfaceEdge.new( \
                        previous_edge.start_position_along_surface, \
                        jump_position, \
                        Vector2(previous_velocity_end_x, 0.0), \
                        movement_params)
                
                path.edges[edge_index - 1] = previous_edge
                path.edges[edge_index] = optimized_edge
                
                return
        
    else:
        # Jumping from a wall.
        
        var jump_position: PositionAlongSurface
        var velocity_start: Vector2
        var optimized_edge: Edge
        
        for i in range(jump_ratios.size()):
            if jump_ratios[i] == 0.0:
                jump_position = previous_edge.start_position_along_surface
            else:
                jump_position = MovementUtils.create_position_offset_from_target_point( \
                        Vector2(0.0, previous_edge.start.y + \
                                previous_edge_displacement.y * jump_ratios[i]), \
                        previous_edge.start_surface, \
                        movement_params.collider_half_width_height)
            
            velocity_start = JumpLandPositionsUtils.get_velocity_start( \
                    movement_params, \
                    jump_position.surface, \
                    edge_movement_calculator.is_a_jump_calculator)
            
            optimized_edge = edge_movement_calculator.calculate_edge( \
                    collision_params, \
                    jump_position, \
                    edge.end_position_along_surface, \
                    velocity_start, \
                    edge.includes_extra_jump_duration, \
                    edge.includes_extra_wall_land_horizontal_speed, \
                    in_debug_mode)
            
            if optimized_edge != null:
                optimized_edge.is_optimized_for_path = true
                
                previous_edge = IntraSurfaceEdge.new( \
                        previous_edge.start_position_along_surface, \
                        jump_position, \
                        Vector2.ZERO, \
                        movement_params)
                
                path.edges[edge_index - 1] = previous_edge
                path.edges[edge_index] = optimized_edge
                
                return

static func optimize_edge_land_position_for_path_helper( \
        collision_params: CollisionCalcParams, \
        path: PlatformGraphPath, \
        edge_index: int, \
        edge: Edge, \
        next_edge: IntraSurfaceEdge, \
        in_debug_mode: bool, \
        edge_movement_calculator: EdgeMovementCalculator) -> void:
    # TODO: Refactor this to use a true binary search. Right now it is similar, but we never
    #       move backward once we find a working land.
    var land_ratios := [1.0, 0.5, 0.25, 0.125]
    
    var movement_params := collision_params.movement_params
    
    var next_edge_displacement := next_edge.end - next_edge.start
    
    var is_horizontal_surface := \
            next_edge.start_surface != null and \
            (next_edge.start_surface.side == SurfaceSide.FLOOR or \
            next_edge.start_surface.side == SurfaceSide.CEILING)
    
    if is_horizontal_surface:
        # Landing on a floor or ceiling.
        
        var land_position: PositionAlongSurface
        var calc_results: MovementCalcResults
        var optimized_edge: Edge
        
        for i in range(land_ratios.size()):
            if land_ratios[i] == 1.0:
                land_position = next_edge.end_position_along_surface
            else:
                land_position = MovementUtils.create_position_offset_from_target_point( \
                        Vector2(next_edge.start.x + \
                                next_edge_displacement.x * land_ratios[i], 0.0), \
                        next_edge.start_surface, \
                        movement_params.collider_half_width_height)
            
            optimized_edge = edge_movement_calculator.calculate_edge( \
                    collision_params, \
                    edge.start_position_along_surface, \
                    land_position, \
                    edge.velocity_start, \
                    edge.includes_extra_jump_duration, \
                    false, \
                    in_debug_mode)
            
            if optimized_edge != null:
                optimized_edge.is_optimized_for_path = true
                
                next_edge = IntraSurfaceEdge.new( \
                        land_position, \
                        next_edge.end_position_along_surface, \
                        optimized_edge.velocity_end, \
                        movement_params)
                
                path.edges[edge_index] = optimized_edge
                path.edges[edge_index + 1] = next_edge
                
                return
        
    else:
        # Landing on a wall.
        
        var land_position: PositionAlongSurface
        var needs_extra_wall_land_horizontal_speed: bool
        var calc_results: MovementCalcResults
        var optimized_edge: Edge
        
        for i in range(land_ratios.size()):
            if land_ratios[i] == 1.0:
                land_position = next_edge.end_position_along_surface
            else:
                land_position = MovementUtils.create_position_offset_from_target_point( \
                        Vector2(0.0, next_edge.start.y + \
                                next_edge_displacement.y * land_ratios[i]), \
                        next_edge.start_surface, \
                        movement_params.collider_half_width_height)
            
            if JumpLandPositionsUtils.is_land_position_close_to_wall_bottom(land_position):
                # If we're too close to the wall bottom, than this and future possible optimized
                # land positions aren't valid.
                return
            
            optimized_edge = edge_movement_calculator.calculate_edge( \
                    collision_params, \
                    edge.start_position_along_surface, \
                    land_position, \
                    edge.velocity_start, \
                    edge.includes_extra_jump_duration, \
                    false, \
                    in_debug_mode)
            
            if optimized_edge != null:
                optimized_edge.is_optimized_for_path = true
                
                next_edge = IntraSurfaceEdge.new( \
                        land_position, \
                        next_edge.end_position_along_surface, \
                        Vector2.ZERO, \
                        movement_params)
                
                path.edges[edge_index] = optimized_edge
                path.edges[edge_index + 1] = next_edge
                
                return

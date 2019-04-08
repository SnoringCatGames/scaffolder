extends Reference
class_name PlatformGraphNodes

const Stopwatch = preload("res://framework/stopwatch.gd")

# TODO: Map the TileMap into an RTree or QuadTree.

var _stopwatch: Stopwatch

# Collections of surfaces.
# Array<PoolVector2Array>
var floors := []
var ceilings := []
var left_walls := []
var right_walls := []

# This supports mapping a cell in a TileMap to its corresponding surface.
# Dictionary<TileMap, Array<PoolVector2Array>>
var tile_map_index_to_surface_maps := {}

func _init(tile_maps: Array) -> void:
    _stopwatch = Stopwatch.new()
    for tile_map in tile_maps:
        parse_tile_map(tile_map)

# Parses the given TileMap into a set of nodes for the platform graph.
# 
# - Each "connecting" tile from the TileMap will be merged into a single surface node in the graph.
# - Each node in this graph corresponds to a continuous surface that could be walked on or climbed
#   on (i.e., floors and walls).
# - Each edge in this graph corresponds to a possible movement that the player could take to get
#   from one surface to another.
# 
# Assumptions:
# - The given TileMap only uses collidable tiles. Use a separate TileMap to paint any
#   non-collidable tiles.
# - The given TileMap only uses tiles with convex collision boundaries.
func parse_tile_map(tile_map: TileMap) -> void:
    var floors := []
    var ceilings := []
    var left_walls := []
    var right_walls := []
    var surface_to_tile_map_index := {}
    
    _stopwatch.start()
    print("_parse_tile_map_into_sides...")
    _parse_tile_map_into_sides(tile_map, floors, ceilings, left_walls, right_walls, \
            surface_to_tile_map_index)
    print("_parse_tile_map_into_sides duration: %sms" % _stopwatch.stop())
    
    _stopwatch.start()
    print("_remove_internal_surfaces: floors+ceilings...")
    _remove_internal_surfaces(floors, ceilings, surface_to_tile_map_index)
    print("_remove_internal_surfaces: left_walls+right_walls...")
    _remove_internal_surfaces(left_walls, right_walls, surface_to_tile_map_index)
    print("_remove_internal_surfaces duration: %sms" % _stopwatch.stop())
    
    _stopwatch.start()
    print("_merge_continuous_surfaces: floors...")
    _merge_continuous_surfaces(floors, surface_to_tile_map_index)
    print("_merge_continuous_surfaces: ceilings...")
    _merge_continuous_surfaces(ceilings, surface_to_tile_map_index)
    print("_merge_continuous_surfaces: left_walls...")
    _merge_continuous_surfaces(left_walls, surface_to_tile_map_index)
    print("_merge_continuous_surfaces: right_walls...")
    _merge_continuous_surfaces(right_walls, surface_to_tile_map_index)
    print("_merge_continuous_surfaces duration: %sms" % _stopwatch.stop())
    
    _stopwatch.start()
    print("_store_surfaces...")
    _store_surfaces(tile_map, floors, ceilings, left_walls, right_walls, surface_to_tile_map_index)
    print("_store_surfaces duration: %sms" % _stopwatch.stop())

# Parses the tiles of given TileMap into their constituent top-sides, left-sides, and right-sides.
func _parse_tile_map_into_sides(tile_map: TileMap, \
        floors: Array, ceilings: Array, left_walls: Array, right_walls: Array, \
        surface_to_tile_map_index: Dictionary) -> void:
    var tile_set := tile_map.tile_set
    var cell_size := tile_map.cell_size
    var used_cells := tile_map.get_used_cells()
    
    for position in used_cells:
        var tile_map_index := Utils.get_tile_map_index(position, tile_map)
        
        # Transform tile shapes into world coordinates.
        var tile_set_index := tile_map.get_cellv(position)
        var info: Dictionary = tile_set.tile_get_shapes(tile_set_index)[0]
        # ConvexPolygonShape2D
        var shape: Shape2D = info.shape
        var shape_transform: Transform2D = info.shape_transform
        var vertex_count: int = shape.points.size()
        var tile_vertices_world_coords := Array()
        tile_vertices_world_coords.resize(vertex_count)
        for i in range(vertex_count):
            var vertex: Vector2 = shape.points[i]
            var vertex_world_coords: Vector2 = shape_transform.xform(vertex) + position * cell_size
            tile_vertices_world_coords[i] = vertex_world_coords
        
        # Calculate and store the polylines from this shape that correspond to the shape's
        # top-side, right-side, and left-side.
        _parse_polygon_into_sides(tile_vertices_world_coords, floors, ceilings, left_walls,
                right_walls, surface_to_tile_map_index, tile_map_index)

# Parses the given polygon into separate polylines corresponding to the top-side, left-side, and
# right-side of the shape. Each of these polylines will be stored with their vertices in clockwise
# order.
func _parse_polygon_into_sides(vertices: Array, \
        floors: Array, ceilings: Array, left_walls: Array, right_walls: Array, \
        surface_to_tile_map_index: Dictionary, tile_map_index: int) -> void:
    var vertex_count := vertices.size()
    var is_clockwise: bool = Utils.is_polygon_clockwise(vertices)
    
    # Find the left-most, right-most, and bottom-most vertices.
    
    var vertex_x: float
    var vertex_y: float
    var left_most_vertex_x: float = vertices[0].x
    var right_most_vertex_x: float = vertices[0].x
    var bottom_most_vertex_y: float = vertices[0].y
    var top_most_vertex_y: float = vertices[0].y
    var left_most_vertex_index := 0
    var right_most_vertex_index := 0
    var bottom_most_vertex_index := 0
    var top_most_vertex_index := 0
    
    for i in range(1, vertex_count):
        vertex_x = vertices[i].x
        vertex_y = vertices[i].y
        if vertex_x < left_most_vertex_x:
            left_most_vertex_x = vertex_x
            left_most_vertex_index = i
        if vertex_x > right_most_vertex_x:
            right_most_vertex_x = vertex_x
            right_most_vertex_index = i
        if vertex_y > bottom_most_vertex_y:
            bottom_most_vertex_y = vertex_y
            bottom_most_vertex_index = i
        if vertex_y < top_most_vertex_y:
            top_most_vertex_y = vertex_y
            top_most_vertex_index = i
    
    # Iterate across the edges in a clockwise direction, regardless of the order the vertices
    # are defined in.
    var step := 1 if is_clockwise else vertex_count - 1
    
    var i1: int
    var i2: int
    var v1: Vector2
    var v2: Vector2
    var pos_angle: float
    var is_wall_segment: bool
    
    var top_side_start_index: int
    var top_side_end_index: int
    var left_side_start_index: int
    var right_side_end_index: int
    
    # Find the start of the top-side.
    
    # Fence-post problem: Calculate the first segment.
    i1 = left_most_vertex_index
    i2 = (i1 + step) % vertex_count
    v1 = vertices[i1]
    v2 = vertices[i2]
    pos_angle = abs(v1.angle_to_point(v2))
    is_wall_segment = pos_angle > Utils.FLOOR_MAX_ANGLE and \
            pos_angle < PI - Utils.FLOOR_MAX_ANGLE
    
    # If we find a non-wall segment, that's the start of the top-side. If we instead find no
    # non-wall segments until one segment after the top-most vertex, then there is no
    # top-side, and we will treat the top-most vertex as both the start and end of this
    # degenerate-case "top-side".
    while is_wall_segment and i1 != top_most_vertex_index:
        i1 = i2
        i2 = (i1 + step) % vertex_count
        v1 = vertices[i1]
        v2 = vertices[i2]
        pos_angle = abs(v1.angle_to_point(v2))
        is_wall_segment = pos_angle > Utils.FLOOR_MAX_ANGLE and \
                pos_angle < PI - Utils.FLOOR_MAX_ANGLE
    
    top_side_start_index = i1
    
    # Find the end of the top-side.
    
    # If we find a wall segment, that's the end of the top-side. If we instead find no wall
    # segments until one segment after the right-most vertex, then there is no right-side, and
    # we will treat the right-most vertex as the end of the top-side.
    while !is_wall_segment and i1 != right_most_vertex_index:
        i1 = i2
        i2 = (i1 + step) % vertex_count
        v1 = vertices[i1]
        v2 = vertices[i2]
        pos_angle = abs(v1.angle_to_point(v2))
        is_wall_segment = pos_angle > Utils.FLOOR_MAX_ANGLE and \
                pos_angle < PI - Utils.FLOOR_MAX_ANGLE
    
    top_side_end_index = i1
    
    # Find the end of the right-side.
    
    # If we find a non-wall segment, that's the end of the right-side. If we instead find no
    # non-wall segments until one segment after the bottom-most vertex, then there is no
    # bottom-side, and we will treat the bottom-most vertex as end of the bottom-side.
    while is_wall_segment and i1 != bottom_most_vertex_index:
        i1 = i2
        i2 = (i1 + step) % vertex_count
        v1 = vertices[i1]
        v2 = vertices[i2]
        pos_angle = abs(v1.angle_to_point(v2))
        is_wall_segment = pos_angle > Utils.FLOOR_MAX_ANGLE and \
                pos_angle < PI - Utils.FLOOR_MAX_ANGLE
    
    right_side_end_index = i1
    
    # Find the start of the left-side.
    
    # If we find a wall segment, that's the start of the left-side. If we instead find no wall
    # segments until one segment after the left-most vertex, then there is no left-side, and we
    # will treat the left-most vertex as both the start and end of this degenerate-case
    # "left-side".
    while !is_wall_segment and i1 != left_most_vertex_index:
        i1 = i2
        i2 = (i1 + step) % vertex_count
        v1 = vertices[i1]
        v2 = vertices[i2]
        pos_angle = abs(v1.angle_to_point(v2))
        is_wall_segment = pos_angle > Utils.FLOOR_MAX_ANGLE and \
                pos_angle < PI - Utils.FLOOR_MAX_ANGLE
    
    left_side_start_index = i1
    
    var i: int
    
    # Calculate the polyline corresponding to the top side.
    
    var top_side_vertices := []
    i = top_side_start_index
    while i != top_side_end_index:
        top_side_vertices.push_back(vertices[i])
        i = (i + step) % vertex_count
    top_side_vertices.push_back(vertices[i])
    
    # Calculate the polyline corresponding to the bottom side.
    
    var bottom_side_vertices := []
    i = right_side_end_index
    while i != left_side_start_index:
        bottom_side_vertices.push_back(vertices[i])
        i = (i + step) % vertex_count
    bottom_side_vertices.push_back(vertices[i])
    
    # Calculate the polyline corresponding to the left side.
    
    var left_side_vertices := []
    i = left_side_start_index
    while i != top_side_start_index:
        left_side_vertices.push_back(vertices[i])
        i = (i + step) % vertex_count
    left_side_vertices.push_back(vertices[i])
    
    # Calculate the polyline corresponding to the right side.
    
    var right_side_vertices := []
    i = top_side_end_index
    while i != right_side_end_index:
        right_side_vertices.push_back(vertices[i])
        i = (i + step) % vertex_count
    right_side_vertices.push_back(vertices[i])
    
    # Store the polylines.
    
    floors.push_back(top_side_vertices)
    ceilings.push_back(bottom_side_vertices)
    left_walls.push_back(right_side_vertices)
    right_walls.push_back(left_side_vertices)
    
    surface_to_tile_map_index[top_side_vertices] = tile_map_index
    surface_to_tile_map_index[bottom_side_vertices] = tile_map_index
    surface_to_tile_map_index[right_side_vertices] = tile_map_index
    surface_to_tile_map_index[left_side_vertices] = tile_map_index

# Removes some "internal" surfaces.
# 
# Specifically, this checks for pairs of floor+ceiling segments or left-wall+right-wall segments
# that share the same vertices. Both segments in these pairs are considered internal, and are
# removed.
# 
# Any surface polyline that consists of more than one segment is ignored.
func _remove_internal_surfaces(surfaces: Array, opposite_surfaces: Array, \
        surface_to_tile_map_index: Dictionary) -> void:
    var i: int
    var j: int
    var count_i: int
    var count_j: int
    var surface1: Array
    var surface2: Array
    var surface1_front: Vector2
    var surface1_back: Vector2
    var surface2_front: Vector2
    var surface2_back: Vector2
    var front_back_diff_x: float
    var front_back_diff_y: float
    var back_front_diff_x: float
    var back_front_diff_y: float
    
    count_i = surfaces.size()
    count_j = opposite_surfaces.size()
    i = 0
    while i < count_i:
        surface1 = surfaces[i]
        
        if surface1.size() > 2:
            i += 1
            continue
        
        surface1_front = surface1.front()
        surface1_back = surface1.back()
        
        j = 0
        while j < count_j:
            surface2 = opposite_surfaces[j]
            
            if surface2.size() > 2:
                j += 1
                continue
            
            surface2_front = surface2.front()
            surface2_back = surface2.back()
            
            # Vector equality checks, allowing for some round-off error.
            front_back_diff_x = surface1_front.x - surface2_back.x
            front_back_diff_y = surface1_front.y - surface2_back.y
            back_front_diff_x = surface1_back.x - surface2_front.x
            back_front_diff_y = surface1_back.y - surface2_front.y
            if front_back_diff_x < Utils.FLOAT_EPSILON and \
                    front_back_diff_x > -Utils.FLOAT_EPSILON and \
                    front_back_diff_y < Utils.FLOAT_EPSILON and \
                    front_back_diff_y > -Utils.FLOAT_EPSILON and \
                    back_front_diff_x < Utils.FLOAT_EPSILON and \
                    back_front_diff_x > -Utils.FLOAT_EPSILON and \
                    back_front_diff_y < Utils.FLOAT_EPSILON and \
                    back_front_diff_y > -Utils.FLOAT_EPSILON:
                # We found a pair of equivalent (internal) segments, so remove them.
                surfaces.remove(i)
                opposite_surfaces.remove(j)
                surface_to_tile_map_index.erase(surface1)
                surface_to_tile_map_index.erase(surface2)
                
                i -= 1
                j -= 1
                count_i -= 1
                count_j -= 1
                break
            
            j += 1
        
        i += 1

# Merges adjacent continuous surfaces.
func _merge_continuous_surfaces(surfaces: Array, surface_to_tile_map_index: Dictionary) -> void:
    var i: int
    var j: int
    var count: int
    var surface1: Array
    var surface2: Array
    var surface1_front: Vector2
    var surface1_back: Vector2
    var surface2_front: Vector2
    var surface2_back: Vector2
    var front_back_diff_x: float
    var front_back_diff_y: float
    var back_front_diff_x: float
    var back_front_diff_y: float
    var tile_map_index_1: int
    var tile_map_index_2: int
    
    var merge_count := 1
    while merge_count > 0:
        merge_count = 0
        count = surfaces.size()
        i = 0
        while i < count:
            surface1 = surfaces[i]
            surface1_front = surface1.front()
            surface1_back = surface1.back()
            
            j = i + 1
            while j < count:
                surface2 = surfaces[j]
                surface2_front = surface2.front()
                surface2_back = surface2.back()
                
                # Vector equality checks, allowing for some round-off error.
                front_back_diff_x = surface1_front.x - surface2_back.x
                front_back_diff_y = surface1_front.y - surface2_back.y
                back_front_diff_x = surface1_back.x - surface2_front.x
                back_front_diff_y = surface1_back.y - surface2_front.y
                if front_back_diff_x < Utils.FLOAT_EPSILON and \
                        front_back_diff_x > -Utils.FLOAT_EPSILON and \
                        front_back_diff_y < Utils.FLOAT_EPSILON and \
                        front_back_diff_y > -Utils.FLOAT_EPSILON:
                    # The start of surface 1 connects with the end of surface 2.
                    
                    tile_map_index_1 = surface_to_tile_map_index[surface1]
                    tile_map_index_2 = surface_to_tile_map_index[surface2]
                    surface_to_tile_map_index.erase(surface1)
                    surface_to_tile_map_index.erase(surface2)
                    
                    # Merge the two surfaces, replacing the first surface and removing the second
                    # surface.
                    surface2.pop_back()
                    Utils.concat(surface2, surface1)
                    surfaces.remove(j)
                    surfaces[i] = surface2
                    surface1 = surface2
                    surface1_front = surface1.front()
                    surface1_back = surface1.back()
                    
                    surface_to_tile_map_index[surface2] = tile_map_index_1
                    surface_to_tile_map_index[surface2] = tile_map_index_2
                                        
                    j -= 1
                    count -= 1
                    merge_count += 1
                elif back_front_diff_x < Utils.FLOAT_EPSILON and \
                        back_front_diff_x > -Utils.FLOAT_EPSILON and \
                        back_front_diff_y < Utils.FLOAT_EPSILON and \
                        back_front_diff_y > -Utils.FLOAT_EPSILON:
                    # The end of surface 1 connects with the start of surface 2.
                    
                    tile_map_index_1 = surface_to_tile_map_index[surface1]
                    tile_map_index_2 = surface_to_tile_map_index[surface2]
                    surface_to_tile_map_index.erase(surface1)
                    surface_to_tile_map_index.erase(surface2)
                    
                    # Merge the two surfaces, replacing the first surface and removing the second
                    # surface.
                    surface1.pop_back()
                    Utils.concat(surface1, surface2)
                    surfaces.remove(j)
                    
                    surface_to_tile_map_index[surface1] = tile_map_index_1
                    surface_to_tile_map_index[surface1] = tile_map_index_2
                    
                    j -= 1
                    count -= 1
                    merge_count += 1
                
                j += 1
            
            i += 1

func _store_surfaces(tile_map: TileMap, floors: Array, ceilings: Array, left_walls: Array, 
        right_walls: Array, surface_to_tile_map_index: Dictionary) -> void:
    var floors_pool_array = _convert_polyline_arrays_to_pool_arrays(floors)
    var ceilings_pool_array = _convert_polyline_arrays_to_pool_arrays(ceilings)
    var left_walls_pool_array = _convert_polyline_arrays_to_pool_arrays(left_walls)
    var right_walls_pool_array = _convert_polyline_arrays_to_pool_arrays(right_walls)
    
    _swap_array_mappings_with_pool_arrays(floors, floors_pool_array, surface_to_tile_map_index)
    _swap_array_mappings_with_pool_arrays(ceilings, ceilings_pool_array, surface_to_tile_map_index)
    _swap_array_mappings_with_pool_arrays(left_walls, left_walls_pool_array, surface_to_tile_map_index)
    _swap_array_mappings_with_pool_arrays(right_walls, right_walls_pool_array, surface_to_tile_map_index)
    
    Utils.concat(self.floors, floors_pool_array)
    Utils.concat(self.ceilings, ceilings_pool_array)
    Utils.concat(self.left_walls, left_walls_pool_array)
    Utils.concat(self.right_walls, right_walls_pool_array)
    
    var rect = tile_map.get_used_rect()
    var width = rect.size.x
    var height = rect.size.y
    var size = width * height
    tile_map_index_to_surface_maps[tile_map] = \
            _invert_surface_to_tile_map_mapping(surface_to_tile_map_index, size)

func _convert_polyline_arrays_to_pool_arrays(surfaces: Array) -> Array:
    var result := surfaces.duplicate()
    for i in range(result.size()):
        result[i] = PoolVector2Array(result[i])
    return result

func _swap_array_mappings_with_pool_arrays(array: Array, pool_array: PoolVector2Array, \
        surface_to_tile_map_index: Dictionary) -> void:
    var tile_map_index: int
    for surface in array:
        tile_map_index = surface_to_tile_map_index[surface]
        surface_to_tile_map_index.erase(surface)
        surface_to_tile_map_index[pool_array] = tile_map_index

func _invert_surface_to_tile_map_mapping(surface_to_tile_map_index: Dictionary, \
        size: int) -> Array:
    var result = []
    result.resize(size)
    var tile_map_index
    for surface in surface_to_tile_map_index:
        tile_map_index = surface_to_tile_map_index[surface]
        result[tile_map_index] = surface
    return result

class Surface:
    var vertices_array: Array
    var vertices_pool_array: PoolVector2Array
    var tile_map_index: int

# FIXME: LEFT OFF HERE:
# - Refactor all this to use a custom data structure to bundle surfaces with the tile
#   indices they map to?
# - Call .free() on each instance afterward.
# - I'm going to also need to refactor all this to store the tile_map_to_surface mappings
#   separately by side type.
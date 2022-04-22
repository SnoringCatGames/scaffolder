tool
class_name ScaffolderGeometry
extends Node


const UP := Vector2.UP
const DOWN := Vector2.DOWN
const LEFT := Vector2.LEFT
const RIGHT := Vector2.RIGHT
const FLOOR_MAX_ANGLE := PI / 4.0
const WALL_ANGLE_EPSILON := 0.01
const FLOAT_EPSILON := 0.00001


func _init() -> void:
    Sc.logger.on_global_init(self, "Geometry")


# Calculates the minimum squared distance between a line segment and a point.
static func get_distance_squared_from_point_to_segment(
        point: Vector2,
        segment_a: Vector2,
        segment_b: Vector2) -> float:
    var closest_point := get_closest_point_on_segment_to_point(
            point,
            segment_a,
            segment_b)
    return point.distance_squared_to(closest_point)


# Calculates the minimum squared distance between a polyline and a point.
static func get_distance_squared_from_point_to_polyline(
        point: Vector2,
        polyline: PoolVector2Array) -> float:
    var closest_point := get_closest_point_on_polyline_to_point(
            point,
            polyline)
    return point.distance_squared_to(closest_point)


# Calculates the minimum squared distance between two NON-INTERSECTING line
# segments.
static func get_distance_squared_between_non_intersecting_segments(
        segment_1_a: Vector2,
        segment_1_b: Vector2,
        segment_2_a: Vector2,
        segment_2_b: Vector2) -> float:
    var closest_on_2_to_1_a = get_closest_point_on_segment_to_point(
            segment_1_a,
            segment_2_a,
            segment_2_b)
    var closest_on_2_to_1_b = get_closest_point_on_segment_to_point(
            segment_1_b,
            segment_2_a,
            segment_2_b)
    var closest_on_1_to_2_a = get_closest_point_on_segment_to_point(
            segment_2_a,
            segment_1_a,
            segment_1_b)
    var closest_on_1_to_2_b = get_closest_point_on_segment_to_point(
            segment_2_a,
            segment_1_a,
            segment_1_b)
    
    var distance_squared_from_2_to_1_a = \
            closest_on_2_to_1_a.distance_squared_to(segment_1_a)
    var distance_squared_from_2_to_1_b = \
            closest_on_2_to_1_b.distance_squared_to(segment_1_b)
    var distance_squared_from_1_to_2_a = \
            closest_on_1_to_2_a.distance_squared_to(segment_2_a)
    var distance_squared_from_1_to_2_b = \
            closest_on_1_to_2_b.distance_squared_to(segment_2_b)
    
    return min(min(distance_squared_from_2_to_1_a,
                    distance_squared_from_2_to_1_b),
            min(distance_squared_from_1_to_2_a,
                    distance_squared_from_1_to_2_b))


static func get_distance_squared_from_rect_to_rect(
        a: Rect2,
        b: Rect2) -> float:
    var min_x := min(a.position.x, b.position.x)
    var min_y := min(a.position.y, b.position.y)
    var max_x := max(a.end.x, b.end.x)
    var max_y := max(a.end.y, b.end.y)
    var inner_width := max(0.0, (max_x - min_x) - a.size.x - b.size.x)
    var inner_height := max(0.0, (max_y - min_y) - a.size.y - b.size.y)
    return inner_width * inner_width + inner_height * inner_height


# Calculates the closest position on a line segment to a point.
static func get_closest_point_on_segment_to_point(
        point: Vector2,
        segment_a: Vector2,
        segment_b: Vector2) -> Vector2:
    var v := segment_b - segment_a
    var u := point - segment_a
    var uv: float = u.dot(v)
    var vv: float = v.dot(v)
    
    if uv <= 0.0:
        # The projection of the point lies before the first point in the
        # segment.
        return segment_a
    elif vv <= uv:
        # The projection of the point lies after the last point in the segment.
        return segment_b
    else:
        # The projection of the point lies within the bounds of the segment.
        var t := uv / vv
        return segment_a + t * v


static func get_closest_point_on_polyline_to_point(
        point: Vector2,
        polyline: PoolVector2Array) -> Vector2:
    if polyline.size() == 1:
        return polyline[0]
    
    var closest_point := get_closest_point_on_segment_to_point(
            point,
            polyline[0],
            polyline[1])
    var closest_distance_squared := point.distance_squared_to(closest_point)
    
    for i in range(1, polyline.size() - 1):
        var current_point := get_closest_point_on_segment_to_point(
                point,
                polyline[i],
                polyline[i + 1])
        var current_distance_squared := \
                point.distance_squared_to(current_point)
        if current_distance_squared < closest_distance_squared:
            closest_distance_squared = current_distance_squared
            closest_point = current_point
    
    return closest_point


static func get_closest_point_on_polyline_to_polyline(
        a: PoolVector2Array,
        b: PoolVector2Array) -> Vector2:
    if a.size() == 1:
        return a[0]
    
    var closest_point: Vector2
    var closest_distance_squared: float = INF
    
    for vertex_b in b:
        var current_point := \
                get_closest_point_on_polyline_to_point(vertex_b, a)
        var current_distance_squared: float = \
                vertex_b.distance_squared_to(current_point)
        if current_distance_squared < closest_distance_squared:
            closest_distance_squared = current_distance_squared
            closest_point = current_point
    
    return closest_point


# Calculates the point of intersection between two line segments. If the
# segments don't intersect, this returns a Vector2 with values of INFINITY.
static func get_intersection_of_segments(
        segment_1_a: Vector2,
        segment_1_b: Vector2,
        segment_2_a: Vector2,
        segment_2_b: Vector2) -> Vector2:
    var r := segment_1_b - segment_1_a
    var s := segment_2_b - segment_2_a
    
    var u_numerator := (segment_2_a - segment_1_a).cross(r)
    var denominator := r.cross(s)
    
    if u_numerator == 0 and denominator == 0:
        # The segments are collinear.
        var t0_numerator := (segment_2_a - segment_1_a).dot(r)
        var t1_numerator := (segment_1_a - segment_2_a).dot(s)
        if 0 <= t0_numerator and t0_numerator <= r.dot(r) or \
                0 <= t1_numerator and t1_numerator <= s.dot(s):
            # The segments overlap. Return one of the segment endpoints that
            # lies within the overlap region.
            if (segment_1_a.x >= segment_2_a.x and \
                    segment_1_a.x <= segment_2_b.x) or \
                    (segment_1_a.x <= segment_2_a.x and \
                    segment_1_a.x >= segment_2_b.x):
                return segment_1_a
            else:
                return segment_1_b
        else:
            # The segments are disjoint.
            return Vector2.INF
    elif denominator == 0:
        # The segments are parallel.
        return Vector2.INF
    else:
        # The segments are not parallel.
        var u := u_numerator / denominator
        var t := (segment_2_a - segment_1_a).cross(s) / denominator
        if t >= 0 and t <= 1 and u >= 0 and u <= 1:
            # The segments intersect.
            return segment_1_a + t * r
        else:
            # The segments don't touch.
            return Vector2.INF


# -   Calculates the point of intersection between a line segment and a
#     polyline.
# -   If the two don't intersect, this returns a Vector2 with values of
#     INFINITY.
static func get_intersection_of_segment_and_polyline(
        segment_a: Vector2,
        segment_b: Vector2,
        vertices: PoolVector2Array) -> Vector2:
    if vertices.size() == 1:
        if do_point_and_segment_intersect(
                segment_a,
                segment_b,
                vertices[0]):
            return vertices[0]
    else:
        for i in vertices.size() - 1:
            var intersection := get_intersection_of_segments(
                    segment_a,
                    segment_b,
                    vertices[i],
                    vertices[i + 1])
            if intersection != Vector2.INF:
                return intersection
    return Vector2.INF


# -   If the two don't intersect, this returns a Vector2 with values of
#     INFINITY.
# -   If there are two intersections, this returns the closest point to
#     segment_a.
static func get_intersection_of_segment_and_circle(
        segment_a: Vector2,
        segment_b: Vector2,
        center: Vector2,
        radius: float,
        uses_first_possible_intersection := true) -> Vector2:
    var d := segment_b - segment_a
    var f := segment_a - center
    var a := d.dot(d);
    var b := 2.0 * f.dot(d);
    var c := f.dot(f) - radius * radius;
    var discriminant := b * b - 4.0 * a * c
    
    if discriminant < 0:
        # The collinear line of the segment does not intersect the circle.
        return Vector2.INF
        
    else:
        var discriminant_sqrt := sqrt(discriminant)
        
        # t1 represents the intersection closer to segment_a.
        var t1 := (-b - discriminant_sqrt) / 2.0 / a
        var t2 := (-b + discriminant_sqrt) / 2.0 / a
        
        var is_t1_intersecting := t1 >= 0 and t1 <= 1
        var is_t2_intersecting := t2 >= 0 and t2 <= 1
        
        if uses_first_possible_intersection:
            if is_t1_intersecting:
                return segment_a + t1 * d
            if is_t2_intersecting:
                return segment_a + t2 * d
        else:
            if is_t2_intersecting:
                return segment_a + t2 * d
            if is_t1_intersecting:
                return segment_a + t1 * d
        
        # The collinear line intersects the circle, but the segment does not.
        return Vector2.INF


static func is_point_in_triangle(
        point: Vector2,
        a: Vector2,
        b: Vector2,
        c: Vector2) -> bool:
    # Uses the barycentric approach.
    
    var ac := c - a
    var ab := b - a
    var ap := point - a
    
    var dot_ac_ac: float = ac.dot(ac)
    var dot_ac_ab: float = ac.dot(ab)
    var dot_ac_ap: float = ac.dot(ap)
    var dot_ab_ab: float = ab.dot(ab)
    var dot_ab_ap: float = ab.dot(ap)
    
    # The barycentric coordinates.
    var inverse_denominator := \
            1 / (dot_ac_ac * dot_ab_ab - dot_ac_ab * dot_ac_ab)
    var u := (dot_ab_ab * dot_ac_ap - dot_ac_ab * dot_ab_ap) * \
            inverse_denominator
    var v := (dot_ac_ac * dot_ab_ap - dot_ac_ab * dot_ac_ap) * \
            inverse_denominator
    
    return u >= 0 and v >= 0 and u + v < 1


static func is_point_in_rectangle(
        point: Vector2,
        rectangle_min: Vector2,
        rectangle_max: Vector2) -> bool:
    return point.x > rectangle_min.x and \
            point.y > rectangle_min.y and \
            point.x < rectangle_max.x and \
            point.y < rectangle_max.y


static func do_rectangles_intersect(
        a_min: Vector2,
        a_max: Vector2,
        b_min: Vector2,
        b_max: Vector2) -> bool:
    return a_min.x <= b_max.x and \
            a_min.y <= b_max.y and \
            a_max.x >= b_min.x and \
            a_max.y >= b_min.y


static func does_rectangle_and_circle_intersect(
        rectangle_min: Vector2,
        rectangle_max: Vector2,
        circle_center: Vector2,
        circle_radius: float) -> bool:
    var rectangle_extents := (rectangle_max - rectangle_min) / 2.0
    var rectangle_center := rectangle_min + rectangle_extents
    
    var centers_distance_x := abs(circle_center.x - rectangle_center.x)
    var centers_distance_y := abs(circle_center.y - rectangle_center.y)
    
    if centers_distance_x >= rectangle_extents.x + circle_radius:
        return false
    if centers_distance_y >= rectangle_extents.y + circle_radius:
        return false
    
    if centers_distance_x < rectangle_extents.x:
        return true
    if centers_distance_y < rectangle_extents.y:
        return true
    
    var rectangle_diagonal_extent_distance_squared := \
            (centers_distance_x - rectangle_extents.x) * \
            (centers_distance_x - rectangle_extents.x) + \
            (centers_distance_y - rectangle_extents.y) * \
            (centers_distance_y - rectangle_extents.y)
    return rectangle_diagonal_extent_distance_squared < \
            circle_radius * circle_radius


static func do_segment_and_rectangle_intersect(
        segment_a: Vector2,
        segment_b: Vector2,
        rectangle_min: Vector2,
        rectangle_max: Vector2) -> bool:
    # First, check line intersection.
    var is_segment_left_of_corner_1 := \
            (segment_b.y - segment_a.y) * rectangle_min.x + \
            (segment_a.x - segment_b.x) * rectangle_min.y + \
            (segment_b.x * segment_a.y - segment_a.x * segment_b.y)
    var is_segment_left_of_corner_2 := \
            (segment_b.y - segment_a.y) * rectangle_max.x + \
            (segment_a.x - segment_b.x) * rectangle_min.y + \
            (segment_b.x * segment_a.y - segment_a.x * segment_b.y)
    var is_segment_left_of_corner_3 := \
            (segment_b.y - segment_a.y) * rectangle_max.x + \
            (segment_a.x - segment_b.x) * rectangle_max.y + \
            (segment_b.x * segment_a.y - segment_a.x * segment_b.y)
    var is_segment_left_of_corner_4 := \
            (segment_b.y - segment_a.y) * rectangle_min.x + \
            (segment_a.x - segment_b.x) * rectangle_max.y + \
            (segment_b.x * segment_a.y - segment_a.x * segment_b.y)
    if (is_segment_left_of_corner_1 == is_segment_left_of_corner_2) and \
            (is_segment_left_of_corner_1 == is_segment_left_of_corner_3) and \
            (is_segment_left_of_corner_1 == is_segment_left_of_corner_4):
        # If all rectangle corners are on the same side of the line, then there
        # is no intersection.
        return false
    
    # Second, check line-segment projection.
    return (segment_a.x <= rectangle_max.x or \
                segment_b.x <= rectangle_max.x) and \
            (segment_a.x >= rectangle_min.x or \
                segment_b.x >= rectangle_min.x) and \
            (segment_a.y <= rectangle_max.y or \
                segment_b.y <= rectangle_max.y) and \
            (segment_a.y >= rectangle_min.y or \
                segment_b.y >= rectangle_min.y)


static func do_segment_and_triangle_intersect(
        segment_a: Vector2,
        segment_b: Vector2,
        triangle_a: Vector2,
        triangle_b: Vector2,
        triangle_c: Vector2) -> bool:
    return \
            get_intersection_of_segments(
                    segment_a,
                    segment_b,
                    triangle_a,
                    triangle_b) != Vector2.INF or \
            get_intersection_of_segments(
                    segment_a,
                    segment_b,
                    triangle_a,
                    triangle_c) != Vector2.INF or \
            get_intersection_of_segments(
                    segment_a,
                    segment_b,
                    triangle_b,
                    triangle_c) != Vector2.INF or \
            is_point_in_triangle(
                    segment_a,
                    triangle_a,
                    triangle_b,
                    triangle_c)


# - Assumes that the polygon's closing segment is implied;
#   i.e., polygon.last != polygon.first.
# - Assumes that polygon.size() > 1.
# - Assumes that segment_a != segment_b.
# 
# -----------------------------------------------------------------------------
# Based on the "parametric line-clipping" approach described by Dan Sunday at
# http://geomalgorithms.com/a13-_intersect-4.html.
# 
# Copyright 2001 softSurfer, 2012 Dan Sunday
# This code may be freely used and modified for any purpose
# providing that this copyright notice is included with it.
# SoftSurfer makes no warranty for this code, and cannot be held
# liable for any real or imagined damage resulting from its use.
# Users of this code must verify correctness for their application.
# -----------------------------------------------------------------------------
static func do_segment_and_polygon_intersect(
        segment_a: Vector2,
        segment_b: Vector2,
        polygon: Array) -> bool:
    assert(polygon[0] == polygon[polygon.size() - 1])
    
    var segment_diff := segment_b - segment_a
    var t_entering := 0.0
    var t_leaving := 1.0
    
    for i in polygon.size() - 1:
        var polygon_segment: Vector2 = polygon[i + 1] - polygon[i]
        var p_to_a: Vector2 = segment_a - polygon[i]
        var n := polygon_segment.x * p_to_a.y - polygon_segment.y * p_to_a.x
        var d := polygon_segment.y * segment_diff.x - \
                polygon_segment.x * segment_diff.y
        
        if abs(d) < FLOAT_EPSILON:
            if n < 0:
                return false
            else:
                continue
        var t := n / d
        if d < 0:
            if t > t_entering:
                t_entering = t
                if t_entering > t_leaving:
                    return false
        else:
            if t < t_leaving:
                t_leaving = t
                if t_leaving < t_entering:
                    return false
    
    # Possible point of intersection 1: segment_a + t_entering * segment_diff
    # Possible point of intersection 2: segment_a + t_leaving * segment_diff
    
    return true


static func do_polyline_and_rectangle_intersect(
        vertices: Array,
        rectangle_min: Vector2,
        rectangle_max: Vector2) -> bool:
    for i in vertices.size() - 1:
        if do_segment_and_rectangle_intersect(
                vertices[i],
                vertices[i + 1],
                rectangle_min,
                rectangle_max):
            return true
    return false


static func do_polyline_and_triangle_intersect(
        vertices: PoolVector2Array,
        triangle_a: Vector2,
        triangle_b: Vector2,
        triangle_c: Vector2) -> bool:
    for i in vertices.size() - 1:
        var segment_a := vertices[i]
        var segment_b := vertices[i + 1]
        if do_segment_and_triangle_intersect(
                segment_a,
                segment_b,
                triangle_a,
                triangle_b,
                triangle_c):
            return true
    return false


static func do_polyline_and_polygon_intersect(
        vertices: PoolVector2Array,
        polygon: Array) -> bool:
    for i in vertices.size() - 1:
        var segment_a := vertices[i]
        var segment_b := vertices[i + 1]
        if do_segment_and_polygon_intersect(
                segment_a,
                segment_b,
                polygon):
            return true
    return false


static func are_floats_equal_with_epsilon(
        a: float,
        b: float,
        epsilon := FLOAT_EPSILON) -> bool:
    var diff = b - a
    return -epsilon < diff and diff < epsilon


static func are_points_equal_with_epsilon(
        a: Vector2,
        b: Vector2,
        epsilon := FLOAT_EPSILON) -> bool:
    var x_diff = b.x - a.x
    var y_diff = b.y - a.y
    return -epsilon < x_diff and x_diff < epsilon and \
            -epsilon < y_diff and y_diff < epsilon


static func are_rects_equal_with_epsilon(
        a: Rect2,
        b: Rect2,
        epsilon := FLOAT_EPSILON) -> bool:
    var x_diff = b.position.x - a.position.x
    var y_diff = b.position.y - a.position.y
    var w_diff = b.size.x - a.size.x
    var h_diff = b.size.y - a.size.y
    return -epsilon < x_diff and x_diff < epsilon and \
            -epsilon < y_diff and y_diff < epsilon and \
            -epsilon < w_diff and w_diff < epsilon and \
            -epsilon < h_diff and h_diff < epsilon


static func are_colors_equal_with_epsilon(
        a: Color,
        b: Color,
        epsilon := FLOAT_EPSILON) -> bool:
    var r_diff = b.r - a.r
    var g_diff = b.g - a.g
    var b_diff = b.b - a.b
    var a_diff = b.a - a.a
    return -epsilon < r_diff and r_diff < epsilon and \
            -epsilon < g_diff and g_diff < epsilon and \
            -epsilon < b_diff and b_diff < epsilon and \
            -epsilon < a_diff and a_diff < epsilon


static func is_float_integer_aligned_with_epsilon(
        number: float,
        epsilon := FLOAT_EPSILON) -> bool:
    var remainder := fmod(number, 1.0)
    return remainder < epsilon or remainder > 1.0 - epsilon


static func snap_float_to_integer(
        number: float,
        epsilon := FLOAT_EPSILON) -> float:
    if is_float_integer_aligned_with_epsilon(number, epsilon):
        return round(number)
    else:
        return number


static func snap_vector2_to_integers(
        point: Vector2,
        epsilon := FLOAT_EPSILON) -> Vector2:
    return Vector2(
            snap_float_to_integer(point.x),
            snap_float_to_integer(point.y))


static func is_float_gte_with_epsilon(
        a: float,
        b: float,
        epsilon := FLOAT_EPSILON) -> bool:
    var diff = b - a
    return a >= b or (-epsilon < diff and diff < epsilon)


static func is_float_lte_with_epsilon(
        a: float,
        b: float,
        epsilon := FLOAT_EPSILON) -> bool:
    var diff = b - a
    return a <= b or (-epsilon < diff and diff < epsilon)


static func clamp_vector_length(
        vector: Vector2,
        min_length: float,
        max_length: float) -> Vector2:
    var length_squared := vector.length_squared()
    if length_squared > max_length * max_length:
        return vector.normalized() * max_length
    elif length_squared < min_length * min_length:
        return vector.normalized() * min_length
    else:
        return vector


# Determine whether the points of the polygon are defined in a clockwise
# direction. This uses the shoelace formula.
static func is_polygon_clockwise(vertices: Array) -> bool:
    var vertex_count := vertices.size()
    var sum := 0.0
    var v1: Vector2 = vertices[vertex_count - 1]
    var v2: Vector2 = vertices[0]
    sum += (v2.x - v1.x) * (v2.y + v1.y)
    for i in vertex_count - 1:
        v1 = vertices[i]
        v2 = vertices[i + 1]
        sum += (v2.x - v1.x) * (v2.y + v1.y)
    return sum < 0


static func are_three_points_clockwise(
        a: Vector2,
        b: Vector2,
        c: Vector2) -> bool:
    var result := (a.y - b.y) * (c.x - a.x) - (a.x - b.x) * (c.y - a.y)
    return result > 0


static func is_polygon_convex(
        vertices: Array,
        epsilon := 0.001) -> bool:
    var vertex_count := vertices.size()
    
    assert(vertices[0] != vertices[vertex_count - 1])
    
    if vertex_count < 3:
        return true
    
    # First nonzero orientation (positive or negative)
    var w_sign := 0
    
    var x_sign := 0
    # Sign of first nonzero edge vector x
    var x_first_sign := 0
    # Number of sign changes in x
    var x_flips := 0
    
    var y_sign := 0
    # Sign of first nonzero edge vector y
    var y_first_sign := 0
    # Number of sign changes in y
    var y_flips := 0
    
    var previous_vertex: Vector2
    var current_vertex: Vector2 = vertices[vertex_count - 2]
    var next_vertex: Vector2 = vertices[vertex_count - 1]
    
    for vertex in vertices:
        previous_vertex = current_vertex
        current_vertex = next_vertex
        next_vertex = vertex
        
        var previous_diplacement := current_vertex - previous_vertex
        var next_diplacement := next_vertex - current_vertex
        
        # Count the number of sign flips, and record the first sign.
        if next_diplacement.x > epsilon:
            if x_sign == 0:
                x_first_sign = 1
            elif x_sign < 0:
                x_flips += 1
            x_sign = 1
        elif next_diplacement.x < -epsilon:
            if x_sign == 0:
                x_first_sign = -1
            elif x_sign > 0:
                x_flips += 1
            x_sign = -1
        
        if x_flips > 2:
            return false
        
        # Count the number of sign flips, and record the first sign.
        if next_diplacement.y > epsilon:
            if y_sign == 0:
                y_first_sign = 1
            elif y_sign < 0:
                y_flips += 1
            y_sign = 1
        elif next_diplacement.y < -epsilon:
            if y_sign == 0:
                y_first_sign = -1
            elif y_sign > 0:
                y_flips += 1
            y_sign = -1
        
        if y_flips > 2:
            return false
        
        # Calculate the edge-pair orientation, and check whether it has changed.
        var w := previous_diplacement.x * next_diplacement.y - \
                next_diplacement.x * previous_diplacement.y
        if w_sign == 0 and \
                (w < -epsilon or epsilon > epsilon):
            w_sign = 0
        elif w_sign > 0 and \
                w < -epsilon:
            return false
        elif w_sign < 0 and \
                w > epsilon:
            return false
    
    # Wrap-around sign flips (the fencepost problem).
    if x_sign != 0 and \
            x_first_sign != 0 and \
            x_sign != x_first_sign:
        x_flips += 1
    if y_sign != 0 and \
            y_first_sign != 0 and \
            y_sign != y_first_sign:
        y_flips += 1
    
    # Convex polygons have two sign flips along each axis.
    return x_flips == 2 and y_flips == 2


static func are_points_collinear(
        p1: Vector2,
        p2: Vector2,
        p3: Vector2,
        epsilon := FLOAT_EPSILON) -> bool:
    return abs((p2.x - p1.x) * (p3.y - p1.y) - \
            (p3.x - p1.x) * (p2.y - p1.y)) < epsilon


static func do_point_and_segment_intersect(
        point: Vector2,
        segment_a: Vector2,
        segment_b: Vector2,
        epsilon := FLOAT_EPSILON) -> bool:
    return abs((segment_a.x - point.x) * (segment_b.y - point.y) - \
            (segment_b.x - point.x) * (segment_a.y - point.y)) < epsilon and \
            ((point.x <= segment_a.x + epsilon and \
                point.x >= segment_b.x - epsilon) or \
            (point.x >= segment_a.x - epsilon and \
                point.x <= segment_b.x + epsilon))


static func get_bounding_box_for_points(points: Array) -> Rect2:
    assert(points.size() > 0)
    var bounding_box := Rect2(points[0], Vector2.ZERO)
    for i in range(1, points.size()):
        bounding_box = bounding_box.expand(points[i])
    return bounding_box


static func distance_squared_from_point_to_rect(
        point: Vector2,
        rect: Rect2) -> float:
    var rect_min := rect.position
    var rect_max := rect.end
    
    if point.x < rect_min.x:
        if point.y < rect_min.y:
            return point.distance_squared_to(rect_min)
        elif point.y > rect_max.y:
            return point.distance_squared_to(Vector2(rect_min.x, rect_max.y))
        else:
            var distance = rect_min.x - point.x
            return distance * distance
    elif point.x > rect_max.x:
        if point.y < rect_min.y:
            return point.distance_squared_to(Vector2(rect_max.x, rect_min.y))
        elif point.y > rect_max.y:
            return point.distance_squared_to(rect_max)
        else:
            var distance = point.x - rect_max.x
            return distance * distance
    else:
        if point.y < rect_min.y:
            var distance = rect_min.y - point.y
            return distance * distance
        elif point.y > rect_max.y:
            var distance = point.y - rect_max.y
            return distance * distance
        else:
            return 0.0


# The built-in TileMap.world_to_map generates incorrect results around cell
# boundaries, so we use a custom utility.
static func world_to_tilemap(
        position: Vector2,
        tile_map: TileMap) -> Vector2:
    var position_map_coord := \
            (position - tile_map.position) / tile_map.cell_size
    position_map_coord = Vector2(
            floor(position_map_coord.x),
            floor(position_map_coord.y))
    return position_map_coord


static func tilemap_to_world(
        position: Vector2,
        tile_map: TileMap) -> Vector2:
    return tile_map.position + position * tile_map.cell_size


# Calculates the TileMap (grid-based) coordinates of the given position,
# relative to the origin of the TileMap's bounding box.
static func get_tilemap_index_from_world_coord(
        position: Vector2,
        tile_map: TileMap) -> int:
    var position_grid_coord = world_to_tilemap(position, tile_map)
    return get_tilemap_index_from_grid_coord(position_grid_coord, tile_map)


# Calculates the TileMap (grid-based) coordinates of the given position,
# relative to the origin of the TileMap's bounding box.
static func get_tilemap_index_from_grid_coord(
        position: Vector2,
        tile_map: TileMap) -> int:
    var used_rect := tile_map.get_used_rect()
    var tilemap_start := used_rect.position
    var tilemap_width: int = used_rect.size.x
    var tilemap_position: Vector2 = position - tilemap_start
    return (tilemap_position.y * tilemap_width + tilemap_position.x) as int


static func get_grid_coord_from_tilemap_index(
        index: int,
        tile_map: TileMap) -> Vector2:
    var used_rect := tile_map.get_used_rect()
    var tilemap_grid_offset := used_rect.position / tile_map.cell_size
    var tilemap_width: int = used_rect.size.x
    var tilemap_position_x := index % tilemap_width
    var tilemap_position_y := int(index / tilemap_width)
    return Vector2(tilemap_position_x, tilemap_position_y) + \
            tilemap_grid_offset


static func get_tilemap_bounds_in_world_coordinates(
        tile_map: TileMap) -> Rect2:
    var used_rect := tile_map.get_used_rect()
    var cell_size := tile_map.cell_size
    return Rect2(
            tile_map.position.x + used_rect.position.x * cell_size.x,
            tile_map.position.y + used_rect.position.y * cell_size.y,
            used_rect.size.x * cell_size.x,
            used_rect.size.y * cell_size.y)


static func do_shapes_match(
        a: Shape2D,
        b: Shape2D) -> bool:
    if a is CircleShape2D:
        return b is CircleShape2D and \
                a.radius == b.radius
    elif a is CapsuleShape2D:
        return b is CapsuleShape2D and \
                a.radius == b.radius and \
                a.height == b.height
    elif a is RectangleShape2D:
        return b is RectangleShape2D and \
                a.extents == b.extents
    else:
        Sc.logger.error(
                "Invalid Shape2D provided for do_shapes_match: %s. The " +
                "supported shapes are: CircleShape2D, CapsuleShape2D, " +
                "RectangleShape2D." % a)
        return false


# The given rotation must be either 0 or PI.
static func calculate_half_width_height(
        shape: Shape2D,
        is_rotated_90_degrees: bool) -> Vector2:
    var half_width_height: Vector2
    if shape is CircleShape2D:
        half_width_height = Vector2(
                shape.radius,
                shape.radius)
    elif shape is CapsuleShape2D:
        half_width_height = Vector2(
                shape.radius,
                shape.radius + shape.height / 2.0)
    elif shape is RectangleShape2D:
        half_width_height = shape.extents
    else:
        Sc.logger.error(
                ("Invalid Shape2D provided to calculate_half_width_height: " +
                "%s. The upported shapes are: CircleShape2D, " +
                "CapsuleShape2D, RectangleShape2D.") % str(shape))
    
    if is_rotated_90_degrees:
        var swap := half_width_height.x
        half_width_height.x = half_width_height.y
        half_width_height.y = swap
        
    return half_width_height


static func calculate_manhattan_distance(
        a: Vector2,
        b: Vector2) -> float:
    return abs(b.x - a.x) + abs(b.y - a.y)


static func is_point_inf(point: Vector2) -> bool:
    return is_inf(point.x) and is_inf(point.y)


static func is_point_partial_inf(point: Vector2) -> bool:
    return is_inf(point.x) or is_inf(point.y)

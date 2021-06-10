class_name DrawUtils
extends Node


const SURFACE_DEPTH := 16.0
const SURFACE_DEPTH_DIVISIONS_COUNT := 8
const SURFACE_ALPHA_END_RATIO := .2

const INSTRUCTION_INDICATOR_HEAD_LENGTH_RATIO := 0.35
const INSTRUCTION_INDICATOR_HEAD_WIDTH_RATIO := 0.3
const INSTRUCTION_INDICATOR_STRIKE_THROUGH_LENGTH_RATIO := 0.8
const INSTRUCTION_INDICATOR_STROKE_WIDTH := 1.0

const STRIKE_THROUGH_ANGLE := -PI / 3.0

const EXCLAMATION_MARK_GAP_LENGTH_TO_WIDTH_RATIO := 0.5
const EXCLAMATION_MARK_BODY_LOWER_END_WIDTH_RATIO := 0.5
const EXCLAMATION_MARK_DOT_WIDTH_RATIO := 1.0


func _init() -> void:
    Gs.logger.print("DrawUtils._init")


# Godot's CanvasItem.draw_polyline function draws the ends of the polyline with
# a flat cap that is perpendicular to the adjacent segment.
# 
# If you try to use draw_polyline to draw a closed polygon outline by including
# the same point in the first and last position of the collection, then there
# will be a small gap between the "adjacent" start and end segments.
# 
# We can close this gap by ensuring that the first and last segments are
# colinear. We can make the first and last segments colinear by introducing
# additional vertices that are just slightly offset from the original ends.
static func draw_closed_polyline(
        canvas: CanvasItem,
        points: PoolVector2Array,
        color: Color,
        stroke_width := 1.0,
        antialiased := false) -> void:
    var original_size := points.size()
    assert(original_size >= 2)
    
    if original_size == 2:
        # Degenerate case: A line segment.
        canvas.draw_line(
                points[0],
                points[1],
                color,
                stroke_width,
                antialiased)
    
    points.insert(0, points[0])
    
    if points[0] == points[original_size]:
        # The given points collection already starts and ends with the same
        # point.
        points.push_back(points[0])
    else:
        # The given points collection starts and ends with a different point.
        points.resize(original_size + 3)
        points[original_size] = points[0]
        points[original_size + 1] = points[0]
    
    var new_size := points.size()
    
    var tangentish_direction := points[2] - points[1]
    var offset := tangentish_direction * 0.00001
    points[1] = points[0] + offset
    points[new_size - 2] = points[0] - offset
    
    canvas.draw_polyline(
            points,
            color,
            stroke_width,
            antialiased)


static func draw_dashed_line(
        canvas: CanvasItem,
        from: Vector2,
        to: Vector2,
        color: Color,
        dash_length: float,
        dash_gap: float,
        dash_offset: float = 0.0,
        width: float = 1.0,
        antialiased: bool = false) -> void:
    var segment_length := from.distance_to(to)
    var direction_normalized: Vector2 = (to - from).normalized()
    
    var current_length := dash_offset

    while current_length < segment_length:
        var current_dash_length := \
                dash_length if \
                current_length + dash_length <= segment_length else \
                segment_length - current_length
        
        var current_from := from + direction_normalized * current_length
        var current_to := from + direction_normalized * \
                (current_length + current_dash_length)
        
        canvas.draw_line(
                current_from,
                current_to,
                color,
                width,
                antialiased)
        
        current_length += dash_length + dash_gap


# TODO: Update this to honor gaps across vertices.
static func draw_dashed_polyline(
        canvas: CanvasItem,
        vertices: PoolVector2Array,
        color: Color,
        dash_length: float,
        dash_gap: float,
        dash_offset: float = 0.0,
        width: float = 1.0,
        antialiased: bool = false) -> void:
    for i in vertices.size() - 1:
        var from := vertices[i]
        var to := vertices[i + 1]
        draw_dashed_line(
                canvas,
                from,
                to,
                color,
                dash_length,
                dash_gap,
                dash_offset,
                width,
                antialiased)


static func draw_dashed_rectangle(
        canvas: CanvasItem,
        center: Vector2,
        half_width_height: Vector2,
        is_rotated_90_degrees: bool,
        color: Color,
        dash_length: float,
        dash_gap: float,
        dash_offset: float = 0.0,
        stroke_width: float = 1.0,
        antialiased: bool = false) -> void:
    var half_width := \
            half_width_height.y if \
            is_rotated_90_degrees else \
            half_width_height.x
    var half_height := \
            half_width_height.x if \
            is_rotated_90_degrees else \
            half_width_height.y

    var top_left := center + Vector2(-half_width, -half_height)
    var top_right := center + Vector2(half_width, -half_height)
    var bottom_right := center + Vector2(half_width, half_height)
    var bottom_left := center + Vector2(-half_width, half_height)
    
    draw_dashed_line(
            canvas,
            top_left,
            top_right,
            color,
            dash_length,
            dash_gap,
            dash_offset,
            stroke_width,
            antialiased)
    draw_dashed_line(
            canvas,
            top_right,
            bottom_right,
            color,
            dash_length,
            dash_gap,
            dash_offset,
            stroke_width,
            antialiased)
    draw_dashed_line(
            canvas,
            bottom_right,
            bottom_left,
            color,
            dash_length,
            dash_gap,
            dash_offset,
            stroke_width,
            antialiased)
    draw_dashed_line(
            canvas,
            bottom_left,
            top_left,
            color,
            dash_length,
            dash_gap,
            dash_offset,
            stroke_width,
            antialiased)


static func draw_surface(
        canvas: CanvasItem,
        surface: Surface,
        color: Color,
        depth := SURFACE_DEPTH) -> void:
    var surface_depth_division_size := depth / SURFACE_DEPTH_DIVISIONS_COUNT
    
    var vertices := surface.vertices
    var surface_depth_division_offset := \
            surface.normal * -surface_depth_division_size
    var alpha_start := color.a
    var alpha_end := alpha_start * SURFACE_ALPHA_END_RATIO
    
    # "Surfaces" can single vertices in the degenerate case.
    if vertices.size() > 1:
        for i in SURFACE_DEPTH_DIVISIONS_COUNT:
            var translation: Vector2 = surface_depth_division_offset * i
            var polyline: PoolVector2Array = \
                    Gs.utils.translate_polyline(vertices, translation)
            var progress: float = i / (SURFACE_DEPTH_DIVISIONS_COUNT - 1.0)
            color.a = alpha_start + progress * (alpha_end - alpha_start)
            canvas.draw_polyline(
                    polyline,
                    color,
                    surface_depth_division_size)
    else:
        canvas.draw_circle(
                vertices[0],
                6.0,
                color)


static func draw_position_along_surface(
        canvas: CanvasItem,
        position: PositionAlongSurface,
        target_point_color: Color,
        t_color: Color,
        target_point_radius := 4.0,
        t_length_in_surface := 8.0,
        t_length_out_of_surface := 8.0,
        t_width := 4.0,
        t_value_drawn := true,
        target_point_drawn := false,
        surface_drawn := false) -> void:
    # Optionally, annotate the t value.
    if t_value_drawn:
        if position.target_projection_onto_surface == Vector2.INF:
            position.target_projection_onto_surface = \
                    Gs.geometry.project_point_onto_surface(
                            position.target_point,
                            position.surface)
        var normal := position.surface.normal
        var start := position.target_projection_onto_surface + \
                normal * t_length_out_of_surface
        var end := position.target_projection_onto_surface - \
                normal * t_length_in_surface
        canvas.draw_line(
                start,
                end,
                t_color,
                t_width)
    
    # Optionally, annotate the target point.
    if target_point_drawn:
        canvas.draw_circle(
                position.target_point,
                target_point_radius,
                target_point_color)
    
    # Optionally, annotate the surface.
    if surface_drawn:
        draw_surface(
                canvas,
                position.surface,
                target_point_color)


static func draw_x(
        canvas: CanvasItem,
        center: Vector2,
        width: float,
        height: float,
        color: Color,
        stroke_width: float) -> void:
    var half_width := width / 2.0
    var half_height := height / 2.0
    canvas.draw_line(
            center + Vector2(-half_width, -half_height),
            center + Vector2(half_width, half_height),
            color,
            stroke_width)
    canvas.draw_line(
            center + Vector2(half_width, -half_height),
            center + Vector2(-half_width, half_height),
            color,
            stroke_width)


static func draw_plus(
        canvas: CanvasItem,
        center: Vector2,
        width: float,
        height: float,
        color: Color,
        stroke_width: float) -> void:
    var half_width := width / 2.0
    var half_height := height / 2.0
    canvas.draw_line(
            center + Vector2(-half_width, 0),
            center + Vector2(half_width, 0),
            color,
            stroke_width)
    canvas.draw_line(
            center + Vector2(0, -half_height),
            center + Vector2(0, half_height),
            color,
            stroke_width)


static func draw_asterisk(
        canvas: CanvasItem,
        center: Vector2,
        width: float,
        height: float,
        color: Color,
        stroke_width: float) -> void:
    var plus_width := width
    var plus_height := height
    var x_width := plus_width * 0.8
    var x_height := plus_height * 0.8
    draw_x(
            canvas,
            center,
            x_width,
            x_height,
            color,
            stroke_width)
    draw_plus(
            canvas,
            center,
            plus_width,
            plus_height,
            color,
            stroke_width)


static func draw_checkmark(
        canvas: CanvasItem,
        position: Vector2,
        width: float,
        color: Color,
        stroke_width: float) -> void:
    # We mostly treat the check mark as 90 degrees, divide the check mark into
    # thirds horizontally, and then position it so that the bottom-most point
    # of the checkmark is slightly below the target position. However, we then
    # give the right-right corner a slight adjustment upward, which makes the
    # checkmark slightly more accute than 90.
    var top_left_point := position + Vector2(-width / 3.0, -width / 6.0)
    var bottom_mid_point := position + Vector2(0, width / 6.0)
    var top_right_point := \
            position + Vector2(width * 2.0 / 3.0, -width / 2.0 * 1.33)
    
    canvas.draw_line(
            top_left_point,
            bottom_mid_point,
            color,
            stroke_width)
    canvas.draw_line(
            bottom_mid_point,
            top_right_point,
            color,
            stroke_width)


static func draw_exclamation_mark(
        canvas: CanvasItem,
        center: Vector2,
        width: float,
        length: float,
        color: Color,
        is_filled: bool,
        stroke_width: float,
        sector_arc_length := 4.0) -> void:
    var half_width := width / 2.0
    var half_length := length / 2.0
    
    var body_top_radius := half_width
    var body_bottom_radius := \
            body_top_radius * EXCLAMATION_MARK_BODY_LOWER_END_WIDTH_RATIO
    var dot_radius := body_top_radius * EXCLAMATION_MARK_DOT_WIDTH_RATIO
    
    var gap_length := width * EXCLAMATION_MARK_GAP_LENGTH_TO_WIDTH_RATIO
    var body_length := length - gap_length - dot_radius * 2.0
    
    var body_top_center := \
            center + Vector2(0.0, -half_length + body_top_radius)
    var body_bottom_center := \
            body_top_center + \
            Vector2(0.0,
                    body_length - \
                    body_top_radius - \
                    body_bottom_radius)
    var dot_center := \
            center + Vector2(0.0, half_length - dot_radius)
    
    # Draw the dot.
    if is_filled:
        canvas.draw_circle(
                dot_center,
                dot_radius,
                color)
    else:
        draw_circle_outline(
                canvas,
                dot_center,
                dot_radius,
                color,
                stroke_width,
                sector_arc_length)
    
    # Draw the body.
    draw_smooth_segment_with_two_circular_ends(
            canvas,
            body_top_center,
            body_top_radius,
            body_bottom_center,
            body_bottom_radius,
            color,
            is_filled,
            stroke_width,
            sector_arc_length)


static func draw_instruction_indicator(
        canvas: CanvasItem,
        input_key: String,
        is_pressed: bool,
        position: Vector2,
        length: float,
        color: Color) -> void:
    var half_length := length / 2.0
    var end_offset_from_mid: Vector2
    match input_key:
        "j":
            end_offset_from_mid = Vector2(0.0, -half_length)
        "ml":
            end_offset_from_mid = Vector2(-half_length, 0.0)
        "mr":
            end_offset_from_mid = Vector2(half_length, 0.0)
        _:
            Gs.logger.error("Invalid input_key: %s" % input_key)
    
    var start := position - end_offset_from_mid
    var end := position + end_offset_from_mid
    var head_length := length * INSTRUCTION_INDICATOR_HEAD_LENGTH_RATIO
    var head_width := length * INSTRUCTION_INDICATOR_HEAD_WIDTH_RATIO
    var strike_through_length := \
            INF if \
            is_pressed else \
            length * INSTRUCTION_INDICATOR_STRIKE_THROUGH_LENGTH_RATIO
    
    draw_strike_through_arrow(
            canvas,
            start,
            end,
            head_length,
            head_width,
            strike_through_length,
            color,
            INSTRUCTION_INDICATOR_STROKE_WIDTH)


static func draw_arrow(
        canvas: CanvasItem,
        start: Vector2,
        end: Vector2,
        head_length: float,
        head_width: float,
        color: Color,
        stroke_width: float) -> void:
    draw_strike_through_arrow(
            canvas,
            start,
            end,
            head_length,
            head_width,
            INF,
            color,
            stroke_width)


static func draw_strike_through_arrow(
        canvas: CanvasItem,
        start: Vector2,
        end: Vector2,
        head_length: float,
        head_width: float,
        strike_through_length: float,
        color: Color,
        stroke_width: float) -> void:
    # Calculate points in the arrow head.
    var start_to_end_angle := start.angle_to_point(end)
    var head_diff_1 := Vector2(head_length, -head_width * 0.5) \
            .rotated(start_to_end_angle)
    var head_diff_2 := Vector2(head_length, head_width * 0.5) \
            .rotated(start_to_end_angle)
    var head_end_1 := end + head_diff_1
    var head_end_2 := end + head_diff_2
    
    # Draw the arrow head.
    canvas.draw_line(
            end,
            head_end_1,
            color,
            stroke_width)
    canvas.draw_line(
            end,
            head_end_2,
            color,
            stroke_width)
    
    # Draw the arrow body.
    canvas.draw_line(
            start,
            end,
            color,
            stroke_width)
    
    # Draw the strike through.
    if strike_through_length != INF:
        var strike_through_angle := start_to_end_angle + STRIKE_THROUGH_ANGLE
        var strike_through_middle := start.linear_interpolate(
                end,
                0.5)
        var strike_through_half_length := strike_through_length / 2.0
        var strike_through_offset := Vector2(
                cos(strike_through_angle) * strike_through_half_length,
                sin(strike_through_angle) * strike_through_half_length)
        var strike_through_start := \
                strike_through_middle - strike_through_offset
        var strike_through_end := \
                strike_through_middle + strike_through_offset
        canvas.draw_line(
                strike_through_start,
                strike_through_end,
                color,
                stroke_width)


static func draw_diamond_outline(
        canvas: CanvasItem,
        center: Vector2,
        width: float,
        height: float,
        color: Color,
        stroke_width: float) -> void:
    var half_width := width / 2.0
    var half_height := height / 2.0
    canvas.draw_line(
            center + Vector2(-half_width, 0),
            center + Vector2(0, -half_height),
            color,
            stroke_width)
    canvas.draw_line(
            center + Vector2(0, -half_height),
            center + Vector2(half_width, 0),
            color,
            stroke_width)
    canvas.draw_line(
            center + Vector2(half_width, 0),
            center + Vector2(0, half_height),
            color,
            stroke_width)
    canvas.draw_line(
            center + Vector2(0, half_height),
            center + Vector2(-half_width, 0),
            color,
            stroke_width)


static func draw_shape_outline(
        canvas: CanvasItem,
        position: Vector2,
        shape: Shape2D,
        rotation: float,
        color: Color,
        thickness: float) -> void:
    var is_rotated_90_degrees = \
            abs(fmod(rotation + PI * 2, PI) - PI / 2) < Gs.geometry.FLOAT_EPSILON
    
    # Ensure that collision boundaries are only ever axially aligned.
    assert(is_rotated_90_degrees or abs(rotation) < Gs.geometry.FLOAT_EPSILON)
    
    if shape is CircleShape2D:
        draw_circle_outline(
                canvas,
                position,
                shape.radius,
                color,
                thickness)
    elif shape is CapsuleShape2D:
        draw_capsule_outline(
                canvas,
                position,
                shape.radius,
                shape.height,
                is_rotated_90_degrees,
                color,
                thickness)
    elif shape is RectangleShape2D:
        draw_rectangle_outline(
                canvas,
                position,
                shape.extents,
                is_rotated_90_degrees,
                color,
                thickness)
    else:
        Gs.logger.error(
                "Invalid Shape2D provided for draw_shape: %s. The " +
                "supported shapes are: CircleShape2D, CapsuleShape2D, " +
                "RectangleShape2D." % shape)


static func draw_circle_outline(
        canvas: CanvasItem,
        center: Vector2,
        radius: float,
        color: Color,
        border_width := 1.0,
        sector_arc_length := 4.0) -> void:
    var points := compute_arc_points(
            center,
            radius,
            0.0,
            2.0 * PI,
            sector_arc_length)
    
    # Even though the points ended and began at the same position, Godot would
    # render a gap, because the "adjacent" segments aren't colinear, and thus
    # their end caps don't align. We introduce two vertices, at very slight
    # offsets, so that we can force the end caps to line up.
    points.insert(0, points[0])
    points.push_back(points[0])
    points[points.size() - 2].y -= 0.0001
    points[1].y += 0.0001
    
    canvas.draw_polyline(
            points,
            color,
            border_width)


static func draw_arc(
        canvas: CanvasItem,
        center: Vector2,
        radius: float,
        start_angle: float,
        end_angle: float,
        color: Color,
        border_width := 1.0,
        sector_arc_length := 4.0) -> void:
    var points := compute_arc_points(
            center,
            radius,
            start_angle,
            end_angle,
            sector_arc_length)
    
    canvas.draw_polyline(
            points,
            color,
            border_width)


static func compute_arc_points(
        center: Vector2,
        radius: float,
        start_angle: float,
        end_angle: float,
        sector_arc_length := 4.0) -> PoolVector2Array:
    assert(sector_arc_length > 0.0)
    
    var angle_diff := end_angle - start_angle
    var sector_count := floor(abs(angle_diff) * radius / sector_arc_length)
    var delta_theta := sector_arc_length / radius
    var theta := start_angle
    
    if angle_diff == 0:
        return PoolVector2Array([
                Vector2(cos(start_angle), sin(start_angle)) * radius + center])
    elif angle_diff < 0:
        delta_theta = -delta_theta
    
    var should_include_partial_sector_at_end := \
            abs(angle_diff) - sector_count * delta_theta > 0.01
    var vertex_count := sector_count + 1
    if should_include_partial_sector_at_end:
        vertex_count += 1
    
    var points := PoolVector2Array()
    points.resize(vertex_count)
    
    for i in sector_count + 1:
        points[i] = Vector2(cos(theta), sin(theta)) * radius + center
        theta += delta_theta
    
    # Handle the fence-post problem.
    if should_include_partial_sector_at_end:
        points[vertex_count - 1] = \
                Vector2(cos(end_angle), sin(end_angle)) * radius + center
    
    return points


static func draw_rectangle_outline(
        canvas: CanvasItem,
        center: Vector2,
        half_width_height: Vector2,
        is_rotated_90_degrees: bool,
        color: Color,
        thickness := 1.0) -> void:
    var x_offset: float = \
            half_width_height.y if \
            is_rotated_90_degrees else \
            half_width_height.x
    var y_offset: float = \
            half_width_height.x if \
            is_rotated_90_degrees else \
            half_width_height.y
    
    var polyline := PoolVector2Array()
    polyline.resize(6)
    
    polyline[1] = center + Vector2(-x_offset, -y_offset)
    polyline[2] = center + Vector2(x_offset, -y_offset)
    polyline[3] = center + Vector2(x_offset, y_offset)
    polyline[4] = center + Vector2(-x_offset, y_offset)
    
    # By having the polyline start and end in the middle of a segment, we can
    # ensure the end caps line up and don't show a gap.
    polyline[5] = lerp(polyline[4], polyline[1], 0.5)
    polyline[0] = polyline[5]
    
    canvas.draw_polyline(
            polyline,
            color,
            thickness)


static func draw_capsule_outline(
        canvas: CanvasItem,
        center: Vector2,
        radius: float,
        height: float,
        is_rotated_90_degrees: bool,
        color: Color,
        thickness := 1.0,
        sector_arc_length := 4.0) -> void:
    var sector_count := ceil((PI * radius / sector_arc_length) / 2.0) * 2.0
    var delta_theta := PI / sector_count
    var theta := \
            PI / 2.0 if \
            is_rotated_90_degrees else \
            0.0
    var capsule_end_offset := \
            Vector2(height / 2.0, 0.0) if \
            is_rotated_90_degrees else \
            Vector2(0.0, height / 2.0)
    var end_center := center - capsule_end_offset
    var vertices := PoolVector2Array()
    var vertex_count := (sector_count + 1) * 2 + 2
    vertices.resize(vertex_count)
    
    for i in sector_count + 1:
        vertices[i + 1] = Vector2(cos(theta), sin(theta)) * radius + end_center
        theta += delta_theta
    
    end_center = center + capsule_end_offset
    theta -= delta_theta
    
    for i in range(sector_count + 1, (sector_count + 1) * 2):
        vertices[i + 1] = Vector2(cos(theta), sin(theta)) * radius + end_center
        theta += delta_theta
    
    # By having the polyline start and end in the middle of a segment, we can
    # ensure the end caps line up and don't show a gap.
    vertices[vertex_count - 1] = lerp(
            vertices[vertex_count - 2],
            vertices[1],
            0.5)
    vertices[0] = vertices[vertex_count - 1]
    
    canvas.draw_polyline(
            vertices,
            color,
            thickness)


# This applies Thales's theorem to find the points of tangency between the line
# segments from the triangular portion and the circle:
# https://en.wikipedia.org/wiki/Thales%27s_theorem
static func draw_ice_cream_cone(
        canvas: CanvasItem,
        cone_end_point: Vector2,
        circle_center: Vector2,
        circle_radius: float,
        color: Color,
        is_filled: bool,
        border_width := 1.0,
        sector_arc_length := 4.0) -> void:
    assert(circle_radius >= 0.0)
    
    var distance_from_cone_end_point_to_circle_center := \
            cone_end_point.distance_to(circle_center)
    
    if circle_radius <= 0.0:
        # Degenerate case: A line segment.
        canvas.draw_line(
                circle_center,
                cone_end_point,
                color,
                border_width,
                false)
        return
    elif distance_from_cone_end_point_to_circle_center <= circle_radius:
        # Degenerate case: A circle (the cone-end-point lies within the circle).
        if is_filled:
            canvas.draw_circle(
                    circle_center,
                    circle_radius,
                    color)
            return
        else:
            draw_circle_outline(
                    canvas,
                    circle_center,
                    circle_radius,
                    color,
                    border_width,
                    sector_arc_length)
            return
    
    var angle_from_circle_center_to_point_of_tangency := \
            acos(circle_radius / distance_from_cone_end_point_to_circle_center)
    var angle_from_circle_center_to_cone_end_point := \
            cone_end_point.angle_to_point(circle_center)
    
    var start_angle := angle_from_circle_center_to_cone_end_point + \
            angle_from_circle_center_to_point_of_tangency
    var end_angle := angle_from_circle_center_to_cone_end_point + \
            2.0 * PI - \
            angle_from_circle_center_to_point_of_tangency
    
    var points := compute_arc_points(
            circle_center,
            circle_radius,
            start_angle,
            end_angle,
            sector_arc_length)
    
    # These extra points prevent the stroke width from shrinking around the
    # cone end point.
    var extra_cone_end_point_1 := \
            cone_end_point + \
            (points[points.size() - 1] - cone_end_point) * 0.000001
    var extra_cone_end_point_2 := \
            cone_end_point + \
            (points[0] - cone_end_point) * 0.000001
    
    points.push_back(extra_cone_end_point_1)
    points.push_back(cone_end_point)
    points.push_back(extra_cone_end_point_2)
    points.push_back(points[0])
    
    if is_filled:
        canvas.draw_colored_polygon(
                points,
                color)
    else:
        canvas.draw_polyline(
                points,
                color,
                border_width)


# -   This applies Thales's theorem to find the points of tangency between the
#     line segments from the triangular portion and the circle:
#     https://en.wikipedia.org/wiki/Thales%27s_theorem
# -   Also see:
#     https://en.wikipedia.org/wiki/Tangent_lines_to_circles#Tangent_lines_to_two_circles
static func draw_smooth_segment_with_two_circular_ends(
        canvas: CanvasItem,
        center_1: Vector2,
        radius_1: float,
        center_2: Vector2,
        radius_2: float,
        color: Color,
        is_filled: bool,
        stroke_width: float,
        sector_arc_length := 4.0) -> void:
    assert(radius_1 >= 0.0)
    assert(radius_2 >= 0.0)
    
    var larger_radius: float
    var larger_center: Vector2
    var smaller_radius: float
    var smaller_center: Vector2
    if radius_1 > radius_2:
        larger_radius = radius_1
        larger_center = center_1
        smaller_radius = radius_2
        smaller_center = center_2
    else:
        larger_radius = radius_2
        larger_center = center_2
        smaller_radius = radius_1
        smaller_center = center_1
    
    var distance_between_circle_centers := \
            smaller_center.distance_to(larger_center)
    
    if larger_radius == 0.0:
        # Degenerate case: A line segment.
        canvas.draw_line(
                smaller_center,
                larger_center,
                color,
                stroke_width,
                false)
        return
    elif distance_between_circle_centers + smaller_radius <= larger_radius:
        # Degenerate case: A circle (the smaller circle lies entirely inside
        # the larger circle).
        if is_filled:
            canvas.draw_circle(
                    larger_center,
                    larger_radius,
                    color)
            return
        else:
            draw_circle_outline(
                    canvas,
                    larger_center,
                    larger_radius,
                    color,
                    stroke_width,
                    sector_arc_length)
            return
    elif smaller_radius == 0.0:
        # Degenerate case: An ice-cream-cone shape, with a cusp at one end.
        draw_ice_cream_cone(
                canvas,
                smaller_center,
                larger_center,
                larger_radius,
                color,
                is_filled,
                stroke_width,
                sector_arc_length)
        return
    
    var angle_between_circle_centers := \
            smaller_center.angle_to_point(larger_center)
    var beta := asin(
            (larger_radius - smaller_radius) / \
            distance_between_circle_centers)
    
    # This angle is identical on either circle.
    var angle_from_circle_center_to_point_of_outer_tangency := \
            angle_between_circle_centers - beta
    
    var smaller_start_angle := angle_between_circle_centers - beta + PI / 2.0
    var smaller_end_angle := angle_between_circle_centers + beta - PI / 2.0
    var larger_start_angle := smaller_end_angle
    var larger_end_angle := smaller_start_angle
    if smaller_end_angle > smaller_start_angle:
        larger_end_angle += 2.0 * PI
    else:
        larger_end_angle -= 2.0 * PI
    
    var smaller_circle_arc_points := compute_arc_points(
            smaller_center,
            smaller_radius,
            smaller_start_angle,
            smaller_end_angle,
            sector_arc_length)
    var larger_circle_arc_points := compute_arc_points(
            larger_center,
            larger_radius,
            larger_start_angle,
            larger_end_angle,
            sector_arc_length)
    
    # Combine the points from both arcs.
    var smaller_arc_count := smaller_circle_arc_points.size()
    var larger_arc_count := larger_circle_arc_points.size()
    assert(smaller_arc_count + larger_arc_count >= 2)
    var points := []
    points.resize(smaller_arc_count + larger_arc_count + 2)
    for i in smaller_arc_count:
        points[i + 1] = smaller_circle_arc_points[i]
    for i in larger_arc_count:
        points[smaller_arc_count + i + 1] = larger_circle_arc_points[i]
    
    # By having the polyline start and end in the middle of a segment, we can
    # ensure the end caps line up and don't show a gap.
    points[points.size() - 1] = lerp(points[points.size() - 2], points[1], 0.5)
    points[0] = points[points.size() - 1]
    
    if is_filled:
        canvas.draw_colored_polygon(
                points,
                color)
    else:
        canvas.draw_polyline(
                points,
                color,
                stroke_width)
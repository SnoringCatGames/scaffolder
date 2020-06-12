extends Node

### Surface

const SURFACE_HUE_MIN := 0.0
const SURFACE_HUE_MAX := 1.0
const SURFACE_SATURATION := 0.9
const SURFACE_VALUE := 0.8
const SURFACE_ALPHA := 0.6

const DEFAULT_SURFACE_HUE := 0.23
const ORIGIN_SURFACE_HUE := 0.11
const DESTINATION_SURFACE_HUE := 0.61

const SURFACE_DEPTH := 16.0

var SURFACE_COLOR_PARAMS := \
        ColorParamsFactory.create_hsv_range_color_params_with_constant_sva( \
                SURFACE_HUE_MIN, \
                SURFACE_HUE_MAX, \
                SURFACE_SATURATION, \
                SURFACE_VALUE, \
                SURFACE_ALPHA)
var DEFAULT_SURFACE_COLOR_PARAMS := HsvColorParams.new( \
        DEFAULT_SURFACE_HUE, \
        SURFACE_SATURATION, \
        SURFACE_VALUE, \
        SURFACE_ALPHA)
var ORIGIN_SURFACE_COLOR_PARAMS := HsvColorParams.new( \
        ORIGIN_SURFACE_HUE, \
        SURFACE_SATURATION, \
        SURFACE_VALUE, \
        SURFACE_ALPHA)
var DESTINATION_SURFACE_COLOR_PARAMS := HsvColorParams.new( \
        DESTINATION_SURFACE_HUE, \
        SURFACE_SATURATION, \
        SURFACE_VALUE, \
        SURFACE_ALPHA)

### Edge

const EDGE_HUE_MIN := 0.0
const EDGE_HUE_MAX := 1.0

const EDGE_DISCRETE_TRAJECTORY_SATURATION := 0.8
const EDGE_DISCRETE_TRAJECTORY_VALUE := 0.9
const EDGE_DISCRETE_TRAJECTORY_ALPHA := 0.8

const EDGE_CONTINUOUS_TRAJECTORY_SATURATION := 0.6
const EDGE_CONTINUOUS_TRAJECTORY_VALUE := 0.6
const EDGE_CONTINUOUS_TRAJECTORY_ALPHA := 0.7

const INCLUDES_WAYPOINTS := true
const INCLUDES_INSTRUCTION_INDICATORS := true
const INCLUDES_CONTINUOUS_POSITIONS := true

# - Lighter, more opaque.
# - More accurate to what is actually executed.
# - Less accurate to what is originally calculated.
var EDGE_DISCRETE_TRAJECTORY_COLOR_PARAMS := \
        ColorParamsFactory.create_hsv_range_color_params_with_constant_sva( \
                EDGE_HUE_MIN, \
                EDGE_HUE_MAX, \
                EDGE_DISCRETE_TRAJECTORY_SATURATION, \
                EDGE_DISCRETE_TRAJECTORY_VALUE, \
                EDGE_DISCRETE_TRAJECTORY_ALPHA)
# - Darker, more transparent.
# - More accurate to what is originally calculated.
# - Less accurate to what is actually executed.
var EDGE_CONTINUOUS_TRAJECTORY_COLOR_PARAMS := \
        ColorParamsFactory.create_hsv_range_color_params_with_constant_sva( \
                EDGE_HUE_MIN, \
                EDGE_HUE_MAX, \
                EDGE_CONTINUOUS_TRAJECTORY_SATURATION, \
                EDGE_CONTINUOUS_TRAJECTORY_VALUE, \
                EDGE_CONTINUOUS_TRAJECTORY_ALPHA)

var DEFAULT_EDGE_DISCRETE_TRAJECTORY_HUE := DEFAULT_SURFACE_HUE
var DEFAULT_EDGE_DISCRETE_TRAJECTORY_COLOR_PARAMS := \
        HsvColorParams.new( \
                DEFAULT_EDGE_DISCRETE_TRAJECTORY_HUE, \
                EDGE_DISCRETE_TRAJECTORY_SATURATION, \
                EDGE_DISCRETE_TRAJECTORY_VALUE, \
                EDGE_DISCRETE_TRAJECTORY_ALPHA)

var DEFAULT_EDGE_CONTINUOUS_TRAJECTORY_HUE := \
        DEFAULT_EDGE_DISCRETE_TRAJECTORY_HUE
var DEFAULT_EDGE_CONTINUOUS_TRAJECTORY_COLOR_PARAMS := \
        HsvColorParams.new( \
                DEFAULT_EDGE_CONTINUOUS_TRAJECTORY_HUE, \
                EDGE_CONTINUOUS_TRAJECTORY_SATURATION, \
                EDGE_CONTINUOUS_TRAJECTORY_VALUE, \
                EDGE_CONTINUOUS_TRAJECTORY_ALPHA)

### Waypoint

const WAYPOINT_HUE_MIN := 0.0
const WAYPOINT_HUE_MAX := 1.0
const WAYPOINT_SATURATION := 0.6
const WAYPOINT_VALUE := 0.7
const WAYPOINT_ALPHA := 0.7

var WAYPOINT_COLOR_PARAMS := \
        ColorParamsFactory.create_hsv_range_color_params_with_constant_sva( \
                WAYPOINT_HUE_MIN, \
                WAYPOINT_HUE_MAX, \
                WAYPOINT_SATURATION, \
                WAYPOINT_VALUE, \
                WAYPOINT_ALPHA)

var DEFAULT_WAYPOINT_HUE := DEFAULT_EDGE_CONTINUOUS_TRAJECTORY_HUE
var DEFAULT_WAYPOINT_COLOR_PARAMS := \
        HsvColorParams.new( \
                DEFAULT_WAYPOINT_HUE, \
                WAYPOINT_SATURATION, \
                WAYPOINT_VALUE, \
                WAYPOINT_ALPHA)

### Instruction

const INSTRUCTION_HUE_MIN := 0.0
const INSTRUCTION_HUE_MAX := 1.0
const INSTRUCTION_SATURATION := 0.3
const INSTRUCTION_VALUE := 0.9
const INSTRUCTION_ALPHA := 0.7

var INSTRUCTION_COLOR_PARAMS := \
        ColorParamsFactory.create_hsv_range_color_params_with_constant_sva( \
                INSTRUCTION_HUE_MIN, \
                INSTRUCTION_HUE_MAX, \
                INSTRUCTION_SATURATION, \
                INSTRUCTION_VALUE, \
                INSTRUCTION_ALPHA)

var DEFAULT_INSTRUCTION_HUE := DEFAULT_EDGE_CONTINUOUS_TRAJECTORY_HUE
var DEFAULT_INSTRUCTION_COLOR_PARAMS := \
        HsvColorParams.new( \
                DEFAULT_INSTRUCTION_HUE, \
                INSTRUCTION_SATURATION, \
                INSTRUCTION_VALUE, \
                INSTRUCTION_ALPHA)

### FailedEdgeAttempt

const FAILED_EDGE_ATTEMPT_SATURATION := 0.6
const FAILED_EDGE_ATTEMPT_VALUE := 0.9
const FAILED_EDGE_ATTEMPT_OPACITY := 0.8
var FAILED_EDGE_ATTEMPT_COLOR_PARAMS := HsvColorParams.new( \
        COLLISION_HUE, \
        FAILED_EDGE_ATTEMPT_SATURATION, \
        FAILED_EDGE_ATTEMPT_VALUE, \
        FAILED_EDGE_ATTEMPT_OPACITY)

const FAILED_EDGE_ATTEMPT_DASH_LENGTH := 6.0
const FAILED_EDGE_ATTEMPT_DASH_GAP := 8.0
const FAILED_EDGE_ATTEMPT_DASH_STROKE_WIDTH := 2.0
const FAILED_EDGE_ATTEMPT_X_WIDTH := 20.0
const FAILED_EDGE_ATTEMPT_X_HEIGHT := 28.0

const FAILED_EDGE_ATTEMPT_INCLUDES_SURFACES := false

### EdgeStepCalcResultMetadata

const STEP_HUE_START := ORIGIN_SURFACE_HUE
const STEP_HUE_END := DESTINATION_SURFACE_HUE
const STEP_SATURATION := 0.6
const STEP_VALUE := 0.9
const STEP_OPACITY_FAINT := 0.2
const STEP_OPACITY_STRONG := 0.9

const STEP_TRAJECTORY_STROKE_WIDTH_FAINT := 1.0
const STEP_TRAJECTORY_STROKE_WIDTH_STRONG := 3.0
const STEP_TRAJECTORY_DASH_LENGTH := 2.0
const STEP_TRAJECTORY_DASH_GAP := 8.0

const INVALID_EDGE_DASH_LENGTH := FAILED_EDGE_ATTEMPT_DASH_LENGTH
const INVALID_EDGE_DASH_GAP := FAILED_EDGE_ATTEMPT_DASH_GAP
const INVALID_EDGE_DASH_STROKE_WIDTH := FAILED_EDGE_ATTEMPT_DASH_STROKE_WIDTH
const INVALID_EDGE_X_WIDTH := FAILED_EDGE_ATTEMPT_X_WIDTH
const INVALID_EDGE_X_HEIGHT := FAILED_EDGE_ATTEMPT_X_HEIGHT
var INVALID_EDGE_COLOR_PARAMS := HsvColorParams.new( \
        COLLISION_HUE, \
        STEP_SATURATION, \
        STEP_VALUE, \
        STEP_OPACITY_STRONG)

const WAYPOINT_RADIUS := 6.0
const WAYPOINT_STROKE_WIDTH_FAINT := WAYPOINT_RADIUS / 3.0
const WAYPOINT_STROKE_WIDTH_STRONG := WAYPOINT_STROKE_WIDTH_FAINT * 2.0
const PREVIOUS_OUT_OF_REACH_WAYPOINT_WIDTH_HEIGHT := 15.0
const VALID_WAYPOINT_WIDTH := 16.0
const VALID_WAYPOINT_STROKE_WIDTH := 2.0
const INVALID_WAYPOINT_WIDTH := 12.0
const INVALID_WAYPOINT_HEIGHT := 16.0
const INVALID_WAYPOINT_STROKE_WIDTH := 2.0

const COLLISION_HUE := 0.0
const COLLISION_FRAME_START_HUE := STEP_HUE_START
const COLLISION_FRAME_END_HUE := STEP_HUE_END
const COLLISION_FRAME_PREVIOUS_HUE := 0.91
const COLLISION_X_WIDTH_HEIGHT := Vector2(16.0, 16.0)
const COLLISION_X_STROKE_WIDTH_FAINT := 2.0
const COLLISION_X_STROKE_WIDTH_STRONG := 4.0
const COLLISION_PLAYER_BOUNDARY_STROKE_WIDTH_FAINT := 1.0
const COLLISION_PLAYER_BOUNDARY_STROKE_WIDTH_STRONG := 2.0
const COLLISION_PLAYER_BOUNDARY_CENTER_RADIUS := 3.0
const COLLISION_BOUNDING_BOX_STROKE_WIDTH := 1.0
const COLLISION_MARGIN_STROKE_WIDTH := 1.0
const COLLISION_MARGIN_DASH_LENGTH := 6.0
const COLLISION_MARGIN_DASH_GAP := 10.0
const COLLISION_INTERSECTION_POINT_RADIUS := 2.0
var COLLISION_COLOR_FAINT := Color.from_hsv( \
        COLLISION_HUE, \
        STEP_SATURATION, \
        STEP_VALUE, \
        STEP_OPACITY_FAINT)
var COLLISION_COLOR_STRONG := Color.from_hsv( \
        COLLISION_HUE, \
        STEP_SATURATION, \
        STEP_VALUE, \
        STEP_OPACITY_STRONG)
var COLLISION_FRAME_START_COLOR := Color.from_hsv( \
        COLLISION_FRAME_START_HUE, \
        0.7, \
        0.9, \
        0.5)
var COLLISION_FRAME_END_COLOR := Color.from_hsv( \
        COLLISION_FRAME_END_HUE, \
        0.7, \
        0.9, \
        0.5)
var COLLISION_FRAME_PREVIOUS_COLOR := Color.from_hsv( \
        COLLISION_FRAME_PREVIOUS_HUE, \
        0.7, \
        0.9, \
        0.2)
var COLLISION_INTERSECTION_POINT_COLOR := Color.from_hsv( \
        0.8, \
        0.8, \
        0.9, \
        0.7)
var COLLISION_JUST_BEFORE_COLLISION_COLOR := Color.from_hsv( \
        COLLISION_HUE, \
        0.5, \
        0.6, \
        0.2)
var COLLISION_AT_COLLISION_COLOR := Color.from_hsv( \
        COLLISION_HUE, \
        0.7, \
        0.9, \
        0.5)

const STEP_LABEL_SCALE := Vector2(2.0, 2.0)
const PREVIOUS_OUT_OF_REACH_WAYPOINT_LABEL_SCALE := Vector2(1.4, 1.4)
const LABEL_OFFSET := Vector2(15.0, -10.0)

### JumpLandPositions

const JUMP_LAND_POSITIONS_HUE_MIN := 0.0
const JUMP_LAND_POSITIONS_HUE_MAX := 1.0
const JUMP_LAND_POSITIONS_SATURATION := 0.7
const JUMP_LAND_POSITIONS_VALUE := 0.7
const JUMP_LAND_POSITIONS_ALPHA := 0.7

const JUMP_LAND_POSITIONS_RADIUS := 6.0
const JUMP_LAND_POSITIONS_DASH_LENGTH := 4.0
const JUMP_LAND_POSITIONS_DASH_GAP := 4.0
const JUMP_LAND_POSITIONS_DASH_STROKE_WIDTH := 1.0

var JUMP_LAND_POSITIONS_COLOR_PARAMS := \
        ColorParamsFactory.create_hsv_range_color_params_with_constant_sva( \
                JUMP_LAND_POSITIONS_HUE_MIN, \
                JUMP_LAND_POSITIONS_HUE_MAX, \
                JUMP_LAND_POSITIONS_SATURATION, \
                JUMP_LAND_POSITIONS_VALUE, \
                JUMP_LAND_POSITIONS_ALPHA)

var DEFAULT_JUMP_LAND_POSITIONS_HUE := DEFAULT_EDGE_CONTINUOUS_TRAJECTORY_HUE
var DEFAULT_JUMP_LAND_POSITIONS_COLOR_PARAMS := \
        HsvColorParams.new( \
                DEFAULT_JUMP_LAND_POSITIONS_HUE, \
                JUMP_LAND_POSITIONS_SATURATION, \
                JUMP_LAND_POSITIONS_VALUE, \
                JUMP_LAND_POSITIONS_ALPHA)

### Navigator

var NAVIGATOR_CURRENT_PATH_COLOR := Colors.opacify( \
        Colors.PURPLE, \
        Colors.ALPHA_FAINT)
var NAVIGATOR_PREVIOUS_PATH_COLOR := Colors.opacify( \
        Colors.PURPLE, \
        Colors.ALPHA_XFAINT)
var NAVIGATOR_DESTINATION_INDICATOR_FILL_COLOR := Colors.opacify( \
        Colors.PURPLE, \
        Colors.ALPHA_XXFAINT)
var NAVIGATOR_DESTINATION_INDICATOR_STROKE_COLOR := Colors.opacify( \
        Colors.PURPLE, \
        Colors.ALPHA_SLIGHTLY_FAINT)
var NAVIGATOR_ORIGIN_INDICATOR_FILL_COLOR := \
        NAVIGATOR_DESTINATION_INDICATOR_FILL_COLOR
var NAVIGATOR_ORIGIN_INDICATOR_STROKE_COLOR := \
        NAVIGATOR_DESTINATION_INDICATOR_STROKE_COLOR

const NAVIGATOR_ORIGIN_INDICATOR_RADIUS := 16.0
const NAVIGATOR_DESTINATIAN_INDICATOR_LENGTH := 64.0
const NAVIGATOR_DESTINATION_INDICATOR_RADIUS := 16.0

const NAVIGATOR_INDICATOR_STROKE_WIDTH := 1.0

### Polyline

const DEFAULT_POLYLINE_HUE := DEFAULT_SURFACE_HUE
const DEFAULT_POLYLINE_SATURATION := 0.6
const DEFAULT_POLYLINE_VALUE := 0.9
const DEFAULT_POLYLINE_OPACITY := 0.8

var DEFAULT_POLYLINE_COLOR_PARAMS := HsvColorParams.new( \
        DEFAULT_POLYLINE_HUE, \
        DEFAULT_POLYLINE_SATURATION, \
        DEFAULT_POLYLINE_VALUE, \
        DEFAULT_POLYLINE_OPACITY)
var FALL_RANGE_POLYGON_COLOR_PARAMS := HsvColorParams.new( \
        DESTINATION_SURFACE_HUE, \
        DEFAULT_POLYLINE_SATURATION, \
        DEFAULT_POLYLINE_VALUE, \
        DEFAULT_POLYLINE_OPACITY)

const DEFAULT_POLYLINE_DASH_LENGTH := 6.0
const DEFAULT_POLYLINE_DASH_GAP := 8.0
const DEFAULT_POLYLINE_STROKE_WIDTH := 1.0

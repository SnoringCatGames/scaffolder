extends Node

const LEVEL_RESOURCE_PATHS := [
    "res://levels/level_1.tscn",
    "res://levels/level_2.tscn",
    "res://levels/level_3.tscn",
    "res://levels/level_4.tscn",
    "res://levels/level_5.tscn",
    "res://levels/level_6.tscn",
]

const TEST_RUNNER_SCENE_RESOURCE_PATH := "res://test/test_runner.tscn"

const UTILITY_PANEL_RESOURCE_PATH := \
        "res://framework/controls/panels/utility_panel.tscn"
const WELCOME_PANEL_RESOURCE_PATH := \
        "res://framework/controls/panels/welcome_panel.tscn"

const IN_DEBUG_MODE := true
var USES_THREADS := false and OS.can_use_threads()
const IN_TEST_MODE := false
const UTILITY_PANEL_STARTS_OPEN := true

#const STARTING_LEVEL_RESOURCE_PATH := \
#        "res://test/data/test_level_long_rise.tscn"
#const STARTING_LEVEL_RESOURCE_PATH := \
#        "res://test/data/test_level_long_fall.tscn"
#const STARTING_LEVEL_RESOURCE_PATH := \
#        "res://test/data/test_level_far_distance.tscn"
#const STARTING_LEVEL_RESOURCE_PATH := \
#        "res://levels/level_3.tscn"
#const STARTING_LEVEL_RESOURCE_PATH := \
#        "res://levels/level_4.tscn"
#const STARTING_LEVEL_RESOURCE_PATH := \
#        "res://levels/level_5.tscn"
const STARTING_LEVEL_RESOURCE_PATH := \
        "res://levels/level_6.tscn"

const DEFAULT_PLAYER_NAME := "cat"
#const DEFAULT_PLAYER_NAME := "test"

var THREAD_COUNT := \
        4 if \
        USES_THREADS else \
        1

const DEBUG_PARAMS := \
        {} if \
        !IN_DEBUG_MODE else \
        {
    is_inspector_enabled = true,
    limit_parsing = {
        player_name = "cat",
#        
#        edge = {
#            origin = {
#                surface_side = SurfaceSide.FLOOR,
#            },
#            destination = {
#                surface_side = SurfaceSide.FLOOR,
#            },
#        },
#        
#        edge_type = EdgeType.CLIMB_OVER_WALL_TO_FLOOR_EDGE,
#        edge_type = EdgeType.FALL_FROM_WALL_EDGE,
#        edge_type = EdgeType.FALL_FROM_FLOOR_EDGE,
#        edge_type = EdgeType.JUMP_INTER_SURFACE_EDGE,
#        edge_type = EdgeType.CLIMB_DOWN_WALL_TO_FLOOR_EDGE,
#        edge_type = EdgeType.WALK_TO_ASCEND_WALL_FROM_FLOOR_EDGE,
#        
#        edge = {
#            origin = {
#                surface_side = SurfaceSide.FLOOR,
#                surface_start_vertex = Vector2(-448, 256),
#                position = Vector2(128, 256),
#                epsilon = 10,
#            },
#            destination = {
#                surface_side = SurfaceSide.FLOOR,
#                surface_start_vertex = Vector2(-64, 64),
#                position = Vector2(64, 64),
#                epsilon = 10,
#            },
#        },
#        
#        edge = {
#            origin = {
#                surface_side = SurfaceSide.LEFT_WALL,
#                surface_start_vertex = Vector2(-960, -640),
#                position = Vector2(-960, -448),
#                epsilon = 10,
#            },
#            destination = {
#                surface_side = SurfaceSide.FLOOR,
#                surface_start_vertex = Vector2(-640, -128),
#                position = Vector2(-640, -128),
#                epsilon = 10,
#            },
#        },
    },
    extra_annotations = {},
}
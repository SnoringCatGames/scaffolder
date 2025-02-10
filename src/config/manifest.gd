class_name ScaffolderManifest
extends Resource


@export var god_mode := false

@export var dev_mode := true
@export var skip_main_menu_in_dev_mode := false

@export var pauses_on_focus_out := true

@export var show_hud := true

@export var main_theme: Theme

@export var dev_mode_level: PackedScene
@export var main_level: PackedScene

@export var hud_scene: PackedScene = preload("res://addons/scaffolder2/src/ui/hud/hud.tscn")

@export var screens: Dictionary[String, PackedScene] = {
    "credits" = preload("res://addons/scaffolder2/src/ui/screens/credits/credits_screen.tscn"),
    "game_over" = preload("res://addons/scaffolder2/src/ui/screens/game_over/game_over_screen.tscn"),
    "game" = preload("res://addons/scaffolder2/src/ui/screens/game/game_screen.tscn"),
    "main_menu" = preload("res://addons/scaffolder2/src/ui/screens/main_menu/main_menu_screen.tscn"),
    "pause" = preload("res://addons/scaffolder2/src/ui/screens/pause/pause_screen.tscn"),
    "settings" = preload("res://addons/scaffolder2/src/ui/screens/settings/settings_screen.tscn"),
}

@export var canvas_layers: Array[ScaffolderCanvasLayerConfig] = [
    ScaffolderCanvasLayerConfig.new("top", Node.ProcessMode.PROCESS_MODE_ALWAYS),
    ScaffolderCanvasLayerConfig.new("notifications", Node.ProcessMode.PROCESS_MODE_ALWAYS),
    ScaffolderCanvasLayerConfig.new("super_hud", Node.ProcessMode.PROCESS_MODE_ALWAYS),
    ScaffolderCanvasLayerConfig.new("screens", Node.ProcessMode.PROCESS_MODE_ALWAYS),
    ScaffolderCanvasLayerConfig.new("hud", Node.ProcessMode.PROCESS_MODE_PAUSABLE),
    ScaffolderCanvasLayerConfig.new("annotations", Node.ProcessMode.PROCESS_MODE_PAUSABLE),
    ScaffolderCanvasLayerConfig.new("game", Node.ProcessMode.PROCESS_MODE_PAUSABLE),
]

# FIXME: Move the required hard-coded values to a separate const, and assign that const here.
#      - Then, in on-change or on-load, ensure that every required hard-coded value is present and wasn't removed by the user.
#      - Do the same for canvas_layers.
#      - Do the same for screens.
@export var sfxs: Dictionary[String, AudioStream] = {
    game_load = preload("res://addons/scaffolder2/assets/sfx/game_load.tres"),
    level_start = preload("res://addons/scaffolder2/assets/sfx/level_start.tres"),
    level_success = preload("res://addons/scaffolder2/assets/sfx/level_success.tres"),
    level_failure = preload("res://addons/scaffolder2/assets/sfx/level_failure.tres"),
    pause = preload("res://addons/scaffolder2/assets/sfx/pause.tres"),
    unpause = preload("res://addons/scaffolder2/assets/sfx/unpause.tres"),
    widget_click = preload("res://addons/scaffolder2/assets/sfx/menu_click.tres"),
}

# FIXME: Incorporate Godot's new built-in Time time-scale into ScaffolderTime.
@export_range(0.5, 5.0, 0.1) var debug_time_scale := 1.0

@export var render_debug_annotations := false

@export_group("Logging")
# FIXME: Use these.
@export var log_surfacer_events := false
@export var log_surfacer_events_verbose := false
@export var log_scaffolder_events := false
@export var log_scaffolder_events_verbose := false
@export_group("")

@export_group("Advanced")
@export var super_hud_scene: PackedScene = preload("res://addons/scaffolder2/src/ui/hud/super_hud.tscn")
@export var shell_scene: PackedScene = preload("res://addons/scaffolder2/src/core/scaffolder_shell.tscn")
@export_group("")

var initial_screen: String:
    get:
        return (
            "game"
            if dev_mode and skip_main_menu_in_dev_mode
            else "main_menu"
        )


func get_screen_scene(name: String) -> PackedScene:
    return screens[name]


func has_screen_scene(name: String) -> bool:
    return screens.has(name)

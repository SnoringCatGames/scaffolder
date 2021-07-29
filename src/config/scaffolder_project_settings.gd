tool
class_name ScaffolderProjectSettings
extends Node
# This global singleton automatically configures Godot's "Project Settings",
# General and Input Map, according to Scaffolder's requirements.


const DEFAULT_INPUT_MAP := {
    "screenshot": [
        {key_scancode = KEY_L},
        {key_scancode = KEY_P},
    ],
    "sc_back": [
        {mouse_button_index = BUTTON_XBUTTON1},
    ],
    "zoom_in": [
        {mouse_button_index = BUTTON_WHEEL_UP},
        {key_scancode = KEY_EQUAL, control = true},
        {key_scancode = KEY_BRACERIGHT, control = true},
    ],
    "zoom_out": [
        {mouse_button_index = BUTTON_WHEEL_DOWN},
        {key_scancode = KEY_MINUS, control = true},
        {key_scancode = KEY_BRACELEFT, control = true},
    ],
    "pan_up": [
        {key_scancode = KEY_UP, control = true},
    ],
    "pan_down": [
        {key_scancode = KEY_DOWN, control = true},
    ],
    "pan_left": [
        {key_scancode = KEY_LEFT, control = true},
    ],
    "pan_right": [
        {key_scancode = KEY_RIGHT, control = true},
    ],
    "jump": [
        {key_scancode = KEY_SPACE},
        {key_scancode = KEY_Q},
        {key_scancode = KEY_X},
    ],
    "move_up": [
        {key_scancode = KEY_UP},
        {key_scancode = KEY_W},
        {key_scancode = KEY_COMMA},
    ],
    "move_down": [
        {key_scancode = KEY_DOWN},
        {key_scancode = KEY_S},
        {key_scancode = KEY_O},
    ],
    "move_left": [
        {key_scancode = KEY_LEFT},
        {key_scancode = KEY_A},
    ],
    "move_right": [
        {key_scancode = KEY_RIGHT},
        {key_scancode = KEY_D},
        {key_scancode = KEY_E},
    ],
    "dash": [
        {key_scancode = KEY_SEMICOLON},
        {key_scancode = KEY_APOSTROPHE},
        {key_scancode = KEY_Z},
    ],
    "face_left": [],
    "face_right": [],
    "grab_wall": [],
}


func _override_project_settings() -> void:
    if !Sc.metadata.overrides_project_settings:
        return
    
    _validate_preexisting_project_settings()
    
    var framebuffer_2d_without_sampling := 1
    var orientation_sensor := "sensor"
    var window_stretch_mode_disabled := "disabled"
    var window_stretch_aspect_expanded := "expand"
    var physics_2d_thread_model_single_unsafe := 0
    var physics_2d_thread_model_multi_threaded := 2
    
    var project_settings_overrides := {
        "application/config/name": Sc.metadata.app_name,
        "application/config/auto_accept_quit": false,
        "application/config/quit_on_go_back": false,
        "application/boot_splash/bg_color": Sc.colors.boot_splash_background,
        "rendering/environment/default_clear_color": Sc.colors.background,
        "rendering/2d/snapping/use_gpu_pixel_snap": true,
        "rendering/quality/intended_usage/framebuffer_allocation":
                framebuffer_2d_without_sampling,
        "rendering/quality/intended_usage/framebuffer_allocation.mobile":
                framebuffer_2d_without_sampling,
        "display/window/handheld/orientation": orientation_sensor,
        "display/window/stretch/mode": window_stretch_mode_disabled,
        "display/window/stretch/aspect": window_stretch_aspect_expanded,
        "logging/file_logging/enable_file_logging": true,
        "input_devices/pointing/emulate_touch_from_mouse": true,
        "input_devices/pointing/emulate_mouse_from_touch": true,
        "input_devices/pointing/ios/touch_delay": 0.005,
        "physics/common/physics_fps": Time.PHYSICS_FPS,
        "layer_names/2d_physics/layer_1": "surfaces_tilemaps",
        "layer_names/2d_render/layer_2": "player",
        # TODO: Figure out if this actually matters...
#        "physics/2d/thread_model": physics_2d_thread_model_multi_threaded,
    }
    for key in project_settings_overrides:
        ProjectSettings.set_setting(key, project_settings_overrides[key])


func _validate_preexisting_project_settings() -> void:
    # These are settings that can't be programmatically saved to project.godot.
    assert(ProjectSettings.get_setting("application/config/name") != "")


func _override_input_map(input_map_overrides: Dictionary) -> void:
    if !Sc.metadata.overrides_input_map:
        return
    
    var input_map = DEFAULT_INPUT_MAP
    Sc.utils.merge(input_map, input_map_overrides)
    
    for action_name in input_map:
        if !InputMap.has_action(action_name):
            InputMap.add_action(action_name)
        for event_config in input_map[action_name]:
            var event: InputEventWithModifiers
            if event_config.has("mouse_button_index"):
                event = InputEventMouseButton.new()
                event.button_index = event_config.mouse_button_index
            elif event_config.has("key_scancode"):
                event = InputEventKey.new()
                event.scancode = event_config.key_scancode
            else:
                Sc.logger.error()
                continue
            
            if event_config.has("control"):
                event.control = event_config.control
            
            if !InputMap.action_has_event(action_name, event):
                InputMap.action_add_event(action_name, event)

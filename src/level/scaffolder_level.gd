tool
class_name ScaffolderLevel, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_level.png"
extends Node2D


signal active_player_character_changed()

const MIN_CONTROLS_DISPLAY_TIME := 0.5

export var level_id := "" setget _set_level_id

# Dictionary<String, Array<ScaffolderSpawnPosition>>
var spawn_positions := {}

# Array<ScaffolderSpawnPosition>
var exclusive_spawn_positions := []

# Dictionary<String, Array<ScaffolderCharacter>>
var characters: Dictionary

var active_player_character: ScaffolderCharacter \
        setget _set_active_player_character,_get_active_player_character
var _active_player_character: ScaffolderCharacter
var _previous_active_player_character: ScaffolderCharacter

var level_bounds: Rect2
var camera_bounds: Rect2
var character_bounds: Rect2

var touch_listener: LevelTouchListener
var level_control_press_controller: LevelControlPressController
var camera: ScaffolderCamera
var _default_camera: ScaffolderCamera

var session: ScaffolderLevelSession

var _is_ready := false
var _configuration_warning := ""


func _init() -> void:
    self.touch_listener = LevelTouchListener.new()
    Sc.canvas_layers.layers.top.add_child(touch_listener)
    self.level_control_press_controller = LevelControlPressController.new()
    Sc.canvas_layers.layers.top.add_child(level_control_press_controller)
    self.connect(
            "active_player_character_changed",
            self,
            "_on_active_player_character_changed")


func _enter_tree() -> void:
    session = Sc.levels.session
    _update_session_in_editor()


func _ready() -> void:
    _is_ready = true
    _establish_boundaries()
    _update_editor_configuration()
    Sc.device.connect(
            "display_resized",
            self,
            "_on_resized")
    _on_resized()


func _load() -> void:
    _create_hud()


func _start() -> void:
    Sc.audio.play_music(get_music_name())
    Sc.save_state.set_level_total_plays(
            Sc.levels.session.id,
            Sc.save_state.get_level_total_plays(Sc.levels.session.id) + 1)
    Sc.analytics.event(
            "level",
            "start",
            Sc.levels.get_level_version_string(Sc.levels.session.id))
    
    if Sc.gui.hud_manifest.is_hud_visible_by_default:
        Sc.gui.hud.visible = true
    
    var includes_default_player_character := _add_default_player_character()
    _add_npcs()
    
    _set_default_camera()
    
    call_deferred("_on_started")


func _on_started() -> void:
    var start_time_scaled: float = Sc.time.get_scaled_play_time()
    var start_time_unscaled: float = Sc.time.get_play_time()
    Sc.levels.session._level_start_play_time_scaled = start_time_scaled
    Sc.levels.session._level_start_play_time_unscaled = start_time_unscaled
    Sc.logger.print("Level started:               %8.3f" % start_time_unscaled)


func _add_default_player_character() -> bool:
    if Sc.characters.default_player_character_name == "":
        # There is no player character configured.
        return false
    
    var spawn_position := _get_default_player_character_spawn_position()
    
    # TODO: Update the rest of the app to support running with no player
    #       character.
#    if !exclusive_spawn_positions.empty() and \
#            !spawn_position.include_exclusively:
#        # We are exclusively including another character.
#        return
    
    # Add the player character.
    add_character(
            Sc.characters.default_player_character_name,
            spawn_position,
            true,
            true)
    
    return true


func _get_default_player_character_spawn_position() -> ScaffolderSpawnPosition:
    # If no spawn position was defined for the default character, then start
    # them at 0,0. 
    if !spawn_positions.has(Sc.characters.default_player_character_name):
        var spawn_position := ScaffolderSpawnPosition.new()
        spawn_position.character_name = Sc.characters.default_player_character_name
        spawn_position.position = Vector2.ZERO
        register_spawn_position(
                Sc.characters.default_player_character_name, spawn_position)
    return spawn_positions[Sc.characters.default_player_character_name][0]


func _add_npcs() -> void:
    if Sc.characters.omits_npcs:
        return
    
    # Add npcs at the registered spawn positions.
    for character_name in spawn_positions:
        if character_name == Sc.characters.default_player_character_name:
            continue
        for spawn_position in spawn_positions[character_name]:
            if spawn_position.exclude:
                # We are excluding this character.
                continue
            if !exclusive_spawn_positions.empty() and \
                    !spawn_position.include_exclusively:
                # We are exclusively including another character.
                continue
            add_character(
                    character_name,
                    spawn_position,
                    false,
                    false)


func _create_hud() -> void:
    Sc.gui.hud = Sc.gui.hud_manifest.hud_class.new()
    Sc.gui.hud.visible = false
    Sc.canvas_layers.layers.hud.add_child(Sc.gui.hud)


func _destroy() -> void:
    _hide_welcome_panel()
    Sc.info_panel.close_panel()
    if is_instance_valid(Sc.gui.hud):
        Sc.gui.hud._destroy()
    for character_name in characters:
        for character in characters[character_name]:
            character._destroy()
    _set_active_player_character(null)
    if is_instance_valid(camera):
        camera._destroy()
    if is_instance_valid(touch_listener):
        touch_listener._destroy()
    if is_instance_valid(level_control_press_controller):
        level_control_press_controller._destroy()
    Sc.level = null
    Sc.levels.session._is_destroyed = true
    if Sc.levels.session.is_restarting:
        Sc.nav.open(
                "loading",
                ScreenTransition.DEFAULT,
                {level_id = Sc.levels.session.id})
    if !is_queued_for_deletion():
        queue_free()


func quit(
        has_finished: bool,
        immediately: bool) -> void:
    Sc.levels.session._level_end_play_time_unscaled = Sc.time.get_play_time()
    Sc.audio.stop_music()
    Sc.levels.session._update_for_level_end(has_finished)
    _record_suggested_next_level()
    if immediately:
        if !Sc.levels.session.is_restarting:
            Sc.nav.open("game_over", ScreenTransition.FANCY)
        _destroy()
    else:
        var sound_name: String = \
                Sc.audio_manifest.level_end_sound_win if \
                has_finished else \
                Sc.audio_manifest.level_end_sound_lose
        Sc.audio.get_sound_player(sound_name) \
                .connect(
                        "finished",
                        self,
                        "_on_level_quit_sound_finished",
                        [has_finished])
        Sc.audio.play_sound(sound_name)


func add_character(
        name_or_path_or_packed_scene,
        position_or_spawn_position,
        can_be_player_character: bool,
        is_active_player_character: bool,
        is_attached := true) -> ScaffolderCharacter:
    if name_or_path_or_packed_scene is String and \
            !name_or_path_or_packed_scene.begins_with("res://"):
        name_or_path_or_packed_scene = \
                Sc.characters.character_scenes[name_or_path_or_packed_scene]
    
    var position: Vector2 = \
            position_or_spawn_position if \
            position_or_spawn_position is Vector2 else \
            position_or_spawn_position.position
    
    var character: ScaffolderCharacter = Sc.utils.add_scene(
            null,
            name_or_path_or_packed_scene,
            false,
            true)
    character.position = position
    
    _update_character_spawn_state(character, position_or_spawn_position)
    
    if !characters.has(character.character_name):
        characters[character.character_name] = []
    characters[character.character_name].push_back(character)
    
    if is_attached:
        add_child(character)
    
    character.set_can_be_player_character(can_be_player_character)
    character.set_is_player_control_active(is_active_player_character)
    if is_active_player_character:
        _set_active_player_character(character)
    
    return character


func _update_character_spawn_state(
        character: ScaffolderCharacter,
        position_or_spawn_position) -> void:
    pass


func remove_character(character: ScaffolderCharacter) -> void:
    characters[character.character_name].erase(character)
    character._destroy()


func register_spawn_position(
        character_name: String,
        spawn_position: ScaffolderSpawnPosition) -> void:
    assert(character_name != "")
    if !spawn_positions.has(character_name):
        spawn_positions[character_name] = []
    var positions_for_character: Array = spawn_positions[character_name]
    positions_for_character.push_back(spawn_position)
    
    if spawn_position.include_exclusively:
        exclusive_spawn_positions.push_back(spawn_position)


func swap_camera(
        camera_or_class,
        matches_previous_camera_pan_and_zoom: bool,
        destroys_previous_camera := false) -> void:
    var previous_camera := camera
    var previous_class: Script = \
            previous_camera.get_script() if \
            is_instance_valid(previous_camera) else \
            null
    var next_class: Script = \
            camera_or_class if \
            camera_or_class is Script else \
            camera_or_class.get_script()
    if previous_class == next_class:
        # No change.
        return
    
    var is_next_camera_already_instantiated := \
            camera_or_class is ScaffolderCamera
    var next_camera: ScaffolderCamera = \
            camera_or_class if \
            is_next_camera_already_instantiated else \
            camera_or_class.new()
    if !is_next_camera_already_instantiated:
        add_child(next_camera)
    
    if matches_previous_camera_pan_and_zoom:
        next_camera.match_camera(previous_camera)
    
    next_camera.is_active = true
    previous_camera.is_active = false
    
    if is_instance_valid(previous_camera) and \
            destroys_previous_camera:
        previous_camera._destroy()
        previous_camera.queue_free()


func _update_editor_configuration() -> void:
    if !_is_ready:
        return
    
    if !Sc.utils.check_whether_sub_classes_are_tools(self):
        _set_configuration_warning(
                "Subclasses of ScaffolderLevel must be marked as tool.")
        return
    
    if level_id == "":
        _set_configuration_warning("Level ID must be defined.")
        return
    
    if !Sc.levels._level_configs_by_id.has(level_id):
        _set_configuration_warning(
                "Level ID must match a value configured in your " +
                "LevelConfiguration file.")
        return
    
    if spawn_positions.has(Sc.characters.default_player_character_name) and \
            spawn_positions[Sc.characters.default_player_character_name].size() > 1:
        _set_configuration_warning(
                "There must not be more than one spawn position for the " +
                "default character.")
        return
    
    _set_configuration_warning("")


func _set_configuration_warning(value: String) -> void:
    if !_is_ready:
        return
    _configuration_warning = value
    update_configuration_warning()
    property_list_changed_notify()
    if value != "" and \
            !Engine.editor_hint:
        Sc.logger.error(value)


func _get_configuration_warning() -> String:
    return _configuration_warning


func _record_suggested_next_level() -> void:
    var suggested_next_level_id: String = \
            Sc.levels.calculate_suggested_next_level()
    Sc.save_state.set_setting(
            SaveState.SUGGESTED_NEXT_LEVEL_SETTINGS_KEY,
            suggested_next_level_id)


func restart() -> void:
    Sc.levels.session._is_restarting = true
    quit(false, true)


func _input(event: InputEvent) -> void:
    if Engine.editor_hint:
        return
    
    if !Sc.levels.session.has_initial_input_happened and \
            Sc.gui.is_player_interaction_enabled and \
            Sc.levels.session.level_play_time_unscaled > \
                    MIN_CONTROLS_DISPLAY_TIME and \
            (event is InputEventMouseButton or \
                    event is InputEventScreenTouch or \
                    event is InputEventKey) and \
            Sc.levels.session.has_started:
        _on_initial_input()


func _unhandled_input(event: InputEvent) -> void:
    if Engine.editor_hint:
        return
    
    if event is InputEventMouseButton or \
            event is InputEventScreenTouch:
        # This ensures that pressing arrow keys won't change selections in any
        # overlay UI.
        Sc.utils.release_focus()


func _on_initial_input() -> void:
    Sc.logger.print(
            "_on_initial_input():         %8.3f" % \
            Sc.time.get_play_time())
    Sc.levels.session._has_initial_input_happened = true
    # Close the welcome panel on any mouse or key click event.
    if is_instance_valid(Sc.gui.welcome_panel):
        _hide_welcome_panel()


func _on_resized() -> void:
    if is_instance_valid(camera):
        camera._on_resized()


func pause() -> void:
    if Sc.audio_manifest.pauses_level_music_on_pause:
        Sc.levels.session._pre_pause_music_name = Sc.audio.get_music_name()
        Sc.levels.session._pre_pause_music_position = \
                Sc.audio.get_playback_position()
        if Sc.audio_manifest.pause_menu_music != "":
            Sc.audio.play_music(Sc.audio_manifest.pause_menu_music)
        else:
            Sc.audio.stop_music()
    Sc.nav.open("pause")


func on_unpause() -> void:
    if Sc.audio_manifest.pauses_level_music_on_pause and \
            !session.is_ended:
        Sc.audio.play_music(Sc.levels.session._pre_pause_music_name)
        Sc.audio.seek(Sc.levels.session._pre_pause_music_position)


func _show_welcome_panel() -> void:
    if !Sc.gui.is_welcome_panel_shown or \
            !Sc.gui.does_app_contain_welcome_panel:
        return
    assert(Sc.gui.welcome_panel == null)
    Sc.gui.welcome_panel = Sc.utils.add_scene(
            Sc.canvas_layers.layers.hud,
            Sc.gui.welcome_panel_scene)


func _hide_welcome_panel() -> void:
    if is_instance_valid(Sc.gui.welcome_panel):
        Sc.gui.welcome_panel._destroy()
        Sc.gui.welcome_panel = null


func _on_level_quit_sound_finished(level_finished: bool) -> void:
    var sound_name: String = \
            Sc.audio_manifest.level_end_sound_win if \
            level_finished else \
            Sc.audio_manifest.level_end_sound_lose
    Sc.audio.get_sound_player(sound_name) \
            .disconnect("finished", self, "_on_level_quit_sound_finished")
    var is_rate_app_screen_next: bool = \
            Sc.gui.is_rate_app_shown and \
            _get_is_rate_app_screen_next()
    var next_screen := \
            "rate_app" if \
            is_rate_app_screen_next else \
            "game_over"
    Sc.nav.open(next_screen, ScreenTransition.FANCY)


func get_music_name() -> String:
    return Sc.audio_manifest.default_level_music


func get_slow_motion_music_name() -> String:
    return ""


func _get_is_rate_app_screen_next() -> bool:
    Sc.logger.error(
            "Abstract ScaffolderLevel._get_is_rate_app_screen_next " +
            "is not implemented")
    return false


func _set_default_camera() -> void:
    var camera: ScaffolderCamera = Sc.camera.default_camera_class.new()
    add_child(camera)
    camera.is_active = true
    self._default_camera = camera


func _update_session_in_editor() -> void:
    if !Engine.editor_hint:
        return
    
    Sc.levels.session.reset(level_id)
    
    var tilemaps: Array = Sc.utils.get_children_by_type(self, TileMap)
    Sc.levels.session.config.cell_size = \
            Vector2.INF if \
            tilemaps.empty() else \
            tilemaps[0].cell_size


func _set_level_id(value: String) -> void:
    level_id = value
    if !Engine.editor_hint:
        assert(Sc.levels.session.id == level_id)
    _update_editor_configuration()
    _update_session_in_editor()


func _set_active_player_character(character: ScaffolderCharacter) -> void:
    var previous_active_player_character := _active_player_character
    _active_player_character = character
    
    if previous_active_player_character == _active_player_character:
        # No change.
        return
    
    _previous_active_player_character = previous_active_player_character
    
    if is_instance_valid(previous_active_player_character):
        # De-activate previous character.
        previous_active_player_character \
                .set_is_player_control_active(false, false)
    
    emit_signal("active_player_character_changed")


func _get_active_player_character() -> ScaffolderCharacter:
    return _active_player_character


func _on_active_player_character_changed() -> void:
    pass


func _establish_boundaries() -> void:
    level_bounds = _get_combined_tilemaps_region()
    camera_bounds = level_bounds.grow_individual(
            Sc.levels.default_camera_bounds_level_margin.left,
            Sc.levels.default_camera_bounds_level_margin.top,
            Sc.levels.default_camera_bounds_level_margin.right,
            Sc.levels.default_camera_bounds_level_margin.bottom)
    character_bounds = level_bounds.grow_individual(
            Sc.levels.default_character_bounds_level_margin.left,
            Sc.levels.default_character_bounds_level_margin.top,
            Sc.levels.default_character_bounds_level_margin.right,
            Sc.levels.default_character_bounds_level_margin.bottom)


func _get_combined_tilemaps_region() -> Rect2:
    var tile_maps: Array = Sc.utils.get_children_by_type(self, TileMap, true)
    assert(!tile_maps.empty())
    var tile_map: TileMap = tile_maps[0]
    var tile_map_region: Rect2 = \
            Sc.geometry.get_tilemap_bounds_in_world_coordinates(tile_map)
    for i in range(1, tile_maps.size()):
        tile_map = tile_maps[i]
        tile_map_region = tile_map_region.merge(
                Sc.geometry.get_tilemap_bounds_in_world_coordinates(tile_map))
    return tile_map_region

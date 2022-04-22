tool
class_name ScaffolderLoadingScreen
extends Screen


var level_id := ""
var graph_load_start_time := INF


func _ready() -> void:
    var loading_image_wrapper := $VBoxContainer/LoadingImageWrapper
    loading_image_wrapper.visible = Sc.gui.is_loading_image_shown
    if Sc.gui.is_loading_image_shown:
        var loading_image: ScaffolderConfiguredImage = Sc.utils.add_scene(
                loading_image_wrapper,
                Sc.gui.loading_image_scene,
                true,
                true, \
                0)
        loading_image.original_scale = Sc.gui.loading_image_scale
    
    $VBoxContainer.rect_min_size.x = Sc.gui.screen_body_width
    
    _on_resized()


func set_params(params) -> void:
    .set_params(params)
    
    assert(params != null)
    assert(params.has("level_id"))
    level_id = params.level_id


func get_is_nav_bar_shown() -> bool:
    return true


func _on_transition_in_ended(previous_screen: Screen) -> void:
    ._on_transition_in_ended(previous_screen)
    if Sc.device.get_is_browser_app():
        Sc.audio.stop_music()
    Sc.time.set_timeout(self, "_load_level", 0.05)


func _load_level() -> void:
    Sc.levels.session.reset(level_id)
    
    Sc.save_state.set_last_level_played(level_id)
    
    var level: ScaffolderLevel = Sc.utils.add_scene(
            null,
            Sc.levels.get_level_config(level_id).scene_path,
            false,
            true)
    
    Sc.level = level
    Sc.nav.screens["game"].add_level(Sc.level)
    Sc.level._load()
    
    Sc.nav.open("game", ScreenTransition.FANCY)

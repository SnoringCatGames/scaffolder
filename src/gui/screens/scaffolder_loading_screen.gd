class_name ScaffolderLoadingScreen
extends Screen


var level_id := ""
var graph_load_start_time := INF


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    var loading_image_wrapper := $VBoxContainer/LoadingImageWrapper
    loading_image_wrapper.visible = Gs.gui.is_loading_image_shown
    if Gs.gui.is_loading_image_shown:
        var loading_image: ScaffolderConfiguredImage = Gs.utils.add_scene(
                loading_image_wrapper,
                Gs.gui.loading_image_scene,
                true,
                true, \
                0)
        loading_image.original_scale = Gs.gui.loading_image_scale
    
    $VBoxContainer.rect_min_size.x = Gs.gui.screen_body_width
    
    _on_resized()


func set_params(params) -> void:
    .set_params(params)
    
    assert(params != null)
    assert(params.has("level_id"))
    level_id = params.level_id


func get_is_nav_bar_shown() -> bool:
    return true


func _on_activated(previous_screen: Screen) -> void:
    ._on_activated(previous_screen)
    if Gs.device.get_is_browser_app():
        Gs.audio.stop_music()
    Gs.time.set_timeout(funcref(self, "_load_level"), 0.05)


func _load_level() -> void:
    Gs.level_session.reset(level_id)
    
    Gs.save_state.set_last_level_played(level_id)
    
    Gs.utils.add_scene(
            null,
            Gs.level_config.get_level_config(level_id).scene_path,
            false,
            true)
    
    Gs.nav.screens["game"].add_level(Gs.level)
    
    Gs.level._load()
    
    Gs.nav.open("game", ScreenTransition.FANCY)
    
    Gs.time.set_timeout( \
            funcref(Gs.level, "_start"), \
            Gs.nav.transition_handler._overlay_mask_transition.duration / 2.0)

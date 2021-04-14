class_name GameScreen
extends Screen

const NAME := "game"
const LAYER_NAME := "game_screen"
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := false

func _init().(
        NAME,
        LAYER_NAME,
        AUTO_ADAPTS_GUI_SCALE,
        INCLUDES_STANDARD_HIERARCHY \
        ) -> void:
    pass

func _enter_tree() -> void:
    move_canvas_layer_to_game_viewport("annotation")
    
    var loading_image_wrapper := \
            $PanelContainer/LoadProgressPanel/VBoxContainer/LoadingImageWrapper
    
    loading_image_wrapper.visible = Gs.is_loading_image_shown
    
    if Gs.is_loading_image_shown:
        var loading_image := Gs.utils.add_scene(
                loading_image_wrapper,
                Gs.loading_image_scene_path,
                true,
                true, \
                0)
        loading_image.set_base_scale(0.5)
    
    _on_resized()

func move_canvas_layer_to_game_viewport(name: String) -> void:
    var layer: CanvasLayer = Gs.canvas_layers.layers[name]
    layer.get_parent().remove_child(layer)
    $PanelContainer/ViewportContainer/Viewport.add_child(layer)

func _process(_delta_sec: float) -> void:
    if !is_instance_valid(Gs.level):
        return
    
    # Transform the annotation layer to follow the camera within the
    # game-screen viewport.
    Gs.canvas_layers.layers.annotation.transform = \
            Gs.level.get_canvas_transform()

func _on_resized() -> void:
    ._on_resized()
    _update_viewport_region_helper()
    
    # TODO: This hack seems to be needed in order for the viewport to actually
    #       update its dimensions correctly.
    Gs.time.set_timeout(funcref(self, "_update_viewport_region_helper"), 1.0)

func _on_activated(previous_screen_name: String) -> void:
    ._on_activated(previous_screen_name)
    if is_instance_valid(Gs.level):
        Gs.level.on_unpause()

func _update_viewport_region_helper() -> void:
    var viewport_size := get_viewport().size
    var game_area_position := \
            (viewport_size - Gs.game_area_region.size) * 0.5
    
    $PanelContainer.rect_size = viewport_size
    $PanelContainer/ViewportContainer.rect_position = game_area_position
    $PanelContainer/ViewportContainer/Viewport.size = \
            Gs.game_area_region.size
    
    call_deferred("_fix_viewport_dimensions_hack")
    Gs.time.set_timeout(funcref(self, "_fix_viewport_dimensions_hack"), 0.4)

func _fix_viewport_dimensions_hack() -> void:
    # TODO: This hack seems to be needed in order for the viewport to actually
    #       update its dimensions correctly.
    self.visible = false
    call_deferred("set_visible", true)

func start_level(level_id: String) -> void:
    if is_instance_valid(Gs.level):
        return
    
    $PanelContainer/LoadProgressPanel.visible = true
    $PanelContainer/LoadProgressPanel/VBoxContainer/ProgressBar.value = 0.0
    $PanelContainer/LoadProgressPanel/VBoxContainer/Label1.text = ""
    $PanelContainer/LoadProgressPanel/VBoxContainer/Label2.text = ""
    $PanelContainer/LoadProgressPanel/VBoxContainer/Label3.text = ""
    
    var level := Gs.utils.add_scene(
            null,
            Gs.level_config.get_level_config(level_id).scene_path,
            false,
            true)
    level.id = level_id
    $PanelContainer/ViewportContainer/Viewport.add_child(level)
    level.graph_parser.connect(
            "calculation_started",
            self,
            "_on_calculation_started")
    level.graph_parser.connect(
            "load_started",
            self,
            "_on_load_started")
    level.graph_parser.connect(
            "calculation_progress",
            self,
            "_on_graph_parse_progress")
    level.graph_parser.connect(
            "parse_finished",
            self,
            "_on_graph_parse_finished")
    level.start()

func _on_calculation_started() -> void:
    $PanelContainer/LoadProgressPanel/VBoxContainer/Label1.text = \
            "Calculating platform graphs"

func _on_load_started() -> void:
    $PanelContainer/LoadProgressPanel/VBoxContainer/Label1.text = \
            "Loading platform graphs"

func _on_graph_parse_progress(
        player_index: int,
        player_count: int,
        origin_surface_index: int,
        surface_count: int) -> void:
    var current_graph_calculation_progress_ratio := \
            origin_surface_index / float(surface_count)
    var progress := \
            (player_index + current_graph_calculation_progress_ratio) / \
            float(player_count) * \
            100.0
    
    var player_name: String = Surfacer.player_params.keys()[player_index]
    var label_1 := "Player %s (%s of %s)" % [
        player_name,
        player_index + 1,
        player_count,
    ]
    var label_2 := "Out-bound surface %s of %s" % [
        origin_surface_index,
        surface_count,
    ]
    
    $PanelContainer/LoadProgressPanel/VBoxContainer/ProgressBar.value = \
            progress
    $PanelContainer/LoadProgressPanel/VBoxContainer/Label2.text = label_1
    $PanelContainer/LoadProgressPanel/VBoxContainer/Label3.text = label_2

func _on_graph_parse_finished() -> void:
    Gs.level.graph_parser.disconnect(
            "calculation_started",
            self,
            "_on_calculation_started")
    Gs.level.graph_parser.disconnect(
            "load_started",
            self,
            "_on_load_started")
    Gs.level.graph_parser.disconnect(
            "calculation_progress",
            self,
            "_on_graph_parse_progress")
    Gs.level.graph_parser.disconnect(
            "parse_finished",
            self,
            "_on_graph_parse_finished")
    
    if !Gs.level.graph_parser.is_loaded_from_file:
        Gs.utils.give_button_press_feedback()
    Gs.nav.fade()
    Gs.time.set_timeout( \
            funcref(self, "_close_load_screen"), \
            Gs.nav.fade_transition.duration / 2.0)

func _close_load_screen() -> void:
    $PanelContainer/LoadProgressPanel.visible = false
    if is_instance_valid(Gs.level):
        Gs.level._on_loaded()

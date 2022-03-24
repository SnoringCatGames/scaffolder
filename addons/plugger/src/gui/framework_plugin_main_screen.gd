tool
class_name FrameworkPluginMainScreen, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_panel_container.png"
extends CenterContainer


const _FRAMEWORK_MANIFEST_PANEL_SCENE := preload(
        "res://addons/scaffolder/addons/plugger/src/gui/framework_manifest_panel.tscn")

const _CENTER_PANEL_MARGIN_FOR_RESIZE_FORGIVENESS := 144.0

# Dictionary<int, int>
var _manifest_modes := {}


var _throttled_on_resize: FuncRef = Sc.time.throttle(
        funcref(self, "adjust_size"),
        0.001,
        false)
var _debounced_save_open_rows = Sc.time.debounce(
        funcref(self, "_save_open_rows"),
        3.0,
        false)


func _ready() -> void:
    _initialize_modes()
    
    Sc.connect("initialized", self, "_reset_panels")
    if Sc.is_initialized:
        _reset_panels()
    
    _load_open_rows()
    
    self.connect("resized", _throttled_on_resize, "call_func")
    call_deferred("adjust_size")


func _reset_panels() -> void:
    var container := \
            $VBoxContainer/CenterContainer/ScrollContainer/VBoxContainer
    Sc.utils.clear_children(container)
    for framework in Sc._framework_globals:
        var panel: FrameworkManifestPanel = \
                Sc.utils.add_scene(container, _FRAMEWORK_MANIFEST_PANEL_SCENE)
        panel.set_up(framework.manifest_controller)
        panel.connect(
                "descendant_toggled", _debounced_save_open_rows, "call_func")


func adjust_size() -> void:
    var size: Vector2 = self.rect_size
    size.y -= $VBoxContainer/Label.rect_size.y
    size.y -= $VBoxContainer/Spacer.rect_size.y
    var margin: Vector2 = Pl.scale_dimension(
            _CENTER_PANEL_MARGIN_FOR_RESIZE_FORGIVENESS * Vector2.ONE)
    var scroll_container_size := size - margin
    $VBoxContainer/CenterContainer/ScrollContainer.rect_min_size = \
            scroll_container_size


func _load_open_rows() -> void:
    var open_rows: Dictionary = Sc.json.load_file(
        ScaffolderMetadata.PLUGIN_OPEN_ROWS_PATH,
            true,
            true)
    for open_panel_label in open_rows:
        var panel := _get_panel_with_label(open_panel_label)
        if is_instance_valid(panel):
            panel.is_open = true
            panel.load_open_rows(open_rows[open_panel_label])


func _save_open_rows() -> void:
    Sc.json.save_file(
            _get_open_rows(),
            ScaffolderMetadata.PLUGIN_OPEN_ROWS_PATH,
            true,
            true)


func _get_open_rows() -> Dictionary:
    var open_rows := {}
    var container := \
            $VBoxContainer/CenterContainer/ScrollContainer/VBoxContainer
    for panel in container.get_children():
        if panel.is_open:
            open_rows[panel.manifest_controller.schema.display_name] = \
                    panel.get_open_rows()
    return open_rows


func _get_panel_with_label(label: String) -> FrameworkManifestPanel:
    var container := \
            $VBoxContainer/CenterContainer/ScrollContainer/VBoxContainer
    for panel in container.get_children():
        if panel.manifest_controller.schema.display_name == label:
            return panel
    return null


func _initialize_modes() -> void:
    _populate_mode_option_buttons()
    _load_modes()


func _populate_mode_option_buttons() -> void:
    for mode_type in FrameworkSchemaMode.MODE_TYPES:
        var option_button := _get_option_button(mode_type)
        option_button.clear()
        var type_to_string_map := _get_type_to_string_map(mode_type)
        for type in type_to_string_map:
            var label: String = type_to_string_map[type]
            option_button.add_item(label, type)


func _load_modes() -> void:
    # Load the selected modes from the JSON file.
    _manifest_modes = Sc.json.load_file(
        ScaffolderMetadata.MODES_PATH,
            true,
            true)
    
    # Assign default values for any missing mode selections.
    for mode_type in ScaffolderMetadata.DEFAULT_MODES:
        if !_manifest_modes.has(mode_type):
            _manifest_modes[mode_type] = \
                    ScaffolderMetadata.DEFAULT_MODES[mode_type]
    
    # Set the OptionButton selections.
    for mode_type in FrameworkSchemaMode.MODE_TYPES:
        _set_mode(mode_type, _manifest_modes[mode_type], false)


func _save_modes() -> void:
    Sc.json.save_file(
            _manifest_modes,
            ScaffolderMetadata.MODES_PATH,
            true,
            true)


func _get_option_button(mode_type: int) -> OptionButton:
    var node: Node
    match mode_type:
        FrameworkSchemaMode.RELEASE:
            node = $VBoxContainer/Modes/Release/ReleaseModeButton
        FrameworkSchemaMode.ANNOTATIONS:
            node = $VBoxContainer/Modes/Annotations/AnnotationsModeButton
        FrameworkSchemaMode.UI_SMOOTHNESS:
            node = $VBoxContainer/Modes/UiSmoothness/UiSmoothnessModeButton
        _:
            Sc.logger.error("FrameworkPluginMainScreen._get_option_button")
    return node as OptionButton


func _get_type_to_string_map(mode_type: int) -> Dictionary:
    match mode_type:
        FrameworkSchemaMode.RELEASE:
            return FrameworkSchemaMode.RELEASE_TYPE_TO_STRING
        FrameworkSchemaMode.ANNOTATIONS:
            return FrameworkSchemaMode.ANNOTATIONS_TYPE_TO_STRING
        FrameworkSchemaMode.UI_SMOOTHNESS:
            return FrameworkSchemaMode.UI_SMOOTHNESS_TYPE_TO_STRING
        _:
            Sc.logger.error("FrameworkPluginMainScreen._type_to_index")
            return {}


func _on_ReleaseModeButton_item_selected(index: int) -> void:
    _on_mode_changed(FrameworkSchemaMode.RELEASE)


func _on_AnnotationsModeButton_item_selected(index: int) -> void:
    _on_mode_changed(FrameworkSchemaMode.ANNOTATIONS)


func _on_UiSmoothnessModeButton_item_selected(index: int) -> void:
    _on_mode_changed(FrameworkSchemaMode.UI_SMOOTHNESS)


func _on_mode_changed(mode_type: int) -> void:
    var option_button := _get_option_button(mode_type)
    var mode_value := option_button.get_selected_id()
    _set_mode(mode_type, mode_value, true)


func _set_mode(
        mode_type: int,
        mode_value: int,
        should_save_json: bool) -> void:
    _manifest_modes[mode_type] = mode_value
    
    var option_button := _get_option_button(mode_type)
    var index := option_button.get_item_index(mode_value)
    option_button.select(index)
    
    if should_save_json:
        _save_modes()

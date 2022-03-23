tool
class_name ScaffolderPluginMainScreen, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_panel_container.png"
extends CenterContainer


const _FRAMEWORK_MANIFEST_PANEL_SCENE := preload(
        "res://addons/scaffolder/addons/plugger/src/gui/framework_manifest_panel.tscn")

const _CENTER_PANEL_MARGIN_FOR_RESIZE_FORGIVENESS := 288.0

# Dictionary<int, int>
var _manifest_modes := {}


var _throttled_on_resize: FuncRef = Sc.time.throttle(
        funcref(self, "_adjust_size"),
        0.001,
        false,
        TimeType.APP_PHYSICS)


func _ready() -> void:
    Sc.connect("initialized", self, "_reset_panels")
    if Sc.is_initialized:
        _reset_panels()
    
    _initialize_modes()
    
    self.connect("resized", _throttled_on_resize, "call_func")
    _adjust_size()


func _reset_panels() -> void:
    var container := \
            $VBoxContainer/CenterContainer/ScrollContainer/VBoxContainer
    Sc.utils.clear_children(container)
    for framework in Sc._framework_globals:
        var panel: FrameworkManifestPanel = \
                Sc.utils.add_scene(container, _FRAMEWORK_MANIFEST_PANEL_SCENE)
        panel.set_up(framework.manifest_controller)


func _adjust_size() -> void:
    # FIXME: LEFT OFF HERE: ------------------------------
#    var size: Vector2 = get_parent().rect_size
    var size: Vector2 = self.rect_size
    size.y -= $VBoxContainer/Label.rect_size.y
    size.y -= $VBoxContainer/Spacer.rect_size.y
    var scroll_container_size := \
            size - _CENTER_PANEL_MARGIN_FOR_RESIZE_FORGIVENESS * Vector2.ONE
    $VBoxContainer/CenterContainer/ScrollContainer.rect_min_size = \
            scroll_container_size


func _initialize_modes() -> void:
    _populate_mode_option_buttons()
    _load_modes()


func _populate_mode_option_buttons() -> void:
    for mode_type in FrameworkSchemaMode.MODE_TYPES:
        var option_button := _get_option_button(mode_type)
        var type_to_string_map := _get_type_to_string_map(mode_type)
        for type in type_to_string_map:
            var label: String = type_to_string_map[type]
            option_button.add_item(label, type)


func _load_modes() -> void:
    # Load the selected modes from the JSON file.
    _manifest_modes = Sc.json.load_file(
            ScaffolderSchema.MODES_PATH,
            true,
            true)
    
    # Assign default values for any missing mode selections.
    for mode_type in ScaffolderSchema.default_modes:
        if !_manifest_modes.has(mode_type):
            _manifest_modes[mode_type] = \
                    ScaffolderSchema.default_modes[mode_type]
    
    # Set the OptionButton selections.
    for mode_type in FrameworkSchemaMode.MODE_TYPES:
        var option_button := _get_option_button(mode_type)
        var type: int = _manifest_modes[mode_type]
        var index := option_button.get_item_index(type)
        option_button.select(index)


func _save_modes() -> void:
    Sc.json.save_file(
            _manifest_modes,
            ScaffolderSchema.MODES_PATH,
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
            Sc.logger.error("ScaffolderPluginMainScreen._get_option_button")
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
            Sc.logger.error("ScaffolderPluginMainScreen._type_to_index")
            return {}


func _on_ReleaseModeButton_item_selected(index: int) -> void:
    _on_mode_changed(FrameworkSchemaMode.RELEASE)


func _on_AnnotationsModeButton_item_selected(index: int) -> void:
    _on_mode_changed(FrameworkSchemaMode.ANNOTATIONS)


func _on_UiSmoothnessModeButton_item_selected(index: int) -> void:
    _on_mode_changed(FrameworkSchemaMode.UI_SMOOTHNESS)


func _on_mode_changed(mode_type: int) -> void:
    var option_button := _get_option_button(mode_type)
    var type := option_button.get_selected_id()
    _manifest_modes[mode_type] = type
    _save_modes()
    # FIXME: LEFT OFF HERE: -------------------------------------
    # - Update rows for new mode.

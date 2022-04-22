tool
class_name FrameworkPluginMainScreen, \
"res://addons/scaffolder/assets/images/editor_icons/scaffolder_panel_container.png"
extends VBoxContainer


const _FRAMEWORK_MANIFEST_PANEL_SCENE := preload(
        "res://addons/scaffolder/addons/plugger/src/gui/framework_manifest_panel.tscn")

const _CENTER_PANEL_MARGIN_FOR_RESIZE_FORGIVENESS := Vector2(144.0, 144.0)
const _MODE_OPTION_BUTTON_WIDTH := 150.0


var _debounced_save_manifest = Sc.time.debounce(
        Pl, "save_manifest", 0.3, false)
var _throttled_on_resize: FuncRef = Sc.time.throttle(
        self, "adjust_size", 0.001, false)
var _debounced_save_open_rows = Sc.time.debounce(
        self, "_save_open_rows", 3.0, false)

# Dictionary<String, OptionButton>
var _option_buttons := {}


func _ready() -> void:
    _create_mode_option_buttons()
    
    _reset_panels()
    Sc.connect("initialized", self, "_reset_panels")
    
    _load_open_rows()
    
    self.connect("resized", _throttled_on_resize, "call_func")
    call_deferred("adjust_size")


func _reset_panels() -> void:
    var container := $CenterContainer/ScrollContainer/VBoxContainer
    Sc.utils.clear_children(container)
    for framework in Sc._framework_globals:
        var panel: FrameworkManifestPanel = \
                Sc.utils.add_scene(container, _FRAMEWORK_MANIFEST_PANEL_SCENE)
        panel.set_up(framework.editor_node, framework.schema)
        panel.connect("value_changed", _debounced_save_manifest, "call_func")
        panel.connect(
                "descendant_toggled", _debounced_save_open_rows, "call_func")


func adjust_size() -> void:
    var size: Vector2 = self.rect_size
    size.y -= $Label.rect_size.y
    size.y -= $Spacer.rect_size.y
    size.y -= $Spacer2.rect_size.y
    var margin: Vector2 = \
            Pl.scale_dimension(_CENTER_PANEL_MARGIN_FOR_RESIZE_FORGIVENESS)
    var scroll_container_size := size - margin
    $CenterContainer/ScrollContainer.rect_min_size = scroll_container_size


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
    for panel in $CenterContainer/ScrollContainer/VBoxContainer.get_children():
        if panel.is_open:
            open_rows[panel.schema.display_name] = panel.get_open_rows()
    return open_rows


func _get_panel_with_label(label: String) -> FrameworkManifestPanel:
    for panel in $CenterContainer/ScrollContainer/VBoxContainer.get_children():
        if panel.schema.display_name == label:
            return panel
    return null


func _create_mode_option_buttons() -> void:
    var container := $Modes
    Sc.utils.clear_children(container)
    
    var spacer_left := Control.new()
    spacer_left.size_flags_horizontal = SIZE_EXPAND_FILL
    container.add_child(spacer_left)
    
    for mode_name in Sc.modes.options:
        var vbox := VBoxContainer.new()
        vbox.add_constant_override("separation", 0.0)
        container.add_child(vbox)
        
        var label := Label.new()
        label.text = "%s mode" % mode_name.capitalize()
        label.align = Label.ALIGN_CENTER
        label.size_flags_horizontal = SIZE_EXPAND_FILL
        vbox.add_child(label)
        
        var color_bar := ColorRect.new()
        var color: Color = Sc.modes.colors[mode_name]
        color_bar.color = color
        color_bar.rect_min_size.y = Pl.scale_dimension(
                FrameworkManifestRow._OVERRIDE_INDICATOR_WIDTH)
        color_bar.size_flags_horizontal = SIZE_EXPAND_FILL
        vbox.add_child(color_bar)
        
        var option_button := OptionButton.new()
        _option_buttons[mode_name] = option_button
        option_button.rect_min_size.x = \
                Pl.scale_dimension(_MODE_OPTION_BUTTON_WIDTH)
        option_button.clear()
        for mode_option in Sc.modes.options[mode_name]:
            option_button.add_item(mode_option)
        _set_mode(mode_name, Sc.modes.get_mode(mode_name), false)
        option_button.connect(
                "item_selected", self, "_on_mode_changed", [mode_name])
        vbox.add_child(option_button)
    
    var spacer_right := Control.new()
    spacer_right.size_flags_horizontal = SIZE_EXPAND_FILL
    container.add_child(spacer_right)


func _get_option_index_from_text(
        option_button: OptionButton,
        text: String) -> int:
    for index in option_button.get_item_count():
        if option_button.get_item_text(index) == text:
            return index
    return -1


func _on_mode_changed(index: int, mode_name: String) -> void:
    var option_button: OptionButton = _option_buttons[mode_name]
    var mode_option := option_button.get_item_text(option_button.selected)
    _set_mode(mode_name, mode_option, true)


func _set_mode(
        mode_name: String,
        mode_option: String,
        should_save_json: bool) -> void:
    Sc.modes.set_mode(mode_name, mode_option)
    
    var option_button: OptionButton = _option_buttons[mode_name]
    var index := _get_option_index_from_text(option_button, mode_option)
    option_button.select(index)
    
    if should_save_json:
        Sc.modes.save_to_json()

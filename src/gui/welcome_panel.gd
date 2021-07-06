class_name WelcomePanel
extends PanelContainer


const _FADE_IN_DURATION := 0.2

export var size_override := Vector2.ZERO

var post_tween_opacity: float


func _init() -> void:
    post_tween_opacity = modulate.a
    modulate.a = 0.0


func _enter_tree() -> void:
    if Engine.editor_hint:
        return
    
    Gs.time.tween_property(
            self,
            "modulate:a",
            0.0,
            post_tween_opacity,
            _FADE_IN_DURATION)


func _ready() -> void:
    if Engine.editor_hint:
        return
    
    Gs.utils.record_gui_original_size_recursively(self)
    
    theme = Gs.gui.theme
    
    Gs.gui.add_gui_to_scale(self)
    
    var faded_color: Color = Gs.colors.zebra_stripe_even_row
    faded_color.a *= 0.3
    
    var items := []
    for item in Gs.gui.welcome_panel_manifest.items:
        if item.size() == 1:
            items.push_back(HeaderLabeledControlItem.new(item[0]))
        else:
            assert(item.size() == 2)
            items.push_back(StaticTextLabeledControlItem.new(item[0], item[1]))
    
    $VBoxContainer/PanelContainer/LabeledControlList \
            .even_row_color_override = faded_color
    $VBoxContainer/PanelContainer/LabeledControlList.items = items
    
    if Gs.gui.welcome_panel_manifest.has("header") and \
            !Gs.gui.welcome_panel_manifest.header.empty():
        $VBoxContainer/Header.text = Gs.gui.welcome_panel_manifest.header
    else:
        $VBoxContainer/Header.text = Gs.app_metadata.app_name
    
    if Gs.gui.welcome_panel_manifest.has("subheader") and \
            !Gs.gui.welcome_panel_manifest.subheader.empty():
        $VBoxContainer/Subheader.text = Gs.gui.welcome_panel_manifest.subheader
    
    if Gs.gui.welcome_panel_manifest.has("is_subheader_shown") and \
            !Gs.gui.welcome_panel_manifest.is_subheader_shown:
        $VBoxContainer/Subheader.visible = false
    
    _on_gui_scale_changed()


func _on_gui_scale_changed() -> bool:
    for child in $VBoxContainer.get_children():
        if child is Control:
            Gs.utils.scale_gui_recursively(child)
        # Round-up sizes to the nearest pixel, in order to prevent small gaps
        # between rows.
        child.rect_min_size = Gs.utils.ceil_vector(child.rect_min_size)
        child.rect_size = rect_min_size
    
    rect_min_size = size_override * Gs.gui.scale
    rect_size.x = rect_min_size.x
    rect_size.y = \
            $VBoxContainer/Header.rect_size.y + \
            $VBoxContainer/Subheader.rect_size.y + \
            $VBoxContainer/PanelContainer.rect_size.y
    rect_position = (get_viewport().size - rect_size) / 2.0
    
    var stylebox: StyleBoxFlat = get_stylebox("panel")
    stylebox.border_color = Gs.colors.overlay_panel_border
    var border_width: float = \
            Gs.styles.overlay_panel_border_width * Gs.gui.scale
    stylebox.border_width_left = border_width
    stylebox.border_width_top = border_width
    stylebox.border_width_right = border_width
    stylebox.border_width_bottom = border_width
    
    return true


func _exit_tree() -> void:
    Gs.gui.remove_gui_to_scale(self)

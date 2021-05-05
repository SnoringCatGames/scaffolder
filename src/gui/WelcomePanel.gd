class_name WelcomePanel
extends VBoxContainer

var controls_items := [
    StaticTextLabeledControlItem.new("*Auto nav*", "click"),
    StaticTextLabeledControlItem.new("Inspect graph", "ctrl + click (x2)"),
    StaticTextLabeledControlItem.new("Walk/Climb", "arrow key / wasd"),
    StaticTextLabeledControlItem.new("Jump", "space / x"),
    StaticTextLabeledControlItem.new("Dash", "z"),
    StaticTextLabeledControlItem.new("Zoom in/out", "ctrl + =/-"),
    StaticTextLabeledControlItem.new("Pan", "ctrl + arrow key"),
]

const DEFAULT_GUI_SCALE := 1.0
const _FADE_IN_DURATION := 0.2

var post_tween_opacity: float

func _init() -> void:
    post_tween_opacity = modulate.a
    modulate.a = 0.0

func _enter_tree() -> void:
    var fade_in_tween := Tween.new()
    add_child(fade_in_tween)
    fade_in_tween.connect(
            "tween_completed",
            self,
            "_on_fade_in_finished",
            [fade_in_tween])
    fade_in_tween.interpolate_property(
            self,
            "modulate:a",
            0.0,
            post_tween_opacity,
            _FADE_IN_DURATION,
            Tween.TRANS_QUAD,
            Tween.EASE_IN_OUT)
    fade_in_tween.start()

func _on_fade_in_finished(
        _object: Object,
        _key: NodePath,
        tween: Tween) -> void:
    remove_child(tween)

func _ready() -> void:
    theme = Gs.theme
    
    Gs.add_gui_to_scale(self, DEFAULT_GUI_SCALE)
    
    var faded_color: Color = Gs.colors.zebra_stripe_even_row_color
    faded_color.a *= 0.3
    
    $PanelContainer/LabeledControlList.even_row_color = faded_color
    $PanelContainer/LabeledControlList.items = controls_items
    
    update_gui_scale(1.0)

func update_gui_scale(gui_scale: float) -> bool:
    for child in get_children():
        if child is Control:
            Gs.utils._scale_gui_recursively(child, gui_scale)
        
    rect_min_size *= gui_scale
    rect_size.x = rect_min_size.x
    rect_size.y = \
            $Header.rect_size.y + \
            $Subheader.rect_size.y + \
            $PanelContainer.rect_size.y
    rect_position = (get_viewport().size - rect_size) / 2.0
    
    return true

func _exit_tree() -> void:
    Gs.remove_gui_to_scale(self)

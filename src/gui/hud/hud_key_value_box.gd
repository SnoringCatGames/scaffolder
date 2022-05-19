tool
class_name HudKeyValueBox
extends ScaffolderPanelContainer


const CONSOLIDATED_SEPARATION := 0.0
const UNCONSOLIDATED_SEPARATION := 12.0

var item: ControlRow
var animation_config: Dictionary

var _tween: ScaffolderTween


func _ready() -> void:
    _tween = ScaffolderTween.new(self)
    
    if Sc.gui.hud.is_key_value_list_consolidated:
        self.style = ScaffolderPanelContainer.PanelStyle.TRANSPARENT
    else:
        self.style = ScaffolderPanelContainer.PanelStyle.HUD
    
    self.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    _on_gui_scale_changed()


func _on_gui_scale_changed() -> bool:
    var size: Vector2 = \
            Sc.gui.hud_manifest.hud_key_value_box_size * Sc.gui.scale
    var spacer_size: float = get_separation() * Sc.gui.scale
    rect_min_size = size
    rect_size = size
    $HBoxContainer.rect_min_size = size
    $HBoxContainer.rect_size = size
    $HBoxContainer/Spacer.rect_size.x = spacer_size
    $HBoxContainer/Spacer.rect_min_size.x = spacer_size
    $HBoxContainer/Spacer2.rect_size.x = spacer_size
    $HBoxContainer/Spacer2.rect_min_size.x = spacer_size
    return true


func _process(_delta: float) -> void:
    if !is_instance_valid(Sc.level):
        return
    _update_display()


func _update_display() -> void:
    var item: TextControlRow = self.item
    
    item.update_item()
    
    $HBoxContainer/Key.text = item.label
    
    var new_value := item.text
    var old_value: String = $HBoxContainer/Value.text
    
    $HBoxContainer/Value.text = item.text
    
    if new_value != old_value and \
            animation_config.has("duration") and \
            animation_config.has("modulate_color"):
        var half_duration: float = animation_config.duration / 2.0
        
        _tween.stop_all()
        _tween.interpolate_property(
                $HBoxContainer/Value,
                "modulate",
                Color.white,
                animation_config.modulate_color,
                half_duration,
                "ease_out",
                0.0,
                TimeType.PLAY_PHYSICS)
        _tween.interpolate_property(
                $HBoxContainer/Value,
                "modulate",
                animation_config.modulate_color,
                Color.white,
                half_duration,
                "ease_out",
                half_duration,
                TimeType.PLAY_PHYSICS)
        _tween.start()


static func get_separation() -> float:
    return CONSOLIDATED_SEPARATION if \
            Sc.gui.hud.is_key_value_list_consolidated else \
            UNCONSOLIDATED_SEPARATION

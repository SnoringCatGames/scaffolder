tool
class_name LevelSelectItemBody
extends Node


var go_scale_multiplier := 0.75

var level_id: String


func _ready() -> void:
    $PlayButton.texture_scale = \
            Vector2(Sc.images.go_scale, Sc.images.go_scale) * \
            go_scale_multiplier


func update() -> void:
    $LabeledControlList.items = _get_items()


func _get_items() -> Array:
    var items := []
    for item_class in Sc.gui.level_select_item_manifest:
        items.push_back(item_class.new(level_id))
    return items


func get_button() -> ScaffolderButton:
    return $PlayButton as ScaffolderButton


func _on_PlayButton_pressed() -> void:
    Sc.nav.open(
            "loading",
            ScreenTransition.DEFAULT,
            {level_id = level_id})

class_name LevelSelectItemBody
extends Node

var go_icon_scale_multiplier := 0.75

var level_id: String

func _ready() -> void:
    $PlayButton.texture = Gs.go_icon
    $PlayButton.texture_scale = \
            Vector2(Gs.go_icon_scale, Gs.go_icon_scale) * \
            go_icon_scale_multiplier

func update() -> void:
    $LabeledControlList.items = _get_items()

func _get_default_item_classes() -> Array:
    var default_items := []
    if Gs.uses_level_scores:
        default_items.push_back(HighScoreLabeledControlItem)
    default_items.push_back(TotalPlaysLabeledControlItem)
    return default_items

func _get_items() -> Array:
    var item_classes := \
            Gs.utils.get_collection_from_exclusions_and_inclusions(
                    _get_default_item_classes(),
                    Gs.level_select_item_class_exclusions,
                    Gs.level_select_item_class_inclusions)
    var items := []
    for item_class in item_classes:
        items.push_back(item_class.new(level_id))
    return items

func get_button() -> ShinyButton:
    return $PlayButton as ShinyButton

func _on_PlayButton_pressed():
    Gs.utils.give_button_press_feedback(true)
    Gs.nav.open("game")
    Gs.nav.screens["game"].start_level(level_id)

tool
class_name LevelSelectScreen
extends Screen

const LEVEL_SELECT_ITEM_RESOURCE_PATH := \
        "res://addons/scaffolder/src/gui/level_select/LevelSelectItem.tscn"

const SCROLL_TWEEN_DURATION := 0.3

const NAME := "level_select"
const LAYER_NAME := "menu_screen"
const AUTO_ADAPTS_GUI_SCALE := true
const INCLUDES_STANDARD_HIERARCHY := true
const INCLUDES_NAV_BAR := true
const INCLUDES_CENTER_CONTAINER := true

# Array<LevelSelectItem>
var level_items := []
var previous_expanded_item: LevelSelectItem
var expanded_item: LevelSelectItem
var _scroll_target: LevelSelectItem
var _new_unlocked_item: LevelSelectItem

func _init().(
        NAME,
        LAYER_NAME,
        AUTO_ADAPTS_GUI_SCALE,
        INCLUDES_STANDARD_HIERARCHY,
        INCLUDES_NAV_BAR,
        INCLUDES_CENTER_CONTAINER \
        ) -> void:
    pass

func _on_activated(previous_screen_name: String) -> void:
    ._on_activated(previous_screen_name)
    _update()

func _ready() -> void:
    for level_id in Gs.level_config.get_level_ids():
        var item: LevelSelectItem = Gs.utils.add_scene(
                $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer \
                        /CenterContainer/VBoxContainer/LevelSelectItems,
                LEVEL_SELECT_ITEM_RESOURCE_PATH,
                true,
                true)
        level_items.push_back(item)
        item.level_id = level_id
        item.is_open = false
        item.connect("pressed", self, "_on_item_pressed", [item])
        item.connect("toggled", self, "_on_item_toggled", [item])

func _update() -> void:
    _calculate_new_unlocked_item()
    for item in level_items:
        item.is_new_unlocked_item = item == _new_unlocked_item
        item.update()
    call_deferred("_deferred_update")

func _deferred_update() -> void:
    var previous_open_item: LevelSelectItem
    for item in level_items:
        if item.is_open:
            previous_open_item = item
    
    if _new_unlocked_item == null:
        if previous_open_item == null:
            var suggested_level_id: String = \
                    Gs.level_config.get_suggested_next_level()
            var item_to_open: LevelSelectItem
            for item in level_items:
                if item.level_id == suggested_level_id:
                    item_to_open = item
            assert(item_to_open != null)
            _on_item_pressed(item_to_open)
        else:
            _give_button_focus(previous_open_item.get_button())
    else:
        var is_closing_accordion_first := previous_open_item != null
        if is_closing_accordion_first:
            _on_item_pressed(previous_open_item)
        
        _scroll_to_item(
                _new_unlocked_item,
                is_closing_accordion_first)

func _process(_delta: float) -> void:
    if Gs.nav.get_active_screen() != self:
        return
    
    var item_to_expand: LevelSelectItem
    var is_up_or_down_pressed := false
    if Input.is_action_just_pressed("ui_up"):
        is_up_or_down_pressed = true
        item_to_expand = _get_previous_item_to_expand()
    elif Input.is_action_just_pressed("ui_down"):
        is_up_or_down_pressed = true
        item_to_expand = _get_next_item_to_expand()
    
    if is_up_or_down_pressed:
        if item_to_expand != null:
            Gs.utils.give_button_press_feedback()
            item_to_expand.focus()
            _on_item_pressed(item_to_expand)
        elif expanded_item != null:
            expanded_item.focus()
        elif previous_expanded_item != null:
            previous_expanded_item.focus()

func _calculate_new_unlocked_item() -> void:
    var new_unlocked_levels: Array = Gs.save_state.get_new_unlocked_levels()
    if new_unlocked_levels.empty():
        _new_unlocked_item = null
    else:
        var last_new_unlocked_level: String = new_unlocked_levels.back()
        for item in level_items:
            if item.level_id == last_new_unlocked_level:
                _new_unlocked_item = item
        assert(_new_unlocked_item != null)

func _get_previous_item_to_expand() -> LevelSelectItem:
    var basis_item := \
            expanded_item if \
            expanded_item != null else \
            previous_expanded_item
    var index := level_items.find(basis_item) - 1
    
    while index >= 0 and \
            !level_items[index].is_unlocked:
        index -= 1
    
    if index >= 0:
        return level_items[index]
    else:
        return null

func _get_next_item_to_expand() -> LevelSelectItem:
    var basis_item := \
            expanded_item if \
            expanded_item != null else \
            previous_expanded_item
    var index := level_items.find(basis_item) + 1
    
    while index < level_items.size() and \
            !level_items[index].is_unlocked:
        index += 1
    
    if index < level_items.size():
        return level_items[index]
    else:
        return null

func _scroll_to_item(
        item: LevelSelectItem,
        include_delay_for_accordion_scroll: bool) -> void:
    _scroll_target = item
    var delay := \
            AccordionPanel.SCROLL_TWEEN_DURATION if \
            include_delay_for_accordion_scroll else \
            0.0
    Gs.time.tween_method(
            self,
            "_interpolate_scroll",
            0.0,
            1.0,
            SCROLL_TWEEN_DURATION,
            "ease_in_out",
            delay,
            TimeType.APP_PHYSICS,
            funcref(self, "_on_scroll_finished"),
            [item])

func _interpolate_scroll(scroll_ratio: float) -> void:
    var scroll_start := scroll_container.get_v_scrollbar().min_value
    var scroll_end: int = Gs.utils.get_node_vscroll_position(
            scroll_container, _scroll_target)
    scroll_container.scroll_vertical = lerp(
            scroll_start,
            scroll_end,
            scroll_ratio)

func _on_scroll_finished(item: LevelSelectItem) -> void:
    item.unlock()
    Gs.save_state.set_new_unlocked_levels([])

func _get_focused_button() -> ShinyButton:
    return null

func _on_item_pressed(item: LevelSelectItem) -> void:
    var delay := 0.0
    if !item.is_open:
        previous_expanded_item = expanded_item
        expanded_item = item
        if previous_expanded_item != null:
            previous_expanded_item.toggle()
            delay = 0.05
    elif expanded_item == item:
        previous_expanded_item = expanded_item
        expanded_item = null
    Gs.time.set_timeout(funcref(item, "toggle"), delay)

func _on_item_toggled(item: LevelSelectItem) -> void:
    _give_button_focus(item.get_button())

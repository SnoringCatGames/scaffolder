tool
class_name LevelSelectScreen
extends Screen


const LEVEL_SELECT_ITEM_SCENE := preload( \
        "res://addons/scaffolder/src/gui/level_select/level_select_item.tscn")
const SCROLL_TWEEN_DURATION := 0.3

# Array<LevelSelectItem>
var level_items := []
var previous_expanded_item: LevelSelectItem
var expanded_item: LevelSelectItem
var _scroll_target: LevelSelectItem
var _new_unlocked_item: LevelSelectItem


func _ready() -> void:
    for level_number in Sc.levels.get_level_numbers():
        var level_config: Dictionary = \
                Sc.levels.get_level_config_by_number(level_number)
        var item: LevelSelectItem = Sc.utils.add_scene(
                $VBoxContainer/LevelSelectItems,
                LEVEL_SELECT_ITEM_SCENE,
                true,
                true)
        level_items.push_back(item)
        item.level_id = level_config.id
        item.is_open = false
        item.connect("pressed", self, "_on_item_pressed", [item])
        item.connect("toggled", self, "_on_item_toggled", [item])


func _on_transition_in_started(previous_screen: Screen) -> void:
    ._on_transition_in_started(previous_screen)
    _update()


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
                    Sc.levels.get_recorded_suggested_next_level()
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
    if Sc.nav.current_screen != self:
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
            Sc.utils.give_button_press_feedback()
            item_to_expand.focus()
            _on_item_pressed(item_to_expand)
        elif expanded_item != null:
            expanded_item.focus()
        elif previous_expanded_item != null:
            previous_expanded_item.focus()


func _calculate_new_unlocked_item() -> void:
    var new_unlocked_levels: Array = Sc.save_state.get_new_unlocked_levels()
    Sc.save_state.set_new_unlocked_levels([])
    
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
    Sc.time.tween_method(
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
    var scroll_start: int = \
            container.scroll_container.get_v_scrollbar().min_value
    var scroll_end: int = Sc.utils.get_node_vscroll_position(
            container.scroll_container,
            _scroll_target)
    container.scroll_container.scroll_vertical = lerp(
            scroll_start,
            scroll_end,
            scroll_ratio)


func _on_scroll_finished(item: LevelSelectItem) -> void:
    item.unlock()


func _get_focused_button() -> ScaffolderButton:
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
    Sc.time.set_timeout(item, "toggle", delay)


func _on_item_toggled(item: LevelSelectItem) -> void:
    _give_button_focus(item.get_button())

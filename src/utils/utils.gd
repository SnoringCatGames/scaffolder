tool
class_name Utils
extends Node


const MAX_INT := 9223372036854775807

const PROPERTY_USAGE_EXPORTED_ITEM := \
        PROPERTY_USAGE_STORAGE | \
        PROPERTY_USAGE_EDITOR | \
        PROPERTY_USAGE_NETWORK | \
        PROPERTY_USAGE_SCRIPT_VARIABLE

const PROPERTY_USAGE_GROUPED_ITEM := PROPERTY_USAGE_EXPORTED_ITEM

const PROPERTY_USAGE_GROUP_HEADER := \
        PROPERTY_USAGE_EDITOR | \
        PROPERTY_USAGE_SCRIPT_VARIABLE | \
        PROPERTY_USAGE_GROUP

var _focus_releaser: Control


func _init() -> void:
    Sc.logger.on_global_init(self, "Utils")
    
    _focus_releaser = Button.new()
    _focus_releaser.modulate.a = 0.0
    _focus_releaser.visible = false
    add_child(_focus_releaser)


func get_is_paused() -> bool:
    return get_tree().paused


func pause() -> void:
    get_tree().paused = true


func unpause() -> void:
    get_tree().paused = false


# TODO: Replace this with any built-in feature whenever it exists
#       (https://github.com/godotengine/godot/issues/4715).
static func subarray(
        array: Array,
        start: int,
        length := -1) -> Array:
    if length < 0:
        length = array.size() - start
    var result := []
    result.resize(length)
    for i in length:
        result[i] = array[start + i]
    return result


# TODO: Replace this with any built-in feature whenever it exists
#       (https://github.com/godotengine/godot/issues/4715).
static func sub_pool_vector2_array(
        array: PoolVector2Array,
        start: int,
        length := -1) -> PoolVector2Array:
    if length < 0:
        length = array.size() - start
    var result := PoolVector2Array()
    result.resize(length)
    for i in length:
        result[i] = array[start + i]
    return result


static func splice(
        result: Array,
        start: int,
        delete_count: int,
        items_to_insert: Array) -> void:
    var old_count := result.size()
    var items_to_insert_count := items_to_insert.size()
    
    assert(start >= 0)
    assert(start <= old_count)
    assert(delete_count >= 0)
    assert(delete_count <= old_count)
    assert(start + delete_count <= old_count)
    
    var new_count := old_count - delete_count + items_to_insert_count
    var is_growing := items_to_insert_count > delete_count
    var is_shrinking := items_to_insert_count < delete_count
    var displacement := items_to_insert_count - delete_count
    
    if is_shrinking:
        # Shift old items toward the front.
        var i := start + delete_count
        while i < old_count:
            result[i + displacement] = result[i]
            i += 1
    
    # Resize the result array.
    result.resize(new_count)
    
    if is_growing:
        # Shift old items toward the back.
        var i := old_count - 1
        while i >= start + delete_count:
            result[i + displacement] = result[i]
            i -= 1
    
    # Insert the new items.
    var i := 0
    while i < items_to_insert_count:
        result[start + i] = items_to_insert[i]
        i += 1


# TODO: Replace this with any built-in feature whenever it exists
#       (https://github.com/godotengine/godot/issues/4715).
static func concat(
        result: Array,
        other: Array,
        append_to_end := true) -> Array:
    var old_result_size := result.size()
    var other_size := other.size()
    var new_result_size := old_result_size + other_size
    result.resize(new_result_size)
    if append_to_end:
        for i in other_size:
            result[old_result_size + i] = other[i]
    else:
        # Move old values to the back.
        for i in old_result_size:
            result[new_result_size - 1 - i] = result[old_result_size - 1 - i]
        # Add new values to the front.
        for i in other_size:
            result[i] = other[i]
    return result


static func dedup(array: Array) -> Array:
    var set := {}
    for element in array:
        set[element] = true
    var set_values := set.values()
    var deduped_size := set_values.size()
    array.resize(deduped_size)
    for i in deduped_size:
        array[i] = set_values[i]
    return array


static func merge(
        result: Dictionary,
        other: Dictionary,
        overrides_preexisting_properties := true,
        recursive := false) -> Dictionary:
    if recursive:
        if overrides_preexisting_properties:
            for key in other:
                if result.has(key):
                    if result[key] is Dictionary and other[key] is Dictionary:
                        merge(result[key], other[key], true, true)
                    elif result[key] is Array and other[key] is Array:
                        concat(result[key], other[key])
                    else:
                        result[key] = other[key]
                else:
                    result[key] = other[key]
        else:
            for key in other:
                if result.has(key):
                    if result[key] is Dictionary and other[key] is Dictionary:
                        merge(result[key], other[key], false, true)
                    elif result[key] is Array and other[key] is Array:
                        concat(result[key], other[key])
                    else:
                        # Do nothing; preserve the original value.
                        pass
                else:
                    result[key] = other[key]
    else:
        if overrides_preexisting_properties:
            for key in other:
                result[key] = other[key]
        else:
            for key in other:
                if !result.has(key):
                    result[key] = other[key]
    return result


static func subtract_nested_arrays(
        result: Dictionary,
        other: Dictionary,
        expects_no_missing_matches := false) -> Dictionary:
    for key in other:
        if result.has(key):
            if result[key] is Dictionary and other[key] is Dictionary:
                subtract_nested_arrays(
                        result[key], other[key], expects_no_missing_matches)
            elif result[key] is Array and other[key] is Array:
                subtract_arrays(
                        result[key], other[key], expects_no_missing_matches)
            elif expects_no_missing_matches:
                Sc.logger.error(
                        ("Utils.subtract_nested_arrays: Wrong-type match: " +
                        "(We currently don't support subtracting properties " +
                        "from a Dictionary. We only support subtracting " +
                        "elements from Arrays.)" +
                        "\n    key=%s,\n    result=%s,\n    other=%s") % \
                        [key, result, other])
        elif expects_no_missing_matches:
            Sc.logger.error(
                    ("Utils.subtract_nested_arrays: Missing match: " +
                    "\n    key=%s,\n    result=%s,\n    other=%s") % \
                    [key, result, other])
    return result


static func subtract_arrays(
        result: Array,
        other: Array,
        expects_no_missing_matches := false) -> Array:
    for element in other:
        var result_index := result.find(element)
        if result_index >= 0:
            result.remove(result_index)
        else:
            Sc.logger.error(
                    ("Utils.subtract_arrays: Missing match: " +
                    "\n    element=%s,\n    result=%s,\n    other=%s") % \
                    [element, result, other])
    return result


static func join(
        array,
        delimiter := ",") -> String:
    assert(array is Array or array is PoolStringArray)
    var count: int = array.size()
    var result := ""
    for index in array.size() - 1:
        result += str(array[index]) + delimiter
    if count > 0:
        result += str(array[count - 1])
    return result


static func array_to_set(array: Array) -> Dictionary:
    var set := {}
    for element in array:
        set[element] = element
    return set


func cascade_sort(arr: Array) -> Array:
    arr.sort()
    return arr


static func translate_polyline(
        vertices: PoolVector2Array,
        translation: Vector2) \
        -> PoolVector2Array:
    var result := PoolVector2Array()
    result.resize(vertices.size())
    for i in vertices.size():
        result[i] = vertices[i] + translation
    return result


static func get_children_by_type(
        parent: Node,
        type,
        recursive := false,
        result := []) -> Array:
    for child in parent.get_children():
        if child is type:
            result.push_back(child)
        if recursive:
            get_children_by_type(
                    child,
                    type,
                    recursive,
                    result)
    return result


static func get_child_by_type(
        parent: Node,
        type,
        recursive := false) -> Node:
    var children := get_children_by_type(parent, type, recursive)
    assert(children.size() == 1)
    return children[0]


static func get_ancestor_by_type(
        descendant: Node,
        type) -> Node:
    var ancestor := descendant.get_parent()
    while is_instance_valid(ancestor) and \
            !(ancestor is type):
        ancestor = ancestor.get_parent()
    return ancestor


func add_scene(
        parent: Node,
        path_or_packed_scene,
        is_attached := true,
        is_visible := true, \
        child_index := -1) -> Node:
    var scene: PackedScene
    if path_or_packed_scene is String:
        scene = load(path_or_packed_scene)
    else:
        scene = path_or_packed_scene
    if scene == null:
        Sc.logger.error("Invalid scene path: %s" % path_or_packed_scene)
    
    var node: Node = scene.instance()
    if node is CanvasItem:
        node.visible = is_visible
    if is_attached:
        parent.add_child(node)
    
    if child_index >= 0:
        parent.move_child(node, child_index)
    
    if path_or_packed_scene is String:
        # Assign a node name based on the file name.
        var name: String = path_or_packed_scene
        if name.find_last("/") >= 0:
            name = name.substr(name.find_last("/") + 1)
        assert(path_or_packed_scene.ends_with(".tscn"))
        name = name.substr(0, name.length() - 5)
        node.name = name
    
    return node


func clear_children(node: Node) -> void:
    for child in node.get_children():
        child.queue_free()


static func get_level_position_for_screen_event(input_event: InputEvent) -> Vector2:
    return transform_screen_position_to_level_position(input_event.position)


static func transform_screen_position_to_level_position(
        screen_position: Vector2) -> Vector2:
    return (Sc.level.get_canvas_transform() * \
            Sc.level.get_global_transform()) \
        .affine_inverse() \
        .xform(screen_position - Sc.nav.current_screen.rect_position)


static func get_screen_position_of_node_in_level(node: CanvasItem) -> Vector2:
    return node.get_global_transform_with_canvas().origin + \
        Sc.nav.current_screen.rect_position


func add_overlay_to_current_scene(node: Node) -> void:
    get_tree().get_current_scene().add_child(node)


func vibrate() -> void:
    if Sc.gui.is_giving_haptic_feedback:
        Input.vibrate_handheld(
                Sc.gui.input_vibrate_duration * 1000)


func give_button_press_feedback(is_fancy := false) -> void:
    vibrate()
    if is_fancy:
        Sc.audio.play_sound("menu_select_fancy")
    else:
        Sc.audio.play_sound("menu_select")


# TODO: Replace this with better built-in EaseType/TransType easing support
#       when it's ready
#       (https://github.com/godotengine/godot-proposals/issues/36).
static func ease_name_to_param(name: String) -> float:
    match name:
        "linear":
            return 1.0
        
        "ease_in":
            return 2.4
        "ease_in_strong":
            return 4.8
        "ease_in_very_strong":
            return 9.6
        "ease_in_weak":
            return 1.6
        
        "ease_out":
            return 0.4
        "ease_out_strong":
            return 0.2
        "ease_out_very_strong":
            return 0.1
        "ease_out_weak":
            return 0.6
        
        "ease_in_out":
            return -2.4
        "ease_in_out_strong":
            return -4.8
        "ease_in_out_very_strong":
            return -9.6
        "ease_in_out_weak":
            return -1.8
        
        _:
            ScaffolderLog.static_error(".ease_name_to_param")
            return INF


static func ease_by_name(
        progress: float,
        ease_name: String) -> float:
    return ease(progress, ease_name_to_param(ease_name))


static func is_num(v) -> bool:
    return v is int or v is float


static func floor_vector(v: Vector2) -> Vector2:
    return Vector2(floor(v.x), floor(v.y))


static func ceil_vector(v: Vector2) -> Vector2:
    return Vector2(ceil(v.x), ceil(v.y))


static func round_vector(v: Vector2) -> Vector2:
    return Vector2(round(v.x), round(v.y))


static func mix(
        values: Array,
        weights: Array):
    assert(values.size() == weights.size())
    assert(!values.empty())
    
    var count := values.size()
    
    var weight_sum := 0.0
    for weight in weights:
        weight_sum += weight
    
    var weighted_average
    if Sc.utils.is_num(values[0] is float):
        weighted_average = 0.0
    elif values[0] is Vector2:
        weighted_average = Vector2.ZERO
    elif values[0] is Vector3:
        weighted_average = Vector3.ZERO
    else:
        ScaffolderLog.static_error(".mix")
    
    for i in count:
        var value = values[i]
        var weight: float = weights[i]
        var normalized_weight := \
                weight / weight_sum if \
                weight_sum > 0.0 else \
                1.0 / count
        weighted_average += value * normalized_weight
    
    return weighted_average


static func mix_colors(
        colors: Array,
        weights: Array) -> Color:
    assert(colors.size() == weights.size())
    assert(!colors.empty())
    
    var count := colors.size()
    
    var weight_sum := 0.0
    for weight in weights:
        weight_sum += weight
    
    var h := 0.0
    var s := 0.0
    var v := 0.0
    for i in count:
        var color: Color = colors[i]
        var weight: float = weights[i]
        var normalized_weight := \
                weight / weight_sum if \
                weight_sum > 0.0 else \
                1.0 / count
        h += color.h * normalized_weight
        s += color.s * normalized_weight
        v += color.v * normalized_weight
    
    return Color.from_hsv(h, s, v, 1.0)


static func get_datetime_string() -> String:
    var datetime := OS.get_datetime()
    return "%s-%s-%s_%s.%s.%s" % [
        datetime.year,
        datetime.month,
        datetime.day,
        datetime.hour,
        datetime.minute,
        datetime.second,
    ]


static func get_time_string_from_seconds(
        time: float,
        includes_ms := false,
        includes_empty_hours := true,
        includes_empty_minutes := true) -> String:
    var is_undefined := is_inf(time)
    var time_str := ""
    
    # Hours.
    var hours := int(time / 3600.0)
    time = fmod(time, 3600.0)
    if hours != 0 or \
            includes_empty_hours:
        if !is_undefined:
            time_str = "%s%02d:" % [
                time_str,
                hours,
            ]
        else:
            time_str = "--:"
    
    # Minutes.
    var minutes := int(time / 60.0)
    time = fmod(time, 60.0)
    if minutes != 0 or \
            includes_empty_minutes:
        if !is_undefined:
            time_str = "%s%02d:" % [
                time_str,
                minutes,
            ]
        else:
            time_str += "--:"
    
    # Seconds.
    var seconds := int(time)
    if !is_undefined:
        time_str = "%s%02d" % [
            time_str,
            seconds,
        ]
    else:
        time_str += "--"
    
    if includes_ms:
        # Milliseconds.
        var milliseconds := \
                int(fmod((time - seconds) * 1000.0, 1000.0))
        if !is_undefined:
            time_str = "%s.%03d" % [
                time_str,
                milliseconds,
            ]
        else:
            time_str += ".---"
    
    return time_str


func get_vector_string(
        vector: Vector2,
        decimal_place_count := 2) -> String:
    return "(%.*f,%.*f)" % [
        decimal_place_count,
        vector.x,
        decimal_place_count,
        vector.y,
    ]


func get_spaces(count: int) -> String:
    assert(count <= 60)
    return "                                                            " \
            .substr(0, count)


func pad_string(
        string: String,
        length: int,
        pads_on_right := true,
        allows_longer_strings := false) -> String:
    assert(allows_longer_strings or string.length() <= length)
    var spaces_count := length - string.length()
    if spaces_count <= 0:
        return string
    else:
        var padding := get_spaces(spaces_count)
        if pads_on_right:
            return "%s%s" % [string, padding]
        else:
            return "%s%s" % [padding, string]


func resize_string(
        string: String,
        length: int,
        pads_on_right := true) -> String:
    if string.length() > length:
        return string.substr(0, length)
    elif string.length() < length:
        return pad_string(string, length, pads_on_right)
    else:
        return string


func take_screenshot() -> void:
    if !ensure_directory_exists("user://screenshots"):
        return
    
    var image := get_viewport().get_texture().get_data()
    image.flip_y()
    var path := "user://screenshots/screenshot-%s.png" % get_datetime_string()
    var status := image.save_png(path)
    if status != OK:
        Sc.logger.error("Utils.take_screenshot")


func open_screenshot_folder() -> void:
    var path := OS.get_user_data_dir() + "/screenshots"
    Sc.logger.print("Opening screenshot folder: " + path)
    OS.shell_open(path)


func ensure_directory_exists(path: String) -> bool:
    var directory := Directory.new()
    var status := directory.make_dir_recursive(path)
    if status != OK:
        Sc.logger.error("make_dir_recursive failed: " + str(status))
        return false
    return true


func clear_directory(
        path: String,
        also_deletes_directory := false) -> void:
    # Open directory.
    var directory := Directory.new()
    var status := directory.open(path)
    if status != OK:
        Sc.logger.error("Utils.clear_directory")
        return
    
    # Delete children.
    directory.list_dir_begin(true)
    var file_name := directory.get_next()
    while file_name != "":
        if directory.current_is_dir():
            var child_path := \
                    path + file_name if \
                    path.ends_with("/") else \
                    path + "/" + file_name
            clear_directory(child_path, true)
        else:
            status = directory.remove(file_name)
            if status != OK:
                Sc.logger.error("Failed to delete file", false)
        file_name = directory.get_next()
    
    # Delete directory.
    if also_deletes_directory:
        status = directory.remove(path)
        if status != OK:
            Sc.logger.error("Failed to delete directory", false)


static func get_last_x_lines_from_file(
        path: String,
        x: int) -> Array:
    var file := File.new()
    var status := file.open(path, File.READ)
    if status != OK:
        ScaffolderLog.static_error("Unable to open file: " + path)
        return []
    var buffer := CircularBuffer.new(x)
    while !file.eof_reached():
        buffer.push(file.get_line())
    file.close()
    return buffer.get_items()


func set_mouse_filter_recursively(
        node: Node,
        mouse_filter: int) -> void:
    for child in node.get_children():
        if child is Control:
            if !(child is Button or \
                    child is Slider):
                child.mouse_filter = mouse_filter
        set_mouse_filter_recursively(child, mouse_filter)


func notify_on_screen_visible_recursively(node: CanvasItem) -> void:
    if node.has_method("_on_screen_visible"):
        node._on_screen_visible()
    
    for child in node.get_children():
        if child is CanvasItem:
            notify_on_screen_visible_recursively(child)


func get_node_vscroll_position(
        scroll_container: ScrollContainer,
        control: Control,
        offset := 0) -> int:
    var scroll_container_global_position := \
            scroll_container.rect_global_position
    var control_global_position := control.rect_global_position
    var vscroll_position: int = \
            control_global_position.y - \
            scroll_container_global_position.y + \
            scroll_container.scroll_vertical + \
            offset
    var max_vscroll_position := scroll_container.get_v_scrollbar().max_value
    return int(min(vscroll_position, max_vscroll_position))


func does_control_have_focus_recursively(control: Control) -> bool:
    var focused_control := _focus_releaser.get_focus_owner()
    while focused_control != null:
        if focused_control == control:
            return true
        focused_control = focused_control.get_parent_control()
    return false


func release_focus(control = null) -> void:
    if control == null or \
            does_control_have_focus_recursively(control):
        _focus_releaser.grab_focus()
        _focus_releaser.release_focus()


func get_instance_id_or_not(object: Object) -> int:
    return object.get_instance_id() if \
            object != null else \
            -1


func get_all_nodes_in_group(group_name: String) -> Array:
    return get_tree().get_nodes_in_group(group_name)


func get_node_in_group(group_name: String) -> Node:
    var nodes := get_tree().get_nodes_in_group(group_name)
    assert(nodes.size() == 1)
    return nodes[0]


# Registers nodes as desaturatable for the slow-motion effect.
func set_is_desaturatable(
        node: Node2D,
        is_desaturatable: bool) -> void:
    if is_desaturatable:
        node.add_to_group(Sc.slow_motion.GROUP_NAME_DESATURATABLES)
    else:
        if node.is_in_group(Sc.slow_motion.GROUP_NAME_DESATURATABLES):
            node.remove_from_group(Sc.slow_motion.GROUP_NAME_DESATURATABLES)


func get_render_layer_bitmask_from_name(layer_name: String) -> int:
    return Sc.metadata._render_layer_name_to_bitmask[layer_name] if \
            Sc.metadata._render_layer_name_to_bitmask.has(layer_name) else \
            -1


func get_physics_layer_bitmask_from_name(layer_name: String) -> int:
    return Sc.metadata._physics_layer_name_to_bitmask[layer_name] if \
            Sc.metadata._physics_layer_name_to_bitmask.has(layer_name) else \
            -1


func get_render_layer_names_from_bitmask(combined_bitmask: int) -> Array:
    var layer_names := []
    for i in 20:
        var index_bitmask := int(pow(2, i))
        var is_bit_enabled := (combined_bitmask & index_bitmask) != 0
        if is_bit_enabled:
            var layer_name: String = \
                    Sc.metadata._render_layer_bitmask_to_name[index_bitmask]
            layer_names.push_back(layer_name)
    return layer_names


func get_physics_layer_names_from_bitmask(combined_bitmask: int) -> Array:
    var layer_names := []
    for i in 20:
        var index_bitmask := int(pow(2, i))
        var is_bit_enabled := (combined_bitmask & index_bitmask) != 0
        if is_bit_enabled:
            var layer_name: String = \
                    Sc.metadata._physics_layer_bitmask_to_name[index_bitmask]
            layer_names.push_back(layer_name)
    return layer_names


func get_property_value_from_scene_state_node(
        state: SceneState,
        node_index: int,
        property_name: String,
        expects_a_result := false):
    for property_index in state.get_node_property_count(node_index):
        if state.get_node_property_name(node_index, property_index) == \
                property_name:
            return state.get_node_property_value(node_index, property_index)
    assert(!expects_a_result)


func check_whether_sub_classes_are_tools(object: Object) -> bool:
    var script: Script = object.get_script()
    while script != null:
        if !script.is_tool():
            return false
        script = script.get_base_script()
    return true


## Creates a property_list array for the given node with the given groups.
## -   Queries the default property list from the given node
##     (from get_property_list()).
## -   Groups will contain properties at and after the given
##     `first_property_name`
## -   Groups will contain properties up to one of the following:
##     -   `last_property_name`, if given
##     -   The next group
##     -   The end of the property list
## -   Properties starting with an underscore will be skipped.
## -   The result is suitable for returning from _get_property_list.
## -   **NOTE**: You will probably want to remove the `export` keyword from any
##     property you are grouping, since they would otherwise be shown twice.
func get_property_list_for_contiguous_inspector_groups(
        node: Node,
        groups: Array) -> Array:
    for group in groups:
        assert(group is Dictionary)
        assert(group.has("group_name"))
        assert(group.has("first_property_name"))
    
    var default_property_list := node.get_property_list()
    var first_property_index_to_group := {}
    
    for group in groups:
        group.first_property_index = _get_property_index(
                group.first_property_name,
                default_property_list)
        if group.first_property_index < 0:
            Sc.logger.error(
                "Utils.get_property_list_for_contiguous_inspector_groups")
            return []
        if group.has("last_property_name"):
            group.last_property_index = _get_property_index(
                    group.last_property_name,
                    default_property_list)
            if group.last_property_index < 0:
                Sc.logger.error(
                    "Utils.get_property_list_for_contiguous_inspector_groups")
                return []
        first_property_index_to_group[group.first_property_index] = group
    
    var first_property_indices := first_property_index_to_group.keys()
    first_property_indices.sort()
    
    var property_list_addendum := []
    
    for group_index in first_property_indices.size():
        var first_property_index: int = first_property_indices[group_index]
        var group: Dictionary = \
                first_property_index_to_group[first_property_index]
        var group_overrides: Dictionary = \
                group.overrides if \
                group.has("overrides") else \
                {}
        
        var last_property_index: int
        if group.has("last_property_index"):
            last_property_index = group.last_property_index
        elif group_index + 1 < first_property_indices.size():
            last_property_index = first_property_indices[group_index + 1] - 1
        else:
            last_property_index = default_property_list.size() - 1
        
        property_list_addendum.push_back({
            name = group.group_name,
            type = TYPE_NIL,
            usage = PROPERTY_USAGE_GROUP_HEADER,
        })
        
        for property_index in \
                range(first_property_index, last_property_index + 1):
            var original_property_config: Dictionary = \
                    default_property_list[property_index]
            var name: String = original_property_config.name
            # Skip "private" properties that start with an underscore.
            if name.begins_with("_"):
                continue
            var property_overrides: Dictionary = \
                    group_overrides[name] if \
                    group_overrides.has(name) else \
                    {}
            var type: int = \
                    property_overrides.type if \
                    property_overrides.has("type") else \
                    original_property_config.type
            var hint: int
            if property_overrides.has("hint"):
                hint = property_overrides.hint
            elif node.get(name) is ColorConfig:
                hint = ScaffolderPropertyHint.PROPERTY_HINT_COLOR_CONFIG
            else:
                hint = original_property_config.hint
            var hint_string: String = \
                    property_overrides.hint_string if \
                    property_overrides.has("hint_string") else \
                    original_property_config.hint_string
            property_list_addendum.push_back({
                name = name,
                type = type,
                hint = hint,
                hint_string = hint_string,
                usage = PROPERTY_USAGE_GROUPED_ITEM,
            })
    
    return property_list_addendum


func get_property_list_for_non_contiguous_inspector_groups(
        node: Node,
        groups: Array) -> Array:
    for group in groups:
        assert(group is Dictionary)
        assert(group.has("group_name"))
        assert(group.has("property_names"))
        group.property_indices = []
        group.property_indices.resize(group.property_names.size())
    
    var default_property_list := node.get_property_list()
    
    for group in groups:
        for i in group.property_names.size():
            var property_name: String = group.property_names[i]
            var property_index := _get_property_index(
                    property_name,
                    default_property_list)
            if property_index < 0:
                Sc.logger.error("Utils.get_property_list_for_non_contiguous_inspector_groups")
                return []
            group.property_indices[i] = property_index
    
    var property_list_addendum := []
    
    for group in groups:
        var group_overrides: Dictionary = \
                group.overrides if \
                group.has("overrides") else \
                {}
        
        property_list_addendum.push_back({
            name = group.group_name,
            type = TYPE_NIL,
            usage = PROPERTY_USAGE_GROUP_HEADER,
        })
        
        for property_index in group.property_indices:
            var original_property_config: Dictionary = \
                    default_property_list[property_index]
            var name: String = original_property_config.name
            var property_overrides: Dictionary = \
                    group_overrides[name] if \
                    group_overrides.has(name) else \
                    {}
            var type: int = \
                    property_overrides.type if \
                    property_overrides.has("type") else \
                    original_property_config.type
            var hint: int = \
                    property_overrides.hint if \
                    property_overrides.has("hint") else \
                    original_property_config.hint
            var hint_string: String = \
                    property_overrides.hint_string if \
                    property_overrides.has("hint_string") else \
                    original_property_config.hint_string
            property_list_addendum.push_back({
                name = name,
                type = type,
                hint = hint,
                hint_string = hint_string,
                usage = PROPERTY_USAGE_GROUPED_ITEM,
            })
    
    return property_list_addendum


# **NOTE**: This doesn't work!
#           -   Godot doesn't support removing the storage flag from the
#               _get_property_list() amendment.
#           -   Maybe they will in the future?
func amend_property_list_to_not_store(
        default_property_list: Array,
        first_property_name: String,
        last_property_name := "") -> Array:
    var first_property_index := \
            _get_property_index(first_property_name, default_property_list)
    var last_property_index := \
            _get_property_index(last_property_name, default_property_list) if \
            last_property_name != "" else \
            default_property_list.size() - 1
    
    if first_property_index < 0 or \
            last_property_index < 0:
        Sc.logger.error("Utils.amend_property_list_to_not_store")
        return []
    
    var property_list_addendum := []
    for i in range(first_property_index, last_property_index + 1):
        var original_property_config: Dictionary = default_property_list[i]
        original_property_config.usage &= ~PROPERTY_USAGE_STORAGE
        property_list_addendum.push_back(original_property_config)
    return property_list_addendum


func _get_property_index(
        property_name: String,
        property_list: Array) -> int:
    var i := property_list.size() - 1
    while i >= 0:
        var property_config: Dictionary = property_list[i]
        if property_config.name == property_name:
            return i
        i -= 1
    TYPE_INT
    return -1


static func get_type_string(type: int) -> String:
    match type:
        TYPE_NIL:
            return "TYPE_NIL"
        TYPE_BOOL:
            return "TYPE_BOOL"
        TYPE_INT:
            return "TYPE_INT"
        TYPE_REAL:
            return "TYPE_REAL"
        TYPE_STRING:
            return "TYPE_STRING"
        TYPE_VECTOR2:
            return "TYPE_VECTOR2"
        TYPE_RECT2:
            return "TYPE_RECT2"
        TYPE_VECTOR3:
            return "TYPE_VECTOR3"
        TYPE_TRANSFORM2D:
            return "TYPE_TRANSFORM2D"
        TYPE_PLANE:
            return "TYPE_PLANE"
        TYPE_QUAT:
            return "TYPE_QUAT"
        TYPE_AABB:
            return "TYPE_AABB"
        TYPE_BASIS:
            return "TYPE_BASIS"
        TYPE_TRANSFORM:
            return "TYPE_TRANSFORM"
        TYPE_COLOR:
            return "TYPE_COLOR"
        TYPE_NODE_PATH:
            return "TYPE_NODE_PATH"
        TYPE_RID:
            return "TYPE_RID"
        TYPE_OBJECT:
            return "TYPE_OBJECT"
        TYPE_DICTIONARY:
            return "TYPE_DICTIONARY"
        TYPE_ARRAY:
            return "TYPE_ARRAY"
        TYPE_RAW_ARRAY:
            return "TYPE_RAW_ARRAY"
        TYPE_INT_ARRAY:
            return "TYPE_INT_ARRAY"
        TYPE_REAL_ARRAY:
            return "TYPE_REAL_ARRAY"
        TYPE_STRING_ARRAY:
            return "TYPE_STRING_ARRAY"
        TYPE_VECTOR2_ARRAY:
            return "TYPE_VECTOR2_ARRAY"
        TYPE_VECTOR3_ARRAY:
            return "TYPE_VECTOR3_ARRAY"
        TYPE_COLOR_ARRAY:
            return "TYPE_COLOR_ARRAY"
        TYPE_MAX:
            return "TYPE_MAX"
        _:
            Sc.logger.error("Utils.get_type_string: %d" % type)
            return ""


static func get_direct_property_map(
        object: Object,
        parent_type) -> Dictionary:
    # -   The problem with get_property_list() is that it also includes all of
    #     the ancestor class properties.
    # -   To get around this, we get all of the ancestor class properties--
    #     without any of the subclass's direct properties--here, so that we can
    #     filter them out later.
    # -   For this to work, the object must extend Reference directly.
    
    var parent_property_list: Array = parent_type.new().get_property_list()
    var parent_property_map := {}
    for property_config in parent_property_list:
        parent_property_map[property_config.name] = property_config
    
    var property_map := {}
    
    var property_list := object.get_property_list()
    for property_config in property_list:
        if parent_property_map.has(property_config.name) or \
                property_config.name == "Script Variables":
            continue
        property_map[property_config.name] = object.get(property_config.name)
    
    return property_map


static func get_direct_color_properties(object: Reference) -> Dictionary:
    var property_map := get_direct_property_map(object, Reference)
    for key in property_map.keys():
        if !property_map[key] is Color and \
                !property_map[key] is ColorConfig:
            property_map.erase(key)
    return property_map


static func get_direct_non_color_properties(object: Reference) -> Dictionary:
    var property_map := get_direct_property_map(object, Reference)
    for key in property_map.keys():
        if property_map[key] is Color or \
                property_map[key] is ColorConfig:
            property_map.erase(key)
    return property_map

class_name Utils
extends Node


const MAX_INT := 9223372036854775807

var _focus_releaser: Control


func _init() -> void:
    Gs.logger.on_global_init(self, "Utils")
    
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


# TODO: Replace this with any built-in feature whenever it exists
#       (https://github.com/godotengine/godot/issues/4715).
static func concat(
        result: Array,
        other: Array,
        append_to_end := true) -> void:
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


static func join(
        array,
        delimiter := ",") -> String:
    assert(array is Array or array is PoolStringArray)
    var count: int = array.size()
    var result := ""
    for index in array.size() - 1:
        result += array[index] + delimiter
    if count > 0:
        result += array[count - 1]
    return result


static func array_to_set(array: Array) -> Dictionary:
    var set := {}
    for element in array:
        set[element] = element
    return set


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


static func get_floor_friction_multiplier(body: KinematicBody2D) -> float:
    var collision := _get_floor_collision(body)
    # Collision friction is a property of the TileMap node.
    if collision != null and collision.collider.collision_friction != null:
        return collision.collider.collision_friction
    return 0.0


static func _get_floor_collision(
        body: KinematicBody2D) -> KinematicCollision2D:
    if body.is_on_floor():
        for i in body.get_slide_count():
            var collision := body.get_slide_collision(i)
            if abs(collision.normal.angle_to(Gs.geometry.UP)) <= \
                    Gs.geometry.FLOOR_MAX_ANGLE:
                return collision
    return null


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
        Gs.logger.error("Invalid scene path: %s" % path_or_packed_scene)
    
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


static func get_level_touch_position(input_event: InputEvent) -> Vector2:
    return Gs.level.make_input_local(input_event).position


func add_overlay_to_current_scene(node: Node) -> void:
    get_tree().get_current_scene().add_child(node)


func vibrate() -> void:
    if Gs.gui.is_giving_haptic_feedback:
        Input.vibrate_handheld(
                Gs.gui.input_vibrate_duration * 1000)


func give_button_press_feedback(is_fancy := false) -> void:
    vibrate()
    if is_fancy:
        Gs.audio.play_sound("menu_select_fancy")
    else:
        Gs.audio.play_sound("menu_select")


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
            ScaffolderLog.static_error()
            return INF


static func ease_by_name(
        progress: float,
        ease_name: String) -> float:
    return ease(progress, ease_name_to_param(ease_name))


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
    if values[0] is float or values[0] is int:
        weighted_average = 0.0
    elif values[0] is Vector2:
        weighted_average = Vector2.ZERO
    elif values[0] is Vector3:
        weighted_average = Vector3.ZERO
    else:
        ScaffolderLog.static_error()
    
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


func take_screenshot() -> void:
    if !ensure_directory_exists("user://screenshots"):
        return
    
    var image := get_viewport().get_texture().get_data()
    image.flip_y()
    var path := "user://screenshots/screenshot-%s.png" % get_datetime_string()
    var status := image.save_png(path)
    if status != OK:
        Gs.logger.error()


func open_screenshot_folder() -> void:
    var path := OS.get_user_data_dir() + "/screenshots"
    Gs.logger.print("Opening screenshot folder: " + path)
    OS.shell_open(path)


func ensure_directory_exists(path: String) -> bool:
    var directory := Directory.new()
    var status := directory.make_dir_recursive(path)
    if status != OK:
        Gs.logger.error("make_dir_recursive failed: " + str(status))
        return false
    return true


func clear_directory(
        path: String,
        also_deletes_directory := false) -> void:
    # Open directory.
    var directory := Directory.new()
    var status := directory.open(path)
    if status != OK:
        Gs.logger.error()
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
                Gs.logger.error("Failed to delete file", false)
        file_name = directory.get_next()
    
    # Delete directory.
    if also_deletes_directory:
        status = directory.remove(path)
        if status != OK:
            Gs.logger.error("Failed to delete directory", false)


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


static func get_collection_from_exclusions_and_inclusions(
        default: Array,
        exclusions: Array,
        inclusions: Array) -> Array:
    var inclusions_set := {}
    for inclusion in inclusions_set:
        inclusions_set[inclusion] = true
    
    var exclusions_set := {}
    for exclusion in exclusions:
        exclusions_set[exclusion] = true
    
    var collection := []
    
    for item in default:
        if inclusions_set.has(item) or \
                exclusions_set.has(item):
            continue
        collection.push_back(item)
    
    for item in inclusions:
        collection.push_back(item)
    
    return collection


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

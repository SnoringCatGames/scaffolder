class_name Utils
extends Node


const MAX_INT := 9223372036854775807

signal display_resized

var _ios_model_names
var _ios_resolutions
var _focus_releaser: Control


func _init() -> void:
    Gs.logger.print("Utils._init")
    
    _ios_model_names = IosModelNames.new()
    _ios_resolutions = IosResolutions.new()
    
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


static func get_which_wall_collided_for_body(body: KinematicBody2D) -> int:
    if body.is_on_wall():
        for i in body.get_slide_count():
            var collision := body.get_slide_collision(i)
            var side := get_which_surface_side_collided(collision)
            if side == SurfaceSide.LEFT_WALL or side == SurfaceSide.RIGHT_WALL:
                return side
    return SurfaceSide.NONE


static func get_which_surface_side_collided(
        collision: KinematicCollision2D) -> int:
    if abs(collision.normal.angle_to(Gs.geometry.UP)) <= \
            Gs.geometry.FLOOR_MAX_ANGLE:
        return SurfaceSide.FLOOR
    elif abs(collision.normal.angle_to(Gs.geometry.DOWN)) <= \
            Gs.geometry.FLOOR_MAX_ANGLE:
        return SurfaceSide.CEILING
    elif collision.normal.x > 0:
        return SurfaceSide.LEFT_WALL
    else:
        return SurfaceSide.RIGHT_WALL


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


static func get_is_android_device() -> bool:
    return OS.get_name() == "Android"


static func get_is_ios_device() -> bool:
    return OS.get_name() == "iOS"


static func get_is_browser() -> bool:
    return OS.get_name() == "HTML5"


static func get_is_windows_device() -> bool:
    return OS.get_name() == "Windows"


static func get_is_mac_device() -> bool:
    return OS.get_name() == "OSX"


static func get_is_linux_device() -> bool:
    return OS.get_name() == "X11"


static func get_is_pc_device() -> bool:
    return get_is_windows_device() or \
            get_is_mac_device() or \
            get_is_linux_device()


static func get_is_mobile_device() -> bool:
    return get_is_android_device() or get_is_ios_device()


static func get_model_name() -> String:
    return IosModelNames.get_model_name() if \
        get_is_ios_device() else \
        OS.get_model_name()


func get_screen_scale() -> float:
    # NOTE: OS.get_screen_scale() is only implemented for MacOS, so it's
    #       useless.
    if get_is_mobile_device():
        if OS.window_size.x < OS.window_size.y:
            return OS.window_size.x / get_viewport().size.x
        else:
            return OS.window_size.y / get_viewport().size.y
    elif get_is_mac_device():
        return OS.get_screen_scale()
    else:
        return 1.0


# This does not take into account the screen scale. Node.get_viewport().size
# likely returns a smaller number than OS.window_size, because of screen scale.
func get_screen_ppi() -> int:
    if get_is_ios_device():
        return _get_ios_screen_ppi()
    else:
        return OS.get_screen_dpi()


func _get_ios_screen_ppi() -> int:
    return _ios_resolutions.get_screen_ppi(_ios_model_names)


# This takes into account the screen scale, and should enable accurate
# conversion of event positions from pixels to inches.
# 
# NOTE: This assumes that the viewport takes up the entire screen, which will
#       likely be true only for mobile devices, and is not even guaranteed for
#       them.
func get_viewport_ppi() -> float:
    return get_screen_ppi() / get_screen_scale()


func get_viewport_size_inches() -> Vector2:
    return get_viewport().size / get_viewport_ppi()


func get_viewport_diagonal_inches() -> float:
    return get_viewport_size_inches().length()


func get_viewport_safe_area() -> Rect2:
    var os_safe_area := OS.get_window_safe_area()
    return Rect2(
            os_safe_area.position / get_screen_scale(),
            os_safe_area.size / get_screen_scale())


func get_safe_area_margin_top() -> float:
    return get_viewport_safe_area().position.y


func get_safe_area_margin_bottom() -> float:
    return get_viewport().size.y - get_viewport_safe_area().end.y


func get_safe_area_margin_left() -> float:
    return get_viewport_safe_area().position.x


func get_safe_area_margin_right() -> float:
    return get_viewport().size.x - OS.get_window_safe_area().end.x


static func floor_vector(v: Vector2) -> Vector2:
    return Vector2(floor(v.x), floor(v.y))


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
        push_error("Unable to open file: " + path)
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
            if !(child is Button):
                child.mouse_filter = mouse_filter
        set_mouse_filter_recursively(child, mouse_filter)


# Automatically resize the gui to adapt to different screen sizes.
func _scale_gui_for_current_screen_size(gui) -> void:
    if !is_instance_valid(gui) or \
            !Gs.gui.guis_to_scale.has(gui):
        Gs.logger.error()
        return
    
    Gs.utils._scale_gui_recursively(gui)


func _scale_gui_recursively(gui) -> void:
    if gui.has_method("update_gui_scale"):
        var handled: bool = gui.update_gui_scale()
        if handled:
            return
    
    assert(gui is Control)
    var control: Control = gui
    var scale: float = Gs.gui.scale
    
    _record_gui_original_simple_dimensions(control)
    
    if control is VBoxContainer or \
            control is HBoxContainer:
        var original_separation: float = \
                control.get_meta("gs_separation") if \
                control.has_meta("gs_separation") else \
                INF
        var separation := round(original_separation * scale)
        control.add_constant_override("separation", separation)
    
    if control is MarginContainer:
        var original_margin_right: float = \
                control.get_meta("gs_margin_right") if \
                control.has_meta("gs_margin_right") else \
                INF
        var original_margin_top: float = \
                control.get_meta("gs_margin_top") if \
                control.has_meta("gs_margin_top") else \
                INF
        var original_margin_left: float = \
                control.get_meta("gs_margin_left") if \
                control.has_meta("gs_margin_left") else \
                INF
        var original_margin_bottom: float = \
                control.get_meta("gs_margin_bottom") if \
                control.has_meta("gs_margin_bottom") else \
                INF
        var margin_right := round(original_margin_right * scale)
        control.add_constant_override("margin_right", margin_right)
        var margin_top := round(original_margin_top * scale)
        control.add_constant_override("margin_top", margin_top)
        var margin_left := round(original_margin_left * scale)
        control.add_constant_override("margin_left", margin_left)
        var margin_bottom := round(original_margin_bottom * scale)
        control.add_constant_override("margin_bottom", margin_bottom)
    
    if control.has_meta("gs_rect_min_size"):
        control.rect_min_size = control.get_meta("gs_rect_min_size") * scale
    if control.has_meta("gs_rect_size"):
        control.rect_size = control.get_meta("gs_rect_size") * scale
    if control.has_meta("gs_rect_scale"):
        control.rect_scale = control.get_meta("gs_rect_scale") * scale
    
    for child in control.get_children():
        if child is Control:
            _scale_gui_recursively(child)


func _record_gui_original_simple_dimensions(control: Control) -> void:
    if control is VBoxContainer or \
            control is HBoxContainer:
        if !control.has_meta("gs_separation"):
            control.set_meta(
                    "gs_separation",
                    control.get_constant("separation"))
    if control is MarginContainer:
        if !control.has_meta("gs_margin_right"):
            control.set_meta(
                    "gs_margin_right",
                    control.get_constant("margin_right"))
        if !control.has_meta("gs_margin_top"):
            control.set_meta(
                    "gs_margin_top",
                    control.get_constant("margin_top"))
        if !control.has_meta("gs_margin_left"):
            control.set_meta(
                    "gs_margin_left",
                    control.get_constant("margin_left"))
        if !control.has_meta("gs_margin_bottom"):
            control.set_meta(
                    "gs_margin_bottom",
                    control.get_constant("margin_bottom"))


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


func create_stylebox_flat_scalable(config) -> StyleBoxFlatScalable:
    if config is Color:
        var stylebox := StyleBoxFlatScalable.new()
        stylebox.bg_color = config
        stylebox.ready()
        return stylebox
    elif config is Dictionary:
        return _create_stylebox_flat_scalable_from_config(config)
    elif config is StyleBox:
        return _create_stylebox_flat_scalable_from_stylebox(config)
    else:
        Gs.logger.error()
        return null


func _create_stylebox_flat_scalable_from_config(
        config: Dictionary) -> StyleBoxFlatScalable:
    var stylebox: StyleBoxFlatScalable
    if config.has("stylebox"):
        stylebox = _create_stylebox_flat_scalable_from_stylebox(
                config.stylebox)
    else:
        stylebox = StyleBoxFlatScalable.new()
    
    if config.has("bg_color"):
        stylebox.bg_color = config.bg_color
    if config.has("border_width"):
        stylebox.border_width_left = config.border_width
        stylebox.border_width_top = config.border_width
        stylebox.border_width_right = config.border_width
        stylebox.border_width_bottom = config.border_width
    if config.has("content_margin"):
        stylebox.content_margin_left = config.content_margin
        stylebox.content_margin_top = config.content_margin
        stylebox.content_margin_right = config.content_margin
        stylebox.content_margin_bottom = config.content_margin
    if config.has("corner_detail"):
        stylebox.corner_detail = config.corner_detail
    if config.has("corner_radius"):
        stylebox.corner_radius_top_left = config.corner_radius
        stylebox.corner_radius_top_right = config.corner_radius
        stylebox.corner_radius_bottom_left = config.corner_radius
        stylebox.corner_radius_bottom_right = config.corner_radius
    if config.has("expand_margin"):
        stylebox.expand_margin_left = config.expand_margin
        stylebox.expand_margin_top = config.expand_margin
        stylebox.expand_margin_right = config.expand_margin
        stylebox.expand_margin_bottom = config.expand_margin
    if config.has("shadow_color"):
        stylebox.shadow_color = config.shadow_color
    if config.has("shadow_offset"):
        stylebox.shadow_offset = config.shadow_offset
    if config.has("shadow_size"):
        stylebox.shadow_size = config.shadow_size
    stylebox.ready()
    return stylebox


func _create_stylebox_flat_scalable_from_stylebox(
        old: StyleBox) -> StyleBoxFlatScalable:
    var new := StyleBoxFlatScalable.new()
    
    new.expand_margin_left = old.expand_margin_left
    new.expand_margin_top = old.expand_margin_top
    new.expand_margin_right = old.expand_margin_right
    new.expand_margin_bottom = old.expand_margin_bottom
    
    if old is StyleBoxFlat:
        new.anti_aliasing = old.anti_aliasing
        new.anti_aliasing_size = old.anti_aliasing_size
        new.bg_color = old.bg_color
        new.border_blend = old.border_blend
        new.border_color = old.border_color
        new.border_width_left = old.border_width_left
        new.border_width_top = old.border_width_top
        new.border_width_right = old.border_width_right
        new.border_width_bottom = old.border_width_bottom
        new.content_margin_left = old.content_margin_left
        new.content_margin_top = old.content_margin_top
        new.content_margin_right = old.content_margin_right
        new.content_margin_bottom = old.content_margin_bottom
        new.corner_detail = old.corner_detail
        new.corner_radius_top_left = old.corner_radius_top_left
        new.corner_radius_top_right = old.corner_radius_top_right
        new.corner_radius_bottom_left = old.corner_radius_bottom_left
        new.corner_radius_bottom_right = old.corner_radius_bottom_right
        new.draw_center = old.draw_center
        new.shadow_color = old.shadow_color
        new.shadow_offset = old.shadow_offset
        new.shadow_size = old.shadow_size
    
    new.ready()
    return new


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

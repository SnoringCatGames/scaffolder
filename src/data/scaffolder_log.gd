class_name ScaffolderLog
extends Node


var _print_queue := []


func _enter_tree() -> void:
    name = "ScaffolderLog"
    _print_front_matter()
    self.print("ScaffolderLog._enter_tree")


func print(message: String) -> void:
    if is_instance_valid(Gs.gui) and \
            is_instance_valid(Gs.gui.debug_panel):
        Gs.gui.debug_panel.add_message(message)
    else:
        _print_queue.push_back(message)
    
    if !is_instance_valid(Gs.app_metadata) or \
            Gs.app_metadata.also_prints_to_stdout:
        print(message)


func error(
        message := "An error occurred",
        should_assert := true) -> void:
    push_error("ERROR: %s" % message)
    self.print("**ERROR**: %s" % message)
    if should_assert:
         assert(false)


static func static_error(
        message := "An error occurred",
        should_assert := true) -> void:
    push_error("ERROR: %s" % message)
    if should_assert:
         assert(false)


func warning(message := "An warning occurred") -> void:
    push_warning("WARNING: %s" % message)
    self.print("**WARNING**: %s" % message)


func on_global_init(global: Node, name: String) -> void:
    global.name = name
    print("%s._init" % name)


func _print_front_matter() -> void:
    self.print(
            "**THIS SHOULD BE THE FIRST LINE PRINTED FROM GDSCRIPT IN " +
            "THE APP**")
    self.print(
            "If not, then you should refactor how you're using the " +
            "Scaffolder framework, so that your custom classes are " +
            "instantiated later.")
    self.print("")
    self.print(get_datetime_string())
    self.print((
        "%s " +
        "%s " +
        "(%4d,%4d) " +
        ""
    ) % [
        OS.get_name(),
        OS.get_model_name(),
        get_viewport().size.x,
        get_viewport().size.y,
    ])
    self.print("")


# NOTE: Keep this in-sync with the duplicate function in Utils.
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

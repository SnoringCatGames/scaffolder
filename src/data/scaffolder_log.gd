tool
class_name ScaffolderLog
extends Node


var _print_queue := []


func _ready() -> void:
    _print_front_matter()
    self.on_global_init(self, "ScaffolderLog")


func print(message: String) -> void:
    if is_instance_valid(Sc.gui) and \
            is_instance_valid(Sc.gui.debug_panel):
        Sc.gui.debug_panel.add_message(message)
    else:
        _print_queue.push_back(message)
    
    if (!is_instance_valid(Sc.metadata) or \
            Sc.metadata.also_prints_to_stdout) and \
            !Engine.editor_hint:
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


func on_global_init(
        global: Node,
        name: String,
        expect_is_tool := true) -> void:
    global.name = name
    
    if Sc._manifest.empty() and \
            Sc._LOGS_EARLY_BOOTSTRAP_EVENTS or \
            !Sc._manifest.empty() and \
            Sc._manifest.metadata.logs_bootstrap_events:
        self.print("%s._init" % name)
    
    if Engine.editor_hint and \
            expect_is_tool and \
            is_instance_valid(Sc.utils):
        assert(Sc.utils.check_whether_sub_classes_are_tools(global))


func _print_front_matter() -> void:
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
    if Sc._LOGS_EARLY_BOOTSTRAP_EVENTS:
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

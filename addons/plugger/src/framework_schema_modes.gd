tool
class_name FrameworkSchemaModes
extends Node


signal mode_changed(mode_name, mode_option)

# Dictionary<String, Array<String>>
var options := {}

# Dictionary<String, String>
var _active := {}

# Dictionary<String, Color>
var colors := {}


func register_mode(
        name: String,
        options: Array,
        default: String,
        color: Color) -> void:
    assert(!self.options.has(name))
    assert(options.find(default) >= 0)
    self.options[name] = options
    self._active[name] = default
    self.colors[name] = color


func register_mode_option(
        name: String,
        option: String) -> void:
    assert(self.options.has(name) and \
            self.options[name].find(option) < 0)
    self.options[name].push_back(option)


func set_mode(
        name: String,
        option: String) -> void:
    assert(self.options.has(name) and \
            self.options[name].find(option) >= 0)
    self._active[name] = option
    emit_signal("mode_changed", name, option)


func get_mode(name: String) -> String:
    return self._active[name]


func get_is_active(
        name: String,
        option: String) -> bool:
    assert(self.options[name].find(option) >= 0)
    return self._active[name] == option


func load_from_json() -> void:
    var _active_modes: Dictionary = Sc.json.load_file(
            ScaffolderMetadata.MODES_PATH,
            true,
            true)
    for mode_name in _active_modes:
        var mode_option = _active_modes[mode_name]
        if !options.has(mode_name):
            Sc.logger.warning(
                    "Invalid mode name saved in JSON: %s" % str(mode_name))
            continue
        if options[mode_name].find(mode_option) < 0:
            Sc.logger.warning(
                    "Invalid mode option saved in JSON: %s" % str(mode_option))
            continue
        self._active[mode_name] = mode_option


func save_to_json() -> void:
    Sc.json.save_file(
            self._active,
            ScaffolderMetadata.MODES_PATH,
            true,
            true)


func _clear() -> void:
    self.options.clear()
    self._active.clear()

tool
class_name Singletons
extends Reference


# Dictionary<Script, Variant>
const _SCRIPT_INSTANCES := {}

# Dictionary<Variant, Variant>
const _VALUES := {}


static func instance(script_or_path):
    var script: Script
    if script_or_path is String:
        script = load(script_or_path)
    else:
        script = script_or_path
    
    if _SCRIPT_INSTANCES.has(script):
        return _SCRIPT_INSTANCES[script]
    else:
        var instance = script.new()
        _SCRIPT_INSTANCES[script] = instance
        return instance


static func has_value(key) -> bool:
    return _VALUES.has(key)


static func get_value(key):
    return _VALUES[key]


static func set_value(key, value) -> void:
    _VALUES[key] = value

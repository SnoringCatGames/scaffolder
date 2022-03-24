tool
class_name Singletons
extends Reference


# Dictionary<Script, Variant>
const _SCRIPT_INSTANCES_KEY := "Singletons_SCRIPT_INSTANCES"
# Dictionary<Variant, Variant>
const _VALUES_KEY := "Singletons_VALUES"

# - This is a hack.
# - But it is a safe way to ensure that our singletons registry is never
#   unloaded as long as the app is running.
const _KNOWN_EXTERNAL_SINGLETON := Engine


static func instance(script_or_path):
    var script: Script
    if script_or_path is String:
        script = load(script_or_path)
    else:
        script = script_or_path
    
    var script_instances := _get_script_instances()
    
    if !script_instances.has(script):
        var instance = script.new()
        script_instances[script] = instance
    
    return script_instances[script]


static func has_value(key) -> bool:
    return _get_values().has(key)


static func get_value(key):
    return _get_values()[key]


static func set_value(key, value) -> void:
    _get_values()[key] = value


static func _get_script_instances() -> Dictionary:
    if !_KNOWN_EXTERNAL_SINGLETON.has_meta(_SCRIPT_INSTANCES_KEY):
        _KNOWN_EXTERNAL_SINGLETON.set_meta(_SCRIPT_INSTANCES_KEY, {})
    return _KNOWN_EXTERNAL_SINGLETON.get_meta(_SCRIPT_INSTANCES_KEY)


static func _get_values() -> Dictionary:
    if !_KNOWN_EXTERNAL_SINGLETON.has_meta(_VALUES_KEY):
        _KNOWN_EXTERNAL_SINGLETON.set_meta(_VALUES_KEY, {})
    return _KNOWN_EXTERNAL_SINGLETON.get_meta(_VALUES_KEY)

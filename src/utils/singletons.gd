tool
class_name Singletons
extends Reference


# Dictionary<Script, Variant>
const _SINGLETONS := {}


static func instance(script_or_path):
    var script: Script
    if script_or_path is String:
        script = load(script_or_path)
    else:
        script = script_or_path
    
    if _SINGLETONS.has(script):
        return _SINGLETONS[script]
    else:
        var instance = script.new()
        _SINGLETONS[script] = instance
        return instance

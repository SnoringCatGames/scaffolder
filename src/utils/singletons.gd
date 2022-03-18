tool
class_name Singletons
extends Reference


# Dictionary<Script, Variant>
const _SINGLETONS := {}


static func instance(script: Script):
    if _SINGLETONS.has(script):
        return _SINGLETONS[script]
    else:
        var instance = script.new()
        _SINGLETONS[script] = instance
        return instance

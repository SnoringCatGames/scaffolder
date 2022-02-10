class_name CharacterLogType


enum {
    UNKNOWN,
    ACTION,
    SURFACE,
    COLLISION,
    NAVIGATOR,
    BEHAVIOR,
    DEFAULT,
    CUSTOM,
}


static func get_string(type: int) -> String:
    match type:
        UNKNOWN:
            return "UNKNOWN"
        ACTION:
            return "ACTION"
        SURFACE:
            return "SURFACE"
        COLLISION:
            return "COLLISION"
        NAVIGATOR:
            return "NAVIGATOR"
        BEHAVIOR:
            return "BEHAVIOR"
        DEFAULT:
            return "DEFAULT"
        CUSTOM:
            return "CUSTOM"
        _:
            ScaffolderLog.static_error("CharacterLogType.get_string")
            return ""


static func get_prefix(type: int) -> String:
    match type:
        UNKNOWN:
            return "UNK"
        ACTION:
            return "ACT"
        SURFACE:
            return "SUR"
        COLLISION:
            return "COL"
        NAVIGATOR:
            return "NAV"
        BEHAVIOR:
            return "BEH"
        DEFAULT:
            return "DEF"
        CUSTOM:
            return "CUS"
        _:
            ScaffolderLog.static_error("CharacterLogType.get_prefix")
            return ""


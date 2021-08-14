class_name PlayerLogType


enum {
    UNKNOWN,
    ACTION,
    SURFACE,
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
        NAVIGATOR:
            return "NAVIGATOR"
        BEHAVIOR:
            return "BEHAVIOR"
        DEFAULT:
            return "DEFAULT"
        CUSTOM:
            return "CUSTOM"
        _:
            ScaffolderLog.static_error()
            return ""


static func get_prefix(type: int) -> String:
    match type:
        UNKNOWN:
            return "UNK"
        ACTION:
            return "ACT"
        SURFACE:
            return "SUR"
        NAVIGATOR:
            return "NAV"
        BEHAVIOR:
            return "BEH"
        DEFAULT:
            return "DEF"
        CUSTOM:
            return "CUS"
        _:
            ScaffolderLog.static_error()
            return ""


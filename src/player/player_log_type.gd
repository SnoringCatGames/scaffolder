class_name PlayerLogType


enum {
    UNKNOWN,
    ACTION,
    SURFACE,
    NAVIGATOR,
    BEHAVIOR,
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
        CUSTOM:
            return "CUSTOM"
        _:
            ScaffolderLog.static_error()
            return ""


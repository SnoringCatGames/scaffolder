class_name NotificationSize


enum {
    UNKNOWN,
    SMALL,
    MEDIUM,
    LARGE,
    FULL_WIDTH,
    FULL_SCREEN,
}


static func get_string(type: int) -> String:
    match type:
        SMALL:
            return "SMALL"
        MEDIUM:
            return "MEDIUM"
        LARGE:
            return "LARGE"
        FULL_WIDTH:
            return "FULL_WIDTH"
        FULL_SCREEN:
            return "FULL_SCREEN"
        UNKNOWN, \
        _:
            Sc.logger.error("NotificationSize.get_string")
            return ""


static func get_prefix(type: int) -> String:
    match type:
        SMALL:
            return "S"
        MEDIUM:
            return "M"
        LARGE:
            return "L"
        FULL_WIDTH:
            return "FULL_WIDTH"
        FULL_SCREEN:
            return "FULL_SCREEN"
        UNKNOWN, \
        _:
            Sc.logger.error("NotificationSize.get_prefix")
            return ""

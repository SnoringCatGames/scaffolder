class_name NotificationsSize


enum {
    UNKNOWN,
    SMALL,
    MEDIUM,
    LARGE,
    TOP_SIDE,
    BOTTOM_SIDE,
    LEFT_SIDE,
    RIGHT_SIDE,
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
        TOP_SIDE:
            return "TOP_SIDE"
        BOTTOM_SIDE:
            return "BOTTOM_SIDE"
        LEFT_SIDE:
            return "LEFT_SIDE"
        RIGHT_SIDE:
            return "RIGHT_SIDE"
        FULL_SCREEN:
            return "FULL_SCREEN"
        UNKNOWN, \
        _:
            Sc.logger.error("NotificationsSize.get_string")
            return ""


static func get_prefix(type: int) -> String:
    match type:
        SMALL:
            return "S"
        MEDIUM:
            return "M"
        LARGE:
            return "L"
        TOP_SIDE:
            return "TOP_SIDE"
        BOTTOM_SIDE:
            return "BOTTOM_SIDE"
        LEFT_SIDE:
            return "LEFT_SIDE"
        RIGHT_SIDE:
            return "RIGHT_SIDE"
        FULL_SCREEN:
            return "FULL_SCREEN"
        UNKNOWN, \
        _:
            Sc.logger.error("NotificationsSize.get_prefix")
            return ""

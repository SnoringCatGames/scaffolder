class_name NotificationDuration


enum {
    UNKNOWN,
    SHORT,
    LONG,
    CLOSED_WITH_CLOSE_BUTTON,
    CLOSED_WITH_TAP_ANYWHERE,
    CLOSED_WITH_CODE,
}


static func get_string(type: int) -> String:
    match type:
        SHORT:
            return "SHORT"
        LONG:
            return "LONG"
        CLOSED_WITH_CLOSE_BUTTON:
            return "CLOSED_WITH_CLOSE_BUTTON"
        CLOSED_WITH_TAP_ANYWHERE:
            return "CLOSED_WITH_TAP_ANYWHERE"
        CLOSED_WITH_CODE:
            return "CLOSED_WITH_CODE"
        UNKNOWN, \
        _:
            Sc.logger.error("NotificationDuration.get_string")
            return ""


static func get_prefix(type: int) -> String:
    match type:
        SHORT:
            return "SHORT"
        LONG:
            return "LONG"
        CLOSED_WITH_CLOSE_BUTTON:
            return "CLOSED_WITH_CLOSE_BUTTON"
        CLOSED_WITH_TAP_ANYWHERE:
            return "CLOSED_WITH_TAP_ANYWHERE"
        CLOSED_WITH_CODE:
            return "CLOSED_WITH_CODE"
        UNKNOWN, \
        _:
            Sc.logger.error("NotificationDuration.get_prefix")
            return ""

class_name ScreenTransition


enum {
    DEFAULT,
    FANCY,
    IMMEDIATE,
    SLIDE,
    FADE,
    OVERLAY_MASK,
    SCREEN_MASK,
}


static func type_to_string(type: int) -> String:
    match type:
        DEFAULT:
            return "DEFAULT"
        FANCY:
            return "FANCY"
        IMMEDIATE:
            return "IMMEDIATE"
        SLIDE:
            return "SLIDE"
        FADE:
            return "FADE"
        OVERLAY_MASK:
            return "OVERLAY_MASK"
        SCREEN_MASK:
            return "SCREEN_MASK"
        _:
            ScaffolderLog.static_error("Invalid ScreenTransition: %d" % type)
            return ""

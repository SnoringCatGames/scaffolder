class_name PlayerBehaviorType


enum {
    REST,
    FOLLOW,
    COLLIDE,
    RUN_AWAY,
    # FIXME: ------------ Use
    WANDER,
    RETURN,
    USER_NAVIGATE,
    CHOREOGRAPHY,
    CUSTOM,
}


static func type_to_string(type: int) -> String:
    match type:
        REST:
            return "REST"
        FOLLOW:
            return "FOLLOW"
        COLLIDE:
            return "COLLIDE"
        RUN_AWAY:
            return "RUN_AWAY"
        WANDER:
            return "WANDER"
        RETURN:
            return "RETURN"
        USER_NAVIGATE:
            return "USER_NAVIGATE"
        CHOREOGRAPHY:
            return "CHOREOGRAPHY"
        CUSTOM:
            return "CUSTOM"
        _:
            ScaffolderLog.static_error("Invalid PlayerBehaviorType: %d" % type)
            return ""
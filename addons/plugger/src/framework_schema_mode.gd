tool
class_name FrameworkSchemaMode
extends Reference


enum {
    UNKNOWN,
    RELEASE,
    THREADING,
    ANNOTATIONS,
    UI_SMOOTHNESS,
}

enum Release {
    UNKNOWN,
    LOCAL_DEV,
    PLAYTEST,
    PRODUCTION,
}

enum Threading {
    UNKNOWN,
    ENABLED,
    DISABLED,
}

enum Annotations {
    UNKNOWN,
    DEFAULT,
    EMPHASIZED,
}

enum UiSmoothness {
    UNKNOWN,
    PIXELATED,
    ANTI_ALIASED,
}

const MODE_TYPES := [
    RELEASE,
    THREADING,
    ANNOTATIONS,
    UI_SMOOTHNESS,
]

const RELEASE_TYPE_TO_STRING := {
    Release.LOCAL_DEV: "LOCAL_DEV",
    Release.PLAYTEST: "PLAYTEST",
    Release.PRODUCTION: "PRODUCTION",
}

const THREADING_TYPE_TO_STRING := {
    Threading.ENABLED: "ENABLED",
    Threading.DISABLED: "DISABLED",
}

const ANNOTATIONS_TYPE_TO_STRING := {
    Annotations.DEFAULT: "DEFAULT",
    Annotations.EMPHASIZED: "EMPHASIZED",
}

const UI_SMOOTHNESS_TYPE_TO_STRING := {
    UiSmoothness.PIXELATED: "PIXELATED",
    UiSmoothness.ANTI_ALIASED: "ANTI_ALIASED",
}

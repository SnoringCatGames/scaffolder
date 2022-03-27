tool
class_name ColorFactory
extends Reference
## FIXME: ------------- Doc comment.


static func rgb(
        r: float,
        g: float,
        b: float,
        a := 1.0) -> StaticColorConfig:
    return color(Color(r, g, b, a))


static func hsv(
        h: float,
        s: float,
        v: float,
        a := 1.0) -> StaticColorConfig:
    var color_config = StaticColorConfig.new()
    color_config.h = h
    color_config.s = s
    color_config.v = v
    color_config.a = a
    return color_config


static func color(color: Color) -> StaticColorConfig:
    var color_config = StaticColorConfig.new()
    color_config.h = color.h
    color_config.s = color.s
    color_config.v = color.v
    color_config.a = color.a
    return color_config


static func hsv_range(
        h_min: float,
        h_max: float,
        s_min: float,
        s_max: float,
        v_min: float,
        v_max: float,
        a_min := 1.0,
        a_max := 1.0) -> HsvRangeColorConfig:
    var color_config = HsvRangeColorConfig.new()
    color_config.h_min = h_min
    color_config.h_max = h_max
    color_config.s_min = s_min
    color_config.s_max = s_max
    color_config.v_min = v_min
    color_config.v_max = v_max
    color_config.a_min = a_min
    color_config.a_max = a_max
    return color_config


static func h_range(
        h_min: float,
        h_max: float,
        s: float,
        v: float,
        a := 1.0) -> HsvRangeColorConfig:
    return hsv_range(h_min, h_max, s, s, v, v, a, a)


static func palette(key: String) -> PaletteColorConfig:
    var color_config := PaletteColorConfig.new()
    color_config.key = key
    return color_config


static func opacify(
        key: String,
        alpha: float) -> PaletteColorConfig:
    var color_config := PaletteColorConfig.new()
    color_config.key = key
    color_config.a = alpha
    return color_config

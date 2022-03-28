tool
class_name ColorFactory
extends Reference
## This is a collection of convenience factory functions for instantiating[br]
## ColorConfigs.


static func rgb(
        r: float,
        g: float,
        b: float,
        a := 1.0) -> ColorConfig:
    return color(Color(r, g, b, a))


static func hsv(
        h: float,
        s: float,
        v: float,
        a := 1.0) -> ColorConfig:
    var color_config = StaticColorConfig.new()
    color_config.h = h
    color_config.s = s
    color_config.v = v
    color_config.a = a
    return color_config


static func color(color: Color) -> ColorConfig:
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
        a_max := 1.0) -> ColorConfig:
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
        a := 1.0) -> ColorConfig:
    return hsv_range(h_min, h_max, s, s, v, v, a, a)


static func palette(key: String) -> ColorConfig:
    var color_config := PaletteColorConfig.new()
    color_config.key = key
    return color_config


static func delta(
        key: String,
        delta: Dictionary) -> ColorConfig:
    var color_config := PaletteColorConfig.new()
    color_config.key = key
    var color := color_config.sample()
    if delta.has("h"):
        color_config.h_delta = delta.h
    if delta.has("s"):
        color_config.s_delta = delta.s
    if delta.has("v"):
        color_config.v_delta = delta.v
    if delta.has("a"):
        color_config.a_delta = delta.a
    return color_config


static func opacify(
        color_or_key,
        alpha: float) -> ColorConfig:
    var color_config: ColorConfig
    if color_or_key is String:
        color_config = PaletteColorConfig.new()
        color_config.key = color_or_key
    elif color_or_key is ColorConfig:
        color_config = color_or_key
    elif color_or_key is Color:
        color_config = color(color_or_key)
    else:
        Sc.logger.error(
            "Invalid value passed to ColorFactory.opacify: %s" % \
            str(color_or_key))
        return transparent()
    color_config.a = alpha
    return color_config


static func transparent() -> ColorConfig:
    return StaticColorConfig.new()

tool
class_name JsonUtils
extends Node


var REGEX_TO_MATCH_TRAILING_ZEROS_AFTER_DECIMAL := RegEx.new()

const _RESOURCE_PREFIX := "$Res:"
const _NAN_TOKEN := "$NAN:"
const _POS_INF_TOKEN := "$+INF:"
const _NEG_INF_TOKEN := "$-INF:"

const _COLOR_CONFIG_KEY := "$ColConf"
const _STATIC_COLOR_CONFIG_TOKEN :=  "static"
const _HSV_RANGE_COLOR_CONFIG_TOKEN :=  "range"
const _PALETTE_COLOR_CONFIG_TOKEN :=  "palette"


func _init() -> void:
    Sc.logger.on_global_init(self, "JsonUtils")
    REGEX_TO_MATCH_TRAILING_ZEROS_AFTER_DECIMAL.compile("\\.0*$")


static func save_file(
        json_object,
        path: String,
        includes_encoding := true,
        includes_newlines := false) -> void:
    if includes_encoding:
        json_object = Sc.json.encode_json_object(json_object)
    var indent := "  " if includes_newlines else ""
    var json_string := JSON.print(json_object, indent)
    
    var file := File.new()
    var status := file.open(path, File.WRITE)
    
    if status != OK:
        ScaffolderLog.static_error("Unable to open file: " + path)
        return
    
    file.store_string(json_string)
    file.close()


static func load_file(
        path: String,
        includes_encoding := true,
        allows_missing_file := false):
    var file := File.new()
    var status := file.open(path, File.READ)
    
    if status != OK:
        if status != ERR_FILE_NOT_FOUND or !allows_missing_file:
            ScaffolderLog.static_error("Unable to open file: " + path)
        return {}
    
    var json_string := file.get_as_text()
    file.close()
    
    if json_string.empty():
        return {}
    
    var parse_result := JSON.parse(json_string)
    if parse_result.error != OK:
        Sc.logger.error("Unable to parse JSON: %s; %s:%s:%s" % [
            path,
            parse_result.error,
            parse_result.error_line,
            parse_result.error_string,
        ])
        return {}
    
    var json_object = parse_result.result
    if includes_encoding:
        json_object = Sc.json.decode_json_object(json_object)
    
    return json_object


# JSON encoding with custom syntax for vector values.
func encode_json_object(value):
    match typeof(value):
        TYPE_BOOL, \
        TYPE_STRING, \
        TYPE_INT, \
        TYPE_NIL:
            return value
        TYPE_REAL:
            return encode_real(value)
        TYPE_VECTOR2:
            return {
                "x": encode_real(value.x),
                "y": encode_real(value.y),
            }
        TYPE_VECTOR3:
            return {
                "x": encode_real(value.x),
                "y": encode_real(value.y),
                "z": encode_real(value.z),
            }
        TYPE_COLOR:
            return {
                "r": value.r,
                "g": value.g,
                "b": value.b,
                "a": value.a,
            }
        TYPE_RECT2:
            return {
                "x": encode_real(value.position.x),
                "y": encode_real(value.position.y),
                "w": encode_real(value.size.x),
                "h": encode_real(value.size.y),
            }
        TYPE_ARRAY:
            value = value.duplicate()
            for index in value.size():
                value[index] = encode_json_object(value[index])
            return value
        TYPE_RAW_ARRAY, \
        TYPE_INT_ARRAY, \
        TYPE_REAL_ARRAY, \
        TYPE_STRING_ARRAY, \
        TYPE_VECTOR2_ARRAY, \
        TYPE_VECTOR3_ARRAY, \
        TYPE_COLOR_ARRAY:
            value = Array(value)
            for index in value.size():
                value[index] = encode_json_object(value[index])
            return value
        TYPE_DICTIONARY:
            value = value.duplicate()
            for key in value:
                value[key] = encode_json_object(value[key])
            return value
        TYPE_OBJECT:
            if value is Resource:
                return _RESOURCE_PREFIX + value.resource_path
            elif value is ColorConfig:
                return encode_color_config(value)
            else:
                continue
        _:
            Sc.logger.error("Unsupported data type for JSON: " + str(value))


# JSON decoding with custom syntax for vector values.
func decode_json_object(json):
    match typeof(json):
        TYPE_ARRAY:
            json = json.duplicate()
            for i in json.size():
                json[i] = decode_json_object(json[i])
            return json
        TYPE_DICTIONARY:
            if json.size() == 2 and \
                    json.has("x") and \
                    json.has("y"):
                return Vector2(json.x, json.y)
            elif json.size() == 3 and \
                    json.has("x") and \
                    json.has("y") and \
                    json.has("z"):
                return Vector3(json.x, json.y, json.z)
            elif json.size() == 4 and \
                    json.has("r") and \
                    json.has("g") and \
                    json.has("b") and \
                    json.has("a"):
                return Color(json.r, json.g, json.b, json.a)
            elif json.size() == 4 and \
                    json.has("x") and \
                    json.has("y") and \
                    json.has("w") and \
                    json.has("h"):
                return Rect2(json.x, json.y, json.w, json.h)
            elif json.has(_COLOR_CONFIG_KEY):
                return decode_color_config(json)
            else:
                json = json.duplicate()
                for key in json.keys():
                    # Translate Stringified integer keys back into ints.
                    var int_key := int(key)
                    if str(int_key) == key:
                        var value = json[key]
                        json.erase(key)
                        key = int_key
                        json[key] = value
                    
                    json[key] = decode_json_object(json[key])
                return json
        TYPE_STRING:
            if json == _POS_INF_TOKEN:
                return INF
            elif json == _NEG_INF_TOKEN:
                return -INF
            elif json == _NAN_TOKEN:
                return NAN
            elif json.begins_with(_RESOURCE_PREFIX):
                return load(json.substr(_RESOURCE_PREFIX.length()))
            else:
                continue
        _:
            return json


func encode_color_config(color_config: ColorConfig) -> Dictionary:
    var json_object := {}
    if color_config is StaticColorConfig:
        json_object[_COLOR_CONFIG_KEY] = _STATIC_COLOR_CONFIG_TOKEN
        json_object.c = color_config._color.to_rgba32()
    elif color_config is HsvRangeColorConfig:
        json_object[_COLOR_CONFIG_KEY] = _HSV_RANGE_COLOR_CONFIG_TOKEN
        json_object.min = [
            color_config.h_min,
            color_config.s_min,
            color_config.v_min,
            color_config.a_min,
        ]
        json_object.max = [
            color_config.h_max,
            color_config.s_max,
            color_config.v_max,
            color_config.a_max,
        ]
    elif color_config is PaletteColorConfig:
        json_object[_COLOR_CONFIG_KEY] = _PALETTE_COLOR_CONFIG_TOKEN
        json_object.key = color_config.key
        json_object.o = [
            color_config._h_override,
            color_config._s_override,
            color_config._v_override,
            color_config._a_override,
        ]
        json_object.d = [
            color_config.h_delta,
            color_config.s_delta,
            color_config.v_delta,
            color_config.a_delta,
        ]
    else:
        Sc.logger.error(
            "JsonUtils.encode_color_config: %s" % str(json_object))
    return json_object


func decode_color_config(json_object: Dictionary) -> ColorConfig:
    match json_object[_COLOR_CONFIG_KEY]:
        _STATIC_COLOR_CONFIG_TOKEN:
            var color_config := StaticColorConfig.new()
            color_config._color = Color(int(json_object.c))
            return color_config
        _HSV_RANGE_COLOR_CONFIG_TOKEN:
            var color_config := HsvRangeColorConfig.new()
            color_config.h_min = json_object.min[0]
            color_config.s_min = json_object.min[1]
            color_config.v_min = json_object.min[2]
            color_config.a_min = json_object.min[3]
            color_config.h_max = json_object.max[0]
            color_config.s_max = json_object.max[1]
            color_config.v_max = json_object.max[2]
            color_config.a_max = json_object.max[3]
            return color_config
        _PALETTE_COLOR_CONFIG_TOKEN:
            var color_config := PaletteColorConfig.new()
            color_config.key = json_object.key
            color_config._h_override = json_object.o[0]
            color_config._s_override = json_object.o[1]
            color_config._v_override = json_object.o[2]
            color_config._a_override = json_object.o[3]
            color_config.h_delta = json_object.d[0]
            color_config.s_delta = json_object.d[1]
            color_config.v_delta = json_object.d[2]
            color_config.a_delta = json_object.d[3]
            return color_config
        _:
            Sc.logger.error("JsonUtil.decode_color_config: %s" % \
                str(json_object))
            return null


func encode_real(value: float):
    if is_inf(value):
        if value > 0:
            return _POS_INF_TOKEN
        else:
            return _NEG_INF_TOKEN
    elif is_nan(value):
        return _NAN_TOKEN
    else:
        return value


func decode_real(value: String):
    match value:
        _POS_INF_TOKEN:
            return INF
        _NEG_INF_TOKEN:
            return -INF
        _NAN_TOKEN:
            return NAN
        _:
            return value


func encode_vector2(value: Vector2) -> String:
    return "%s,%s" % [
        str(value.x),
        str(value.y),
    ]


func decode_vector2(value: String) -> Vector2:
    var comma_index := value.find(",")
    return Vector2(
            float(value.substr(0, comma_index)),
            float(value.substr(comma_index + 1)))


func encode_vector3(value: Vector3) -> String:
    return "%s,%s,%s" % [
        str(value.x),
        str(value.y),
        str(value.z),
    ]


func decode_vector3(value: String) -> Vector3:
    var comma_index_1 := value.find(",")
    var comma_index_2 := value.find(",", comma_index_1 + 1)
    return Vector3(
            float(value.substr(0, comma_index_1)),
            float(value.substr(comma_index_1 + 1,
                    comma_index_2 - comma_index_1 - 1)),
            float(value.substr(comma_index_2 + 1)))


func encode_rect2(value: Rect2) -> String:
    return "%s,%s,%s,%s" % [
        str(value.position.x),
        str(value.position.y),
        str(value.size.x),
        str(value.size.y),
    ]


func decode_rect2(value: String) -> Rect2:
    var comma_index_1 := value.find(",")
    var comma_index_2 := value.find(",", comma_index_1 + 1)
    var comma_index_3 := value.find(",", comma_index_2 + 1)
    return Rect2(
            float(value.substr(0, comma_index_1)),
            float(value.substr(comma_index_1 + 1,
                    comma_index_2 - comma_index_1 - 1)),
            float(value.substr(comma_index_2 + 1,
                    comma_index_3 - comma_index_2 - 1)),
            float(value.substr(comma_index_3 + 1)))


func encode_color(value: Color) -> String:
    return "%s,%s,%s,%s" % [
        str(value.r),
        str(value.g),
        str(value.b),
        str(value.a),
    ]


func decode_color(value: String) -> Color:
    var comma_index_1 := value.find(",")
    var comma_index_2 := value.find(",", comma_index_1 + 1)
    var comma_index_3 := value.find(",", comma_index_2 + 1)
    if comma_index_3 >= 0:
        return Color(
                float(value.substr(0, comma_index_1)),
                float(value.substr(comma_index_1 + 1,
                        comma_index_2 - comma_index_1 - 1)),
                float(value.substr(comma_index_2 + 1,
                        comma_index_3 - comma_index_2 - 1)),
                float(value.substr(comma_index_3 + 1)))
    else:
        return Color(
                float(value.substr(0, comma_index_1)),
                float(value.substr(comma_index_1 + 1,
                        comma_index_2 - comma_index_1 - 1)),
                float(value.substr(comma_index_2 + 1)))


func encode_vector2_array(value) -> Array:
    var result := []
    result.resize(value.size())
    for i in value.size():
        result[i] = encode_vector2(value[i])
    return result


func decode_vector2_array(value: Array) -> Array:
    var result := []
    result.resize(value.size())
    for i in value.size():
        result[i] = decode_vector2(value[i])
    return result

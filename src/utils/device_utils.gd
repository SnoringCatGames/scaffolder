tool
class_name DeviceUtils
extends Node


signal display_resized

const JAVASCRIPT_IS_MOBILE_CHECK := """
(function () {
    // This mobile/tablet check is based off of the approach here:
    // https://stackoverflow.com/questions/11381673/detecting-a-mobile-browser/11381730#11381730

    var MOBILE_REGEX_LONG = /(android|bb\\d+|meego).+mobile|avantgo|bada\\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i;
    var MOBILE_REGEX_SHORT = /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\\-(n|u)|c55\\/|capi|ccwa|cdm\\-|cell|chtm|cldc|cmd\\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\\-s|devi|dica|dmob|do(c|p)o|ds(12|\\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\\-|_)|g1 u|g560|gene|gf\\-5|g\\-mo|go(\\.w|od)|gr(ad|un)|haie|hcit|hd\\-(m|p|t)|hei\\-|hi(pt|ta)|hp( i|ip)|hs\\-c|ht(c(\\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\\-(20|go|ma)|i230|iac( |\\-|\\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\\/)|klon|kpt |kwc\\-|kyo(c|k)|le(no|xi)|lg( g|\\/(k|l|u)|50|54|\\-[a-w])|libw|lynx|m1\\-w|m3ga|m50\\/|ma(te|ui|xo)|mc(01|21|ca)|m\\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\\-2|po(ck|rt|se)|prox|psio|pt\\-g|qa\\-a|qc(07|12|21|32|60|\\-[2-7]|i\\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\\-|oo|p\\-)|sdk\\/|se(c(\\-|0|1)|47|mc|nd|ri)|sgh\\-|shar|sie(\\-|m)|sk\\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\\-|v\\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\\-|tdg\\-|tel(i|m)|tim\\-|t\\-mo|to(pl|sh)|ts(70|m\\-|m3|m5)|tx\\-9|up(\\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\\-|your|zeto|zte\\-/i;
    var NON_MOBILE_TABLET_REGEX_LONG = /android|ipad|playbook|silk/i;

    var userAgent = navigator.userAgent || navigator.vendor || window.opera;

    var isMobile =
        MOBILE_REGEX_LONG.test(userAgent) ||
        MOBILE_REGEX_SHORT.test(userAgent.substr(0, 4));
    var isTablet =
        !isMobile &&
        NON_MOBILE_TABLET_REGEX_LONG.test(userAgent);
    
    return isMobile;
})();
"""

var _ios_model_names
var _ios_resolutions

# This is determined according to a regex-check against the browser's useragent
# using the JavaScript embedded above.
var _is_mobile_web := false

# **NOTE**: This will produce false-negatives when checked before the first
#           touch event.
# -   This is hacky, but mostly works.
# -   The basic problem is that Godot has no support for detecting whether the
#     device either has a touch-screen or is a mobile device.
# -   OS.get_name() is insufficient, since it can't differentiate between a
#     browser on Android, Ios, or desktop.
# -   So our workaround is to constantly listen for a touch event. If we ever
#     find one, then we set this flag to true.
# -   Then, our future is-touch-screen checks return true.
var _is_definitely_touch_device := false

var _is_emulating_touch_from_mouse := false
var _is_emulating_mouse_from_touch := false


func _init() -> void:
    Sc.logger.on_global_init(self, "DeviceUtils")
    
    _ios_model_names = IosModelNames.new()
    _ios_resolutions = IosResolutions.new()
    
    _is_emulating_touch_from_mouse = ProjectSettings.get_setting(
            "input_devices/pointing/emulate_touch_from_mouse")
    _is_emulating_mouse_from_touch = ProjectSettings.get_setting(
            "input_devices/pointing/emulate_mouse_from_touch")
    
    if get_is_browser_app():
        _is_mobile_web = JavaScript.eval(JAVASCRIPT_IS_MOBILE_CHECK, true)


static func get_is_android_app() -> bool:
    return OS.get_name() == "Android"


static func get_is_ios_app() -> bool:
    return OS.get_name() == "iOS"


static func get_is_browser_app() -> bool:
    return OS.get_name() == "HTML5"


static func get_is_windows_app() -> bool:
    return OS.get_name() == "Windows"


static func get_is_mac_app() -> bool:
    return OS.get_name() == "OSX"


static func get_is_linux_app() -> bool:
    return OS.get_name() == "X11"


static func get_is_pc_app() -> bool:
    return get_is_windows_app() or \
            get_is_mac_app() or \
            get_is_linux_app()


static func get_is_mobile_app() -> bool:
    return get_is_android_app() or \
            get_is_ios_app()


func get_is_mobile_device() -> bool:
    return get_is_mobile_app() or \
            _is_mobile_web


func get_is_definitely_touch_device() -> bool:
    return _is_definitely_touch_device


static func get_model_name() -> String:
    return IosModelNames.get_model_name() if \
        get_is_ios_app() else \
        OS.get_model_name()


func get_screen_scale() -> float:
    # NOTE: OS.get_screen_scale() is only implemented for MacOS, so it's
    #       useless.
    if get_is_mobile_app():
        if OS.window_size.x < OS.window_size.y:
            return OS.window_size.x / get_viewport().size.x
        else:
            return OS.window_size.y / get_viewport().size.y
    elif get_is_mac_app():
        return OS.get_screen_scale()
    else:
        return 1.0


# This does not take into account the screen scale. Node.get_viewport().size
# likely returns a smaller number than OS.window_size, because of screen scale.
func get_screen_ppi() -> int:
    if get_is_ios_app():
        return _get_ios_screen_ppi()
    else:
        return OS.get_screen_dpi()


func _get_ios_screen_ppi() -> int:
    return _ios_resolutions.get_screen_ppi(_ios_model_names)


# This takes into account the screen scale, and should enable accurate
# conversion of event positions from pixels to inches.
# 
# NOTE: This assumes that the viewport takes up the entire screen, which will
#       likely be true only for mobile devices, and is not even guaranteed for
#       them.
func get_viewport_ppi() -> float:
    return get_screen_ppi() / get_screen_scale()


func get_viewport_size() -> Vector2:
    return get_viewport().size


func get_viewport_size_inches() -> Vector2:
    return get_viewport().size / get_viewport_ppi()


func get_viewport_diagonal_inches() -> float:
    return get_viewport_size_inches().length()


func pixels_to_inches(pixels: float) -> float:
    return pixels / get_viewport_ppi()


func inches_to_pixels(inches: float) -> float:
    return inches * get_viewport_ppi()


func get_viewport_safe_area() -> Rect2:
    var os_safe_area := OS.get_window_safe_area()
    return Rect2(
            os_safe_area.position / get_screen_scale(),
            os_safe_area.size / get_screen_scale())


func get_safe_area_margin_top() -> float:
    return get_viewport_safe_area().position.y


func get_safe_area_margin_bottom() -> float:
    return get_viewport().size.y - get_viewport_safe_area().end.y


func get_safe_area_margin_left() -> float:
    return get_viewport_safe_area().position.x


func get_safe_area_margin_right() -> float:
    return get_viewport().size.x - OS.get_window_safe_area().end.x

tool
class_name GestureReporter
extends Node


const HEADERS := ["Content-Type: application/json"]


func _init() -> void:
    Sc.logger.on_global_init(self, "GestureReporter")


func record_recent_gestures() -> void:
    assert(Sc.gui.is_gesture_logging_supported)
    
    var recent_top_level_events_raw_str := ""
    
    if is_instance_valid(Sc.gui.gesture_record):
        var events: Array = Sc.gui.gesture_record \
                .recent_gesture_events_for_debugging
        for event in events:
            recent_top_level_events_raw_str += event.to_string()
    
    var url: String = Sc.metadata.get_log_gestures_url_with_params()
    
    var body_object := {
        recent_top_level_gesture_events = recent_top_level_events_raw_str,
    }
    var body_str := JSON.print(body_object)
    
    Sc.logger.print("GestureReporter.record_recent_gestures: %s" % url)
    
    if !Sc.metadata.agreed_to_terms or \
            !Sc.metadata.is_data_tracked:
        # User hasn't agreed to data collection.
        Sc.logger.error("GestureReporter.record_recent_gestures")
        return
    
    var request := HTTPRequest.new()
    request.use_threads = true
    request.connect(
            "request_completed",
            self,
            "_on_record_recent_gestures_request_completed",
            [request])
    add_child(request)
    
    var status: int = request.request(
            url,
            HEADERS,
            true,
            HTTPClient.METHOD_POST,
            body_str)
    
    if status != OK:
        Sc.logger.error(
                ("GestureReporter.record_recent_gestures failed: " +
                "status=%d") % status,
                false)


func _on_record_recent_gestures_request_completed(
        result: int,
        response_code: int,
        headers: PoolStringArray,
        body: PoolByteArray,
        request: HTTPRequest) -> void:
    Sc.logger.print(
            ("GestureReporter._on_record_recent_gestures_request_completed: " +
            "result=%d, code=%d") % \
            [result, response_code])
    if result != HTTPRequest.RESULT_SUCCESS or \
            response_code < 200 or \
            response_code >= 300:
        Sc.logger.print("  Body:\n    " + body.get_string_from_utf8())
        Sc.logger.print(
                "  Headers:\n    " + Sc.utils.join(headers, ",\n    "))
    request.queue_free()

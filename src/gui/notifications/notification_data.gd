class_name NotificationData
extends Reference


var header_text := ""
var body_text := ""
var duration := NotificationDuration.UNKNOWN
var size := NotificationsSize.UNKNOWN


func _init(
        header_text := "",
        body_text := "",
        duration := NotificationDuration.SHORT,
        size := NotificationsSize.SMALL) -> void:
    self.header_text = header_text
    self.body_text = body_text
    self.duration = duration
    self.size = size

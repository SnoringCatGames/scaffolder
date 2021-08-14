tool
class_name CrashReporter
extends Node


signal upload_finished

const LOGS_DIRECTORY_PATH := "user://logs"
const ACTIVE_LOG_FILE_NAME := "godot.log"

# Don't report too much data.
const ERROR_LOG_REPORTING_MAX_LINE_COUNT := 500

## We know the app has been initialized once the ScreenNavigator class has
## successfully opened a screen.
#var APP_LOADED_SUCCESSFULLY_LOG_TOKEN_INDICATOR := "Nav.open:"

const APP_ERROR_LOG_TOKEN_REGEX := "(ERROR|Error|error)(\\:|\\*)"

# Skips lines starting with whitespace, since these are usually stacktraces or
# other continuations from the main interesting line that we want to look at.
const LOG_LAST_MESSAGE_COUNT_TO_CHECK_FOR_ERRORS := 5

const HEADERS := ["Content-Type: text/plain"]

const ERROR_EXCLUSION_PATTERNS := [
    "Condition \"_first != __null\" is true",
    "cleanup: ObjectDB instances leaked at exit",
    "Resources still in use at exit",
    "There are still MemoryPool allocs in use at exit!",
]


func _init() -> void:
    Sc.logger.on_global_init(self, "CrashReporter")


func report_any_previous_crash() -> bool:
    _log("CrashReporter.report_any_previous_crash")
    
    if !Sc.metadata.are_error_logs_captured:
        _log("CrashReporter: Error logs not captured for this app")
        return false
    
    var log_file_name := _get_most_recent_log_file_name()
    if log_file_name == "":
        # There are no logs.
        _log("CrashReporter: There are no previous logs to check")
        return false
    
    var log_file_path := LOGS_DIRECTORY_PATH + "/" + log_file_name
    var lines := Utils.get_last_x_lines_from_file(
            log_file_path,
            ERROR_LOG_REPORTING_MAX_LINE_COUNT)
    if lines.empty():
        Sc.logger.error(
                "An error occurred reading the log file: " + log_file_path)
        return false
    
    # Check for an indication of a crash.
    var error_regex := RegEx.new()
    error_regex.compile(APP_ERROR_LOG_TOKEN_REGEX)
    var main_lines_count := 0
    var all_lines_count := 0
    while main_lines_count < LOG_LAST_MESSAGE_COUNT_TO_CHECK_FOR_ERRORS and \
            all_lines_count < lines.size():
        var line: String = lines[lines.size() - 1 - all_lines_count]
        
        if error_regex.search(line) != null and \
                !_does_line_match_an_exclusion_pattern(line):
            # We found an indication of a crash, so report recent logs.
            var text := Utils.join(lines, "\n")
            _upload_crash_log(text, log_file_name)
            Sc.logger.warning(
                    "CrashReporter: Uploading a previous error log")
            return true
        
        all_lines_count += 1
        if !line.begins_with(" ") and \
                !line.begins_with("\t") and \
                line != "":
            main_lines_count += 1
    
    # We didn't find any indication of a crash.
    _log("CrashReporter: There did not seem to be an error in the " +
            "previous session")
    return false


func _does_line_match_an_exclusion_pattern(line: String) -> bool:
    for pattern in ERROR_EXCLUSION_PATTERNS:
        if line.find(pattern) >= 0:
            return true
    return false


func _get_most_recent_log_file_name() -> String:
    if ProjectSettings.get_setting("application/config/name") == "":
        # If the app name isn't configured, then accessing log files will fail.
        return ""
    
    var directory := Directory.new()
    if !directory.dir_exists(LOGS_DIRECTORY_PATH):
        # There are no logs.
        return ""
    var status := directory.open(LOGS_DIRECTORY_PATH)
    if status != OK:
        Sc.logger.error(
                "Unable to open directory: %s" % LOGS_DIRECTORY_PATH)
        return ""
    
    directory.list_dir_begin(true)
    var current_file_name := directory.get_next()
    var most_recent_file_name := current_file_name
    while current_file_name != "":
        if current_file_name != ACTIVE_LOG_FILE_NAME and \
                current_file_name > most_recent_file_name:
            most_recent_file_name = current_file_name
        current_file_name = directory.get_next()
    
    return most_recent_file_name


func _upload_crash_log(
        text: String,
        file_name: String) -> void:
    var url: String = \
            Sc.metadata.error_logs_url + \
            "?uploadType=media&name=" + file_name
    
    Sc.logger.print("CrashReporter._upload_crash_log: %s" % url)
    
    var request := HTTPRequest.new()
    # We specifically don't want to use threads, since the crash we're
    # reporting could recur while this upload is in progress.
    request.use_threads = false
    request.connect(
            "request_completed",
            self,
            "_on_upload_crash_log_completed",
            [request])
    add_child(request)
    
    var status: int = request.request(
            url,
            HEADERS,
            true,
            HTTPClient.METHOD_POST,
            text)
    
    if status != OK:
        Sc.logger.error(
                "CrashReporter._upload_crash_log failed: status=%d" % status)


func _on_upload_crash_log_completed(
        result: int,
        response_code: int,
        headers: PoolStringArray,
        body: PoolByteArray,
        request: HTTPRequest) -> void:
    Sc.logger.print(
            ("CrashReporter._on_upload_crash_log_completed: " +
            "result=%d, code=%d") % \
            [result, response_code])
    if result != HTTPRequest.RESULT_SUCCESS or \
            response_code < 200 or \
            response_code >= 300:
        Sc.logger.warning("  Body:\n    " + body.get_string_from_utf8())
        Sc.logger.warning(
                "  Headers:\n    " + Utils.join(headers, ",\n    "))
    emit_signal("upload_finished")
    request.queue_free()
    self.queue_free()
    Sc.crash_reporter = null


func _log(message: String) -> void:
    if Sc.metadata.logs_bootstrap_events:
        Sc.logger.print(message)

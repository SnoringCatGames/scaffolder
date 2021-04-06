class_name CircularBuffer
extends Reference

var _buffer := []
var _size: int
var _current_count := 0
var _previous_index := -1

func _init(size: int) -> void:
    assert(size > 0)
    _size = size
    _buffer.resize(size)

func push(item) -> void:
    _previous_index = (_previous_index + 1) % _size
    _buffer[_previous_index] = item
    _current_count = min(_current_count + 1, _size)

func pop():
    var item = _buffer[_previous_index]
    _buffer[_previous_index] = null
    _previous_index = (_previous_index - 1 + _size) % _size
    _current_count = max(_current_count - 1, 0)
    return item

func get_items() -> Array:
    var start_index := (_previous_index + 1 - _current_count + _size) % _size
    var result := []
    result.resize(_current_count)
    for i in range(_current_count):
        var index := (i + start_index) % _size
        result[i] = _buffer[index]
    return result

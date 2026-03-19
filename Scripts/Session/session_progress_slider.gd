extends HSlider

var _is_dragging: bool = false
var _active_session_data: SessionData


func _ready() -> void:
	drag_started.connect(_handle_drag_started)
	drag_ended.connect(_handle_drag_ended)


func _process(_delta: float) -> void:
	if !_is_dragging:
		set_value_no_signal(_active_session_data.get_current_time())


func set_session_data(in_session_data: SessionData) -> void:
	_active_session_data = in_session_data
	max_value = _active_session_data.calculate_end_time()


func _handle_drag_started() -> void:
	_is_dragging = true


func _handle_drag_ended(in_value_changed: bool) -> void:
	_is_dragging = false
	if in_value_changed:
		_active_session_data.snap_to_time(value)

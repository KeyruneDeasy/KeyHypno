extends Button

var _active_session_data: SessionData


func _ready() -> void:
	pressed.connect(_handle_pressed)


func set_session_data(in_session_data: SessionData) -> void:
	if _active_session_data != null:
		_active_session_data.on_session_started.disconnect(_handle_session_started)
		_active_session_data.on_session_end_reached.disconnect(_handle_session_end_reached)
		_active_session_data.on_snap_to_time.disconnect(_handle_snap_to_time)
		
	_active_session_data = in_session_data
	
	if _active_session_data != null:
		_active_session_data.on_session_started.connect(_handle_session_started)
		_active_session_data.on_session_end_reached.connect(_handle_session_end_reached)
		_active_session_data.on_snap_to_time.connect(_handle_snap_to_time)


func _refresh() -> void:
	if _active_session_data.is_at_end():
		text = "Replay"
	else: if _active_session_data.is_paused():
		text = "Resume"
	else:
		text = "Pause"


func _handle_pressed() -> void:
	if _active_session_data != null:
		if _active_session_data.is_at_end():
			_active_session_data.begin_session()
		else:
			_active_session_data._paused = !_active_session_data.is_paused()
		_refresh()


func _handle_session_started() -> void:
	_refresh()


func _handle_session_end_reached() -> void:
	_refresh()


func _handle_snap_to_time() -> void:
	_refresh()

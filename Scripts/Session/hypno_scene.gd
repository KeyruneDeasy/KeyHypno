extends Node2D

var _canvas: CanvasLayer
var _active_session_data: SessionData
var _is_dragging_progress_slider: bool

@onready
var _session_progress_slider: Slider = $OverlayLayer/SessionProgressSlider


func _ready() -> void:
	_canvas = $SessionCanvas
	visibility_changed.connect(_handle_visibility_changed)


func _process(_delta: float) -> void:
	if !_is_dragging_progress_slider:
		_session_progress_slider.set_value_no_signal(_active_session_data.get_current_time())


func set_session_data(in_session_data: SessionData) -> void:
	_active_session_data = in_session_data
	_canvas.set_session_data(_active_session_data)
	_session_progress_slider.max_value = _active_session_data.calculate_end_time()


func begin_session() -> void:
	if _active_session_data == null:
		return
	_active_session_data.begin_session()


func _handle_visibility_changed() -> void:
	_canvas.visible = visible


func _handle_main_menu_button_pressed() -> void:
	if _active_session_data != null:
		_active_session_data._paused = true
	hide()


func _handle_session_progress_slider_drag_ended(value_changed: bool) -> void:
	_is_dragging_progress_slider = false
	if value_changed:
		_active_session_data.snap_to_time(_session_progress_slider.value)


func _handle_session_progress_slider_drag_started() -> void:
	_is_dragging_progress_slider = true

extends Node2D

var _active_session_data: SessionData

@onready
var _session_progress_slider: Slider = $OverlayLayer/SessionProgressSlider
@onready
var _overlay: CanvasLayer = $OverlayLayer
@onready
var _canvas: CanvasLayer = $SessionCanvas


func _ready() -> void:
	visibility_changed.connect(_handle_visibility_changed)


func _process(_delta: float) -> void:
	pass


func set_session_data(in_session_data: SessionData) -> void:
	_active_session_data = in_session_data
	_canvas.set_session_data(_active_session_data)
	_session_progress_slider.set_session_data(_active_session_data)


func begin_session() -> void:
	if _active_session_data == null:
		return
	_active_session_data.begin_session()


func _handle_visibility_changed() -> void:
	_canvas.visible = visible
	_overlay.visible = visible


func _handle_main_menu_button_pressed() -> void:
	if _active_session_data != null:
		_active_session_data._paused = true
	hide()

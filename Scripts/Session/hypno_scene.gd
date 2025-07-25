extends Node2D
var _canvas: CanvasLayer
var HSControl: Control
var HSSessionData: SessionData
var _active_session_data: SessionData
var audio_player: AudioStreamPlayer


func _ready() -> void:
	_canvas = $SessionCanvas
	audio_player = $Control/ASPlayer2D
	HSControl = $Control
	visibility_changed.connect(_handle_visibility_changed)


func set_session_data(in_session_data: SessionData) -> void:
	_active_session_data = in_session_data
	_canvas.set_session_data(_active_session_data)


func begin_session() -> void:
	if _active_session_data == null:
		return
	_active_session_data.begin_session()


func _handle_visibility_changed() -> void:
	_canvas.visible = visible


func _handle_main_menu_button_pressed() -> void:
	if _active_session_data != null:
		_active_session_data._paused = true
	if audio_player.playing:
		audio_player.stop()
	hide()

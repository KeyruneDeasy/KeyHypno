extends Node2D
var _canvas: CanvasLayer
var HSControl: Control
var HSSessionData: SessionData
var active_session_data: SessionData
var zip_reader: ZIPReader
var audio_player: AudioStreamPlayer


func _ready():
	_canvas = $SessionCanvas
	audio_player = $Control/ASPlayer2D
	HSControl = $Control


func set_visibility(is_visible: bool):
	show()
	_canvas.visible = is_visible
	HSControl.visible = is_visible


func begin_session():
	if active_session_data == null:
		return
	else:
		active_session_data._paused = false
	_canvas.session_data = active_session_data
	_canvas.zip_reader = zip_reader
	active_session_data.begin_session()


func _on_main_menu_button_pressed() -> void:
	if active_session_data != null:
		active_session_data._paused = true
	if audio_player.playing:
		audio_player.play_path(zip_reader,"")
	hide()

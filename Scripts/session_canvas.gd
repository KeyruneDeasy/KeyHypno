extends CanvasLayer

var session_data: SessionData
var zip_reader: ZIPReader
var player: AudioStreamPlayer
var subliminal_label: Label
var debug_label: Label


func _ready():
	subliminal_label = $sub
	player = get_node("../Control/ASPlayer2D")
	debug_label = $DebugLabel


func _process(delta: float):
	if session_data != null:
		draw_session()


func draw_session():
	var active_elements: Array[SessionElement] = session_data.get_active_elements()
	var active_subliminals = active_elements.filter(
		func(element: SessionElement): return element is SessionElement_Subliminal
	)
	if active_subliminals.is_empty():
		subliminal_label.visible = false
	else:
		subliminal_label.visible = true
		subliminal_label.text = active_subliminals[0].get_current_message()
	var active_audio = active_elements.filter(
		func(element: SessionElement): return element is SessionElement_Audio
	)
	if active_audio.size() == 0  && !player.path.is_empty():
		player.play_path(zip_reader, "")
	elif active_audio.size() > 0 && active_audio[0].path != player.path && !session_data._paused:
		player.play_path(zip_reader, active_audio[0].path)
	var debug_string: String = "%s" % session_data._global_time
	debug_label.text = debug_string

	#for session_element : SessionElement in active_elements:
	#if(session_element is SessionElement_Subliminal):
	#draw_subliminal(session_element)

#func draw_subliminal(var subliminal : SessionElement):

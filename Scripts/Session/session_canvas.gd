extends CanvasLayer

const END_OF_SESSION_TEXT: String = "END OF SESSION"

var _session_data: SessionData
var _image_nodes: Array[Sprite2D]

@onready
var player: AudioStreamPlayer = $SessionAudioPlayer
@onready
var subliminal_label: Label = $SubliminalLabel
@onready
var debug_label: Label = $DebugLabel
@onready
var interact_label: Label = $InteractLabel


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if _session_data != null && visible:
		draw_session()
	if !visible:
		if player.playing:
			player.stop()


func set_session_data(in_session_data: SessionData) -> void:
	if _session_data != null:
		_session_data.on_session_end_reached.disconnect(_handle_session_end_reached)
	_session_data = in_session_data
	_session_data.on_session_end_reached.connect(_handle_session_end_reached)


func draw_session() -> void:
	var active_elements: Array[SessionElement] = _session_data.get_active_elements()
	
	# Subliminals
	var active_subliminals: Array[SessionElement_Subliminal]
	active_subliminals.assign(active_elements.filter(
		func(element: SessionElement): return element is SessionElement_Subliminal
	))
	if _session_data.is_at_end():
		# Don't touch the sub label, it's been updated in _handle_session_end_reached
		pass
	elif active_subliminals.is_empty():
		subliminal_label.visible = false
	else:
		subliminal_label.visible = true
		subliminal_label.text = active_subliminals[0].get_current_message()
	
	# Audio
	var active_audios: Array[SessionElement_Audio]
	active_audios.assign(active_elements.filter(
		func(element: SessionElement): return element is SessionElement_Audio
	))
	if active_audios.size() == 0  && player.playing:
		player.stop_and_clear()
	elif _session_data.is_paused():
		# TODO: This presumably loses the place in the audio stream.
		# Should keep it so it can be resumed.
		player.stop()
	elif active_audios.size() > 0 && !_session_data.is_paused():
		# TODO: support multiple audio streams
		var audio_data: PackedByteArray = active_audios[0].get_audio_data()
		if !player.is_playing_data(audio_data):
			var audio_ext: String = active_audios[0].get_audio_ext()
			player.play_file_data(audio_data, audio_ext)
	
	# Interacts
	var active_interacts: Array[SessionElement_Interact]
	active_interacts.assign(active_elements.filter(
		func(element: SessionElement): return element is SessionElement_Interact
	))
	if active_interacts.is_empty():
		interact_label.visible = false
	else:
		var awaited_interact: ButtonInteract = active_interacts[0].get_awaited_interact()
		if awaited_interact == null:
			interact_label.visible = false
		else:
			interact_label.visible = true
			var key_string: String = OS.get_keycode_string(awaited_interact.get_bound_key())
			var hold_time: float = awaited_interact.get_hold_time()
			if hold_time > 0.0:
				interact_label.text = "Hold the " + key_string + " key for " + str(hold_time) + " seconds."
			else:
				interact_label.text = "Press the " + key_string + " key."
	
	# Images
	var active_images: Array[SessionElement_Image]
	active_images.assign(active_elements.filter(
		func(element: SessionElement): return element is SessionElement_Image
	))
	if !active_images.is_empty():
		# WIP code
		var my_image: Image = Image.new()
		my_image.load_png_from_buffer(active_images[0].get_image_data())
		var image_texture = ImageTexture.create_from_image(my_image)
		$Sprite2D.set_texture(image_texture)
		var vertical_fit_scale: float = float(get_window().size.y) / float(my_image.get_height())
		var horizontal_fit_scale: float = float(get_window().size.x) / float(my_image.get_width())
		var scale = minf(horizontal_fit_scale, vertical_fit_scale)
		print(scale)
		print("window ", get_window().size.y)
		print("image ", my_image.get_height())
		$Sprite2D.scale.x = scale
		$Sprite2D.scale.y = scale
		$Sprite2D.position = get_window().size / 2
		


func _input(event: InputEvent) -> void:
	if _session_data == null:
		return
		
	for active_element: SessionElement in _session_data.get_active_elements():
		active_element._input(event)


func _handle_session_end_reached() -> void:
	subliminal_label.visible = true
	subliminal_label.text = END_OF_SESSION_TEXT
	

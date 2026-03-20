extends CanvasLayer

const END_OF_SESSION_TEXT: String = "END OF SESSION"

var _session_data: SessionData

var _currently_displayed_image_element: SessionElement_Image

@onready
var audio_player: AudioStreamPlayer = $SessionAudioPlayer
@onready
var video_player: VideoStreamPlayer = $SessionVideoPlayer
@onready
var subliminal_label: Label = $SubliminalLabel
@onready
var debug_label: Label = $DebugLabel
@onready
var interact_label: Label = $InteractLabel
@onready
var image_grid_container: GridContainer = $ImageGridContainer


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if _session_data != null && visible:
		draw_session()
	if !visible:
		if audio_player.playing:
			audio_player.stop()
		if video_player.is_playing():
			video_player.stop()


func set_session_data(in_session_data: SessionData) -> void:
	if _session_data != null:
		_session_data.on_session_end_reached.disconnect(_handle_session_end_reached)
		_session_data.on_snap_to_time.disconnect(_handle_snap_to_time)
	_session_data = in_session_data
	_session_data.on_session_end_reached.connect(_handle_session_end_reached)
	_session_data.on_snap_to_time.connect(_handle_snap_to_time)


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
	if active_audios.size() == 0  && audio_player.playing:
		audio_player.stop_and_clear()
	elif _session_data.is_paused():
		audio_player.stop()
	elif active_audios.size() > 0 && !_session_data.is_paused():
		# TODO: support multiple audio streams
		var audio_element: SessionElement_Audio = active_audios[0]
		var audio_data: PackedByteArray = audio_element.get_audio_data()
		if !audio_player.is_playing_data(audio_data):
			var audio_ext: String = audio_element.get_audio_ext()
			audio_player.play_file_data(audio_data, audio_ext)
			audio_player.seek(audio_element.get_local_time())
	
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
	
	draw_session_images()
	
	# Videos
	var active_videos: Array[SessionElement_Video]
	active_videos.assign(active_elements.filter(
		func(element: SessionElement): return element is SessionElement_Video
	))
	if active_videos.size() == 0  && video_player.is_playing():
		video_player.stop_and_clear()
	elif _session_data.is_paused():
		# TODO: This presumably loses the place in the video stream.
		# Should keep it so it can be resumed.
		video_player.stop()
	elif active_videos.size() > 0 && !_session_data.is_paused():
		# TODO: handle multiple video streams?
		var video_element: SessionElement_Video = active_videos[0]
		var video_path: String = video_element.get_file_data_temp_path()
		if !video_player.is_playing_path(video_path):
			var video_ext: String = video_element.get_video_ext()
			video_player.play_file_path(video_path, video_ext)


func draw_session_images() -> void:
	var active_elements: Array[SessionElement] = _session_data.get_active_elements()
	
	var active_images: Array[SessionElement_Image]
	active_images.assign(active_elements.filter(
		func(element: SessionElement): return element is SessionElement_Image
	))
	if active_images.is_empty():
		if _currently_displayed_image_element != null:
			_clear_displayed_image()
		return
	
	var image_element: SessionElement_Image = active_images[0]
	
	if image_element == _currently_displayed_image_element:
		return
	
	_clear_displayed_image()
	
	var image_object: Image = Image.new()
	image_element.load_image_object(image_object)
	var image_texture = ImageTexture.create_from_image(image_object)
	
	var layout: SessionElement_Image.ImageLayout = image_element.get_image_layout()
	if layout == SessionElement_Image.ImageLayout.FIT_TO_WINDOW || \
		layout == SessionElement_Image.ImageLayout.FILL_WINDOW || \
		layout == SessionElement_Image.ImageLayout.STRETCH:
		image_grid_container.position = get_window().size / 2
		var new_sprite: Sprite2D = Sprite2D.new()
		image_grid_container.add_child(new_sprite) 
		new_sprite.set_texture(image_texture)
		var vertical_fit_scale: float = float(get_window().size.y) / float(image_object.get_height())
		var horizontal_fit_scale: float = float(get_window().size.x) / float(image_object.get_width())
		if layout == SessionElement_Image.ImageLayout.FIT_TO_WINDOW:
			new_sprite.scale.x = minf(horizontal_fit_scale, vertical_fit_scale)
			new_sprite.scale.y = new_sprite.scale.x
		else: if layout == SessionElement_Image.ImageLayout.FILL_WINDOW:
			new_sprite.scale.x = maxf(horizontal_fit_scale, vertical_fit_scale)
			new_sprite.scale.y = new_sprite.scale.x
		else:
			new_sprite.scale.x = horizontal_fit_scale
			new_sprite.scale.y = vertical_fit_scale

	else: if layout == SessionElement_Image.ImageLayout.TILED:
		@warning_ignore("integer_division")
		var num_horizontal_tiles: int = (get_window().size.x / image_object.get_width()) + 1
		@warning_ignore("integer_division")
		var num_vertical_tiles: int = (get_window().size.y / image_object.get_height()) + 1
		image_grid_container.columns = num_horizontal_tiles
		image_grid_container.position = Vector2(0.0, 0.0)
		
		for horizontal_index in num_horizontal_tiles:
			for vertical_index in num_vertical_tiles:
				var new_sprite: Sprite2D = Sprite2D.new()
				new_sprite.position.x = image_object.get_width() * (horizontal_index + 0.5)
				new_sprite.position.y = image_object.get_height() * (vertical_index + 0.5)
				new_sprite.set_texture(image_texture)
				image_grid_container.add_child(new_sprite) 
				
	_currently_displayed_image_element = image_element


func _input(event: InputEvent) -> void:
	if _session_data == null:
		return
		
	for active_element: SessionElement in _session_data.get_active_elements():
		active_element._input(event)


func _handle_session_end_reached() -> void:
	subliminal_label.visible = true
	subliminal_label.text = END_OF_SESSION_TEXT


func _handle_snap_to_time() -> void:
	audio_player.stop_and_clear()
	video_player.stop_and_clear()
	if _session_data.is_paused():
		return
	
	var active_audios: Array[SessionElement_Audio]
	active_audios.assign(_session_data.get_active_elements().filter(
		func(element: SessionElement): return element is SessionElement_Audio
	))
	
	if active_audios.size() > 0:
		var audio_element: SessionElement_Audio = active_audios[0]
		var audio_data: PackedByteArray = audio_element.get_audio_data()
		var audio_ext: String = active_audios[0].get_audio_ext()
		audio_player.play_file_data(audio_data, audio_ext)
		audio_player.seek(audio_element.get_local_time())
	
	var active_videos: Array[SessionElement_Video]
	active_videos.assign(_session_data.get_active_elements().filter(
		func(element: SessionElement): return element is SessionElement_Video
	))
	
	if active_videos.size() > 0:
		var video_element: SessionElement_Video = active_videos[0]
		var video_path: String = video_element.get_file_data_temp_path()
		var video_ext: String = video_element.get_video_ext()
		video_player.play_file_path(video_path, video_ext)
		video_player.stream_position = fmod(video_element.get_local_time(), video_player.get_stream_length())


func _clear_displayed_image() -> void:
	for child in image_grid_container.get_children():
		image_grid_container.remove_child(child)
	_currently_displayed_image_element = null

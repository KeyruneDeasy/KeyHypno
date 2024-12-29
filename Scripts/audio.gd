extends AudioStreamPlayer

@export var path = ""


func play_path(session_data: ZIPReader, new_path: String):
	print("playing: " + new_path)
	get_node(".").stop()
	path = new_path
	var hypno_scene_audio_player = get_node(".")
	if path.is_empty():
		return
	match path.right(3).to_lower():
		"ogg":
			hypno_scene_audio_player.stream = AudioStreamOggVorbis.load_from_buffer(session_data.read_file(new_path))
		"mp3":
			var mp3 = AudioStreamMP3.new()
			mp3.data = session_data.read_file(new_path)
			hypno_scene_audio_player.stream = mp3
		_:
			print("unexpected file type")
	hypno_scene_audio_player.play()

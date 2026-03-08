extends VideoStreamPlayer

var _currently_playing_file_path: String


func play_file_path(file_path: String, file_ext: String) -> void:
	stop_and_clear()
	match file_ext:
		"ogg":
			stream = VideoStreamTheora.new()
			stream.file = file_path
			#stream.file = 
			#stream = VideoStream.load_from_buffer(file_data)
		_:
			print("unexpected file type '" + file_ext + "'")
	play()
	_currently_playing_file_path = file_path


func is_playing_path(file_path: String) -> bool:
	return is_playing() and _currently_playing_file_path == file_path


func stop_and_clear() -> void:
	stop()
	stream = null

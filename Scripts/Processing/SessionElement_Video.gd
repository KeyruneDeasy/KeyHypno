class_name SessionElement_Video
extends SessionElement_SingleFile
	

static func get_type_static() -> String:
	return "VIDEO"


func _init() -> void:
	super._init()
	_end_time.set_value(10.0)


func get_default_display_name() -> String:
	return "Video"


func get_type() -> String:
	return get_type_static()


func get_video_data() -> PackedByteArray:
	return get_file_data()


func get_video_ext() -> String:
	return get_file_ext()

class_name SessionElement_Image
extends SessionElement

var path: String
var file: SessionResourceFilePointer
var id: int
	

static func get_type_static() -> String:
	return "IMAGE"


func _init() -> void:
	super._init()
	_end_time.set_value(10.0)
	file = SessionResourceFilePointer.new()


func process_element(delta: float) -> void:
	super.process_element(delta)
	

func get_default_display_name() -> String:
	return "Image"


func encode_to_json() -> Dictionary:
	var out : Dictionary = super.encode_to_json()
	out.get_or_add("file_id", file.get_session_resource_file_id())
	return out
	
	
func decode_from_json(entry : Dictionary) -> void:
	super.decode_from_json(entry)
	file.set_to_session_resource_file_id(entry["file_id"])


func get_type() -> String:
	return get_type_static()


func set_local_path(in_path: String) -> void:
	path = in_path
	file.set_to_local_file_path(in_path)


func save_files_to_new_manifest(session_data: SessionData) -> void:
	session_data.add_file_to_new_manifest(file)


func get_image_data() -> PackedByteArray:
	return file.get_file_data()


func get_image_ext() -> String:
	return file.get_file_ext()


func populate_file_data_from_manifest(session_data: SessionData) -> void:
	file.populate_file_data_from_manifest(session_data)


func can_run() -> bool:
	return file.is_set()

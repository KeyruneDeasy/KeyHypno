class_name SessionElement_SingleFile
extends SessionElement

var _file: SessionResourceFilePointer
	

static func get_type_static() -> String:
	return "SINGLE_FILE"


func _init() -> void:
	super._init()
	_file = SessionResourceFilePointer.new()
	

func get_default_display_name() -> String:
	return "Single File"


func encode_to_json() -> Dictionary:
	var out : Dictionary = super.encode_to_json()
	out.get_or_add("file_id", _file.get_session_resource_file_id())
	return out
	
	
func decode_from_json(entry : Dictionary) -> void:
	super.decode_from_json(entry)
	_file.set_to_session_resource_file_id(entry["file_id"])
	
	

func get_type() -> String:
	return get_type_static()
	
	
func set_local_path(in_path: String) -> void:
	_file.set_to_local_file_path(in_path)
	
	
func get_local_path() -> String:
	return _file.get_local_path()


func save_files_to_new_manifest(session_data: SessionData) -> void:
	session_data.add_file_to_new_manifest(_file)


func get_file_data() -> PackedByteArray:
	return _file.get_file_data()
	

func get_file_data_temp_path() -> String:
	return _file.get_file_data_temp_path()


func get_file_ext() -> String:
	return _file.get_file_ext()


func populate_file_data_from_manifest(session_data: SessionData) -> void:
	_file.populate_file_data_from_manifest(session_data)


func can_run() -> bool:
	return _file.is_set()

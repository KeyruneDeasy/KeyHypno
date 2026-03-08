class_name SessionResourceFilePointer
extends RefCounted

var _session_resource_file_id: int = -1
var _file: SessionResourceFile

func set_to_local_file_path(new_local_file_path: String) -> void:
	_file = LocalFileManager.singleton.register_or_get_local_file(new_local_file_path)


func set_to_session_resource_file_id(new_session_resource_file_id: int) -> void:
	_session_resource_file_id = new_session_resource_file_id
	

func get_file_data() -> PackedByteArray:
	return _file.get_file_data()
	

func get_file_ext() -> String:
	return _file.get_local_path().get_extension()


func get_session_resource_file_id() -> int:
	return _session_resource_file_id


func get_file() -> SessionResourceFile:
	return _file


func get_local_path() -> String:
	return ("") if (_file == null) else (_file.get_local_path())
	

func get_file_data_temp_path() -> String:
	return _file.get_file_data_temp_path()


func populate_file_data_from_manifest(session_data: SessionData) -> void:
	if _session_resource_file_id != -1:
		_file = session_data.get_file_from_manifest_by_id(_session_resource_file_id)


func is_set() -> bool:
	return _file != null || _session_resource_file_id != -1

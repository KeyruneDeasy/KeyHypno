class_name LocalFileManager
extends RefCounted

static var singleton: LocalFileManager = LocalFileManager.new()

var files: Array[SessionResourceFile]

func register_or_get_local_file(file_path: String) -> SessionResourceFile:
	for file: SessionResourceFile in files:
		if file._file_local_path == file_path:
			return file
	var new_file: SessionResourceFile = SessionResourceFile.new(file_path)
	files.append(new_file)
	return new_file

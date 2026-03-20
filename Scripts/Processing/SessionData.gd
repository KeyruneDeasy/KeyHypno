class_name SessionData
extends Node

var _elements: Array[SessionElement]
var _paused: bool = true
var _at_end: bool = true
var _global_time: float = 0.0
var _file_manifest: Array[SessionResourceFile]
var _new_file_manifest: Array[SessionResourceFile]

signal on_session_started()
signal on_session_end_reached()
signal on_snap_to_time()


func _ready() -> void:
	pass


func begin_session():
	_global_time = 0.0
	_at_end = false
	for element: SessionElement in _elements:
		element.reset_element_execution()
	_paused = false
	on_session_started.emit()


func _process(delta: float) -> void:
	if _paused:
		return
	
	# Advance time
	var old_global_time: float = _global_time
	var time_advancing: bool = _should_time_advance()
	if time_advancing:
		_global_time += delta
	else:
		delta = 0.0
	
	var has_incomplete_element: bool = false
	for element: SessionElement in _elements:
		if element.is_element_active():
			if time_advancing || element is SessionElement_Interact:
				element.process_element(delta)
		else:
			if (
				old_global_time <= element.get_start_time()
				and _global_time > element.get_start_time()
				and element.can_run()
			):
				element.begin_element()
				element.process_element(_global_time - element.get_start_time())
		has_incomplete_element = (
			has_incomplete_element
			|| element.is_element_active()
			|| _global_time < element.get_start_time()
		)
	if !has_incomplete_element:
		_paused = true
		_at_end = true
		on_session_end_reached.emit()


func is_paused() -> bool:
	return _paused


func is_at_end() -> bool:
	return _at_end


func add_element(new_element: SessionElement) -> void:
	_elements.append(new_element)


func delete_element(element: SessionElement) -> void:
	var index: int = _elements.find(element)
	_elements.remove_at(index)


func add_element_of_class(new_element_class: Resource) -> SessionElement:
	var new_element = new_element_class.new()
	add_element(new_element)
	return new_element


func reset_and_clear():
	_paused = true
	_global_time = 0.0
	_elements.clear()


func get_active_elements():
	return _elements.filter(func(element: SessionElement): return element.is_element_active())
	
	
func is_element_name_in_use(in_name: String, element_to_ignore: SessionElement) -> bool:
	for element in _elements:
		if element != element_to_ignore and element.get_display_name() == in_name:
			return true
	return false


func get_element_by_display_name(in_name: String) -> SessionElement:
	for element in _elements:
		if element.get_display_name() == in_name:
			return element
	return null
	
	
func assign_unique_default_display_name_to_element(element: SessionElement) -> void:
	element._display_name.set_value(_update_display_name_until_unique(element, element.get_default_display_name()))
	
	
func update_display_name_of_element_to_be_unique(element: SessionElement) -> void:
	element._display_name.set_value(_update_display_name_until_unique(element, element.get_display_name()))


func _update_display_name_until_unique(element: SessionElement, preferred_name: String) -> String:
	var suffix: int = 0
	while true:
		var chosen_name: String = preferred_name
		if suffix > 0:
			chosen_name += str(suffix)
		suffix += 1
		if !is_element_name_in_use(chosen_name, element):
			return chosen_name
	return ""


func _should_time_advance() -> bool:
	for element: SessionElement in _elements:
		if element.is_element_active() && element is SessionElement_Interact:
			return false
	return true
	
	
func debug_print() -> void:
	for element in _elements:
		element.debug_print()


func encode_to_json() -> String:
	var sav : Array[Dictionary] = []
	for element in _elements:
		sav.append(element.encode_to_json())
	return JSON.stringify(sav)


func json_destringify(data: String) -> Array:
	# parse data
	var json = JSON.new()
	var error = json.parse(data)
	# verify data
	if error == OK:
		var data_received : Array = json.data
		if typeof(data_received) == TYPE_ARRAY:
			return data_received
		else:
			print("data is of invalid type")
			return []
	else:
		print(
			"JSON Parse Error: ",
			json.get_error_message(),
			" in ",
			data,
			" at line ",
			json.get_error_line()
		)
		return []

func decode_from_json(data: String) -> void:
	var sav: Array = json_destringify(data)
	for entry : Dictionary in sav:
		var element: SessionElement
		if entry["type"] == SessionElement_Subliminal.get_type_static():
			element = add_element_of_class(SessionElement_Subliminal)
		else: if entry["type"] == SessionElement_Audio.get_type_static():
			element = add_element_of_class(SessionElement_Audio)
		else: if entry["type"] == SessionElement_Interact.get_type_static():
			element = add_element_of_class(SessionElement_Interact)
		else: if entry["type"] == SessionElement_Image.get_type_static():
			element = add_element_of_class(SessionElement_Image)
		else: if entry["type"] == SessionElement_Video.get_type_static():
			element = add_element_of_class(SessionElement_Video)
		else:
			print("invalid event type " + entry.type)
			return
		element.decode_from_json(entry)
		if !entry.has("display_name"):
			assign_unique_default_display_name_to_element(element)


func load_from_file(path: String) -> void:
	reset_and_clear()
	var reader: ZIPReader = ZIPReader.new()
	reader.open(path)
	var files = reader.get_files()
	files.sort()
	print(files)
	var data: String = reader.read_file("Elements.txt").get_string_from_utf8()
	decode_from_json(data)
	unpack_files(reader)


func create_file_manifest() -> void:
	_new_file_manifest.clear()
	for element: SessionElement in _elements:
		element.save_files_to_new_manifest(self)
	_file_manifest = _new_file_manifest.duplicate()
	_new_file_manifest.clear()


func add_file_to_new_manifest(new_file : SessionResourceFilePointer) -> void:
	if !new_file.is_set():
		return
	var index: int = 0
	for manifest_file: SessionResourceFile in _new_file_manifest:
		if manifest_file == new_file.get_file():
			# The file is already in the manifest, just update the pointer
			new_file.set_to_session_resource_file_id(index)
			return
		index = index + 1
	# Didn't find the file in the manifest, so add it.	
	_new_file_manifest.append(new_file.get_file())
	new_file.set_to_session_resource_file_id(index)
		

func pack_files(packer: ZIPPacker) -> void:
	var index: int = 0
	var manifest_data: Array[Dictionary] = []
	for file: SessionResourceFile in _file_manifest:
		var file_meta_data: Dictionary = file.encode_to_json()
		file_meta_data.get_or_add("manifest_index", str(index))
		manifest_data.append(file_meta_data)
		index += 1
	var manifest_string: String = JSON.stringify(manifest_data)
	
	packer.start_file("Manifest.txt")
	packer.write_file(manifest_string.to_utf8_buffer())
	packer.close_file()
	
	index = 0
	for file: SessionResourceFile in _file_manifest:
		packer.start_file(str(index))
		packer.write_file(file.get_file_data())
		packer.close_file()
		index += 1


func unpack_files(reader: ZIPReader) -> void:
	_file_manifest.clear()
	var manifest_string: String = reader.read_file("Manifest.txt").get_string_from_utf8()
	var manifest_data: Array = json_destringify(manifest_string)
	for entry: Dictionary in manifest_data:
		var new_file := SessionResourceFile.new("")
		new_file.decode_from_json(entry)
		_file_manifest.append(new_file)
		
		var index: int = entry["manifest_index"].to_int()
		var file_packed_name = str(index)
		new_file.set_loaded_file_data(reader.read_file(file_packed_name))
	for element: SessionElement in _elements:
		element.populate_file_data_from_manifest(self)
	

func save_to(path: String) -> void:
	create_file_manifest()
	
	var packer := ZIPPacker.new()
	packer.open(path)
	packer.start_file("Elements.txt")
	var save_raw: String = encode_to_json()
	packer.write_file(save_raw.to_utf8_buffer());
	packer.close_file()
	
	pack_files(packer)
	
	packer.close()


func get_file_from_manifest_by_id(id: int) -> SessionResourceFile:
	return _file_manifest[id]


func calculate_end_time() -> float:
	var end_time = 0.0
	for element in _elements:
		end_time = maxf(element.get_end_time(), end_time)
	return end_time


func get_current_time() -> float:
	return _global_time


func snap_to_time(time: float) -> void:
	_global_time = time
	_at_end = false
	for element: SessionElement in _elements:
		element.reset_element_execution()
	_paused = false
	for element: SessionElement in _elements:
		if (
			_global_time >= element.get_start_time() 
			and _global_time < element.get_end_time() 
			and not (element is SessionElement_Interact)
			and element.can_run()
			):
			element.begin_element()
			element.process_element(_global_time - element.get_start_time())
	on_snap_to_time.emit()
	

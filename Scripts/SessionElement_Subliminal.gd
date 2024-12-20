class_name SessionElement_Subliminal
extends SessionElement

var _messages: Array[String]
var _time_per_message: float
var _time_since_message_change: float
var _message_index: int


func _begin_element():
	super._begin_element()
	_message_index = -1
	_randomise_message_index()
	_time_since_message_change = 0.0
	#load_file("TestSave.hypsav")
	#save_file("TestSave2.hypsav")
	print("subliminal started")
	if !_messages.is_empty():
		print(_messages[0])


func _process_element(delta: float):
	#print("subliminal tick")
	var StillRunning = super._process_element(delta)
	if !StillRunning:
		return false
	_time_since_message_change += delta
	if _time_since_message_change > _time_per_message:
		_time_since_message_change -= _time_per_message
		_randomise_message_index()
	return true


func _end_element():
	super._end_element()
	print("subliminal ended")


func _randomise_message_index():
	if _messages.is_empty():
		return

	if _message_index == -1:
		# No message chosen yet, choose any
		_message_index = randi_range(0, _messages.size() - 1)
	else:
		# Don't choose the same message that's currently chosen
		var new_message_index = randi_range(0, _messages.size() - 2)
		if new_message_index >= _message_index:
			new_message_index = new_message_index + 1
		_message_index = new_message_index


func get_current_message():
	if _message_index == -1:
		return ""
	else:
		return _messages[_message_index]


func save_file(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	for message in _messages:
		file.store_string(message + "\n")


func load_file(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	print(content)
	var content_packed_array = content.split("\n")
	print("packed array: ", content_packed_array.size())
	for packed_string in content_packed_array:
		_messages.append(packed_string)

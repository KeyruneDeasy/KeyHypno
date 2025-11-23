extends  Control


var _editing_element: SessionElement_Subliminal

@onready
var _subliminal_message_text_box: TextEdit = $SubliminalMessageTextBox


func set_editing_element(in_editing_element: SessionElement_Subliminal) -> void:
	_editing_element = in_editing_element
	_populate()


func _populate() -> void:
		var subliminal_messages: String = ""
		for message in _editing_element._messages:
			subliminal_messages = subliminal_messages + message + "\n"
		_subliminal_message_text_box.text = subliminal_messages


func _handle_text_edit_text_changed() -> void:
	_editing_element._messages.clear()
	var new_message_list: PackedStringArray = _subliminal_message_text_box.text.split("\n", false)
	for new_message: String in new_message_list:
		_editing_element._messages.append(new_message)

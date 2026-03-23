class_name SessionElement_Interact
extends SessionElement

# Saved config
var _button_sequence: Array[ButtonInteract]

# Transient state
var _next_awaited_button_index: int = 0
var _holding_awaited_button: bool = false
var _time_holding_awaited_button: float = 0.0
	

static func get_type_static() -> String:
	return "INTERACT"


func _init() -> void:
	super._init()
	_end_time.set_value(1.0)
	

func begin_element():
	super.begin_element()
	_next_awaited_button_index = 0


func process_element(delta: float) -> void:
	# Deliberately don't call Super function
	
	if _next_awaited_button_index >= _button_sequence.size():
		_end_element()
		return
		
	if _holding_awaited_button:
		_time_holding_awaited_button += delta
		if _time_holding_awaited_button > get_awaited_interact().get_hold_time():
			_advance_awaited_button()
		if _next_awaited_button_index >= _button_sequence.size():
			_end_element()
			return


func get_awaited_interact() -> ButtonInteract:
	if _next_awaited_button_index < _button_sequence.size():
		return _button_sequence[_next_awaited_button_index]
	else:
		return null


func add_button_interact() -> void:
	var new_button_interact = ButtonInteract.new()
	_button_sequence.append(new_button_interact)


func remove_button_interact(to_remove: ButtonInteract) -> void:
	_button_sequence.erase(to_remove)


func get_button_sequence() -> Array[ButtonInteract]:
	return _button_sequence
	

func get_default_display_name() -> String:
	return "Interact"


func _input(event: InputEvent) -> void:
	if !(event is InputEventKey) || !is_element_active():
		return
	var key_event: InputEventKey = event
	
	var awaited_interact: ButtonInteract = get_awaited_interact()
	if awaited_interact == null:
		return
		
	if key_event.keycode == awaited_interact.get_bound_key():
		if key_event.pressed:
			if awaited_interact.get_hold_time() <= 0.0:
				_advance_awaited_button()
			else: if !_holding_awaited_button:
				_holding_awaited_button = true
				_time_holding_awaited_button = 0.0
		else:
			_holding_awaited_button = false
			

func _advance_awaited_button() -> void:
	_next_awaited_button_index = _next_awaited_button_index + 1
	_holding_awaited_button = false


func encode_to_json() -> Dictionary:
	var out: Dictionary = super.encode_to_json()
	
	var button_interact_dictionaries: Array[Dictionary]
	for button_interact: ButtonInteract in _button_sequence:
		var button_interact_dictionary: Dictionary
		button_interact.encode_to_json(button_interact_dictionary)
		button_interact_dictionaries.push_back(button_interact_dictionary)
	out.get_or_add("ButtonInteracts", button_interact_dictionaries)
	return out
	
	
func decode_from_json(entry: Dictionary) -> void:
	super.decode_from_json(entry)
	var button_interact_dictionaries: Array = entry["ButtonInteracts"]
	for button_interact_dictionary: Dictionary in button_interact_dictionaries:
		var button_interact = ButtonInteract.new()
		button_interact.decode_from_json(button_interact_dictionary)
		_button_sequence.push_back(button_interact)


func get_type() -> String:
	return get_type_static()


func get_end_time() -> float:
	return get_start_time()

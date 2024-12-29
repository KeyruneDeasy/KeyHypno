class_name SessionData
extends Node

var SubliminalClass = preload("res://Scripts/SessionElement_Subliminal.gd")
var AudioClass = preload("res://Scripts/SessionElement_Audio.gd")

var _elements: Array[SessionElement]
var _paused: bool = true
var _global_time: float = 0.0


func _ready() -> void:
	pass


func begin_session():
	_global_time = 0.0
	_paused = false


func _process(delta: float) -> void:
	if _paused:
		return
	var old_global_time: float = _global_time
	_global_time += delta
	var has_incomplete_element: bool = false
	for element in _elements:
		if element.is_element_active():
			element._process_element(delta)
		else:
			if (
				old_global_time <= element.get_start_time()
				and _global_time > element.get_start_time()
			):
				element._begin_element()
				element._process_element(_global_time - element.get_start_time())
		has_incomplete_element = (
			has_incomplete_element
			|| element.is_element_active
			|| _global_time < element.get_start_time()
		)
	if !has_incomplete_element:
		_paused = true


func add_element(new_element: SessionElement):
	_elements.append(new_element)


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

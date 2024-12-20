class_name SessionElement
extends RefCounted

var _type: String = ""
var _start_time: float = 0.0
var _end_time: float = -1.0
var _local_time: float = 0.0
var _is_active: bool = false


func _begin_element():
	_is_active = true
	_local_time = 0.0


func _process_element(delta: float):
	_local_time += delta
	if _end_time >= 0.0 && _local_time > _end_time:
		_end_element()
		return false
	return true


func _end_element():
	_is_active = false


func get_start_time():
	return _start_time


func get_local_time():
	return _local_time


func is_element_active():
	return _is_active

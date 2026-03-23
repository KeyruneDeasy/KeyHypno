class_name ButtonInteract
extends RefCounted

var _bound_key : Key
var _hold_time : FloatObj = FloatObj.new(0.0)


func _ready() -> void:
	pass


func set_bound_key(in_bound_key: Key) -> void:
	_bound_key = in_bound_key


func get_bound_key() -> Key:
	return _bound_key


func get_hold_time_ref() -> FloatObj:
	return _hold_time


func get_hold_time() -> float:
	return _hold_time.get_value()


func encode_to_json(out: Dictionary):
	out.get_or_add("Key", _bound_key)
	out.get_or_add("HoldTime", _hold_time.get_value())


func decode_from_json(entry: Dictionary):
	_bound_key = entry["Key"]
	_hold_time.set_value(entry["HoldTime"])
	pass

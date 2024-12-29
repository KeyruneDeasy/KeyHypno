class_name SessionElement_Audio
extends SessionElement

var path: String
var id: int


func _process_element(delta: float):
	var StillRunning = super._process_element(delta)
	if !StillRunning:
		return false
	return true

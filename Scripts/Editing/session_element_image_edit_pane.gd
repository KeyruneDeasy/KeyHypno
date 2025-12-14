extends Control


var _editing_element: SessionElement_Image

var ImageFileSelectScene = preload("res://Scenes/ImageFileSelect.tscn")

@onready
var PathLabel = $PathLabel


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func set_editing_element(in_editing_element: SessionElement_Image) -> void:
	_editing_element = in_editing_element
	_populate()


func _handle_select_path_button_pressed() -> void:
	var file_select: FileDialog = ImageFileSelectScene.instantiate()
	add_child(file_select)
	file_select.file_selected.connect(_handle_file_selected)
	file_select.popup()


func _handle_file_selected(path: String) -> void:
	print(path)
	_editing_element.set_local_path(path)
	_populate()


func _populate() -> void:
	if _editing_element.path.is_empty():
		PathLabel.text = "No file selected"
	else:
		PathLabel.text = _editing_element.path.get_file()

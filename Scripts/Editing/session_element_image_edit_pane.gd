extends Control


var _editing_element: SessionElement_Image

var ImageFileSelectScene = preload("res://Scenes/ImageFileSelect.tscn")

@onready
var PathLabel = $PathLabel
@onready
var _image_layout_option_button = $ImageLayoutOptionButton


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
	_editing_element.set_local_path(path)
	_populate()


func _populate() -> void:
	if _editing_element.get_local_path().is_empty():
		PathLabel.text = "No file selected"
	else:
		PathLabel.text = _editing_element.get_local_path().get_file()
	_image_layout_option_button.select(_editing_element.get_image_layout())


func _handle_image_layout_option_button_item_selected(index: int) -> void:
	_editing_element.set_image_layout(index)

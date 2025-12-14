class_name EditingScene
extends Node2D

var open_session_data : SessionData
var _selected_element: SessionElement
var _selected_index: int

@onready
var _canvas_layer: CanvasLayer = $CanvasLayer
@onready
var _list_of_elements_in_session: ItemList = $CanvasLayer/ListOfElementsInSession
@onready
var _edit_element_root_container: Container = $CanvasLayer/EditElementRootContainer
@onready
var _edit_element_grid_container: Container = $CanvasLayer/EditElementRootContainer/EditElementGridContainer
@onready
var _new_session_confirmation_dialog: ConfirmationDialog = $CanvasLayer/NewSessionButton/NewSessionConfirmationDialog

var SubliminalClass = preload("res://Scripts/Processing/SessionElement_Subliminal.gd")
var InteractClass = preload("res://Scripts/Processing/SessionElement_Interact.gd")
var AudioClass = preload("res://Scripts/Processing/SessionElement_Audio.gd")
var ImageClass = preload("res://Scripts/Processing/SessionElement_Image.gd")
var SessionElementSubliminalEditPaneScene = preload("res://Scenes/SessionElement_Subliminal_EditPane.tscn")
var SessionElementInteractEditPaneScene = preload("res://Scenes/SessionElement_Interact_EditPane.tscn")
var SessionElementAudioEditPaneScene = preload("res://Scenes/SessionElement_Audio_EditPane.tscn")
var SessionElementImageEditPaneScene = preload("res://Scenes/SessionElement_Image_EditPane.tscn")
var SaveSessionDialogScene = preload("res://Scenes/SaveSessionDialog.tscn")

var _subliminal_messages_editor: TextEdit

signal on_new_session_confirmed()


func _ready():
	pass


func refresh():
	_list_of_elements_in_session.clear()
	_set_selected_element_and_populate_edit_container(null)
	
	if open_session_data != null:
		for element in open_session_data._elements:
			_add_element_to_display_list(element)


func _handle_add_subliminal_button_pressed() -> void:
	var new_element: SessionElement_Subliminal = SubliminalClass.new()
	_set_up_new_element(new_element)


func _handle_add_interact_button_pressed() -> void:
	var new_element: SessionElement_Interact = InteractClass.new()
	_set_up_new_element(new_element)


func _handle_add_audio_button_pressed() -> void:
	var new_element: SessionElement_Audio = AudioClass.new()
	_set_up_new_element(new_element)


func _handle_add_image_button_pressed() -> void:
	var new_element: SessionElement_Image = ImageClass.new()
	_set_up_new_element(new_element)


func _set_up_new_element(new_element: SessionElement) -> void:
	open_session_data.assign_unique_default_display_name_to_element(new_element)
	open_session_data.add_element(new_element)
	_add_element_to_display_list(new_element)
	var new_element_index: int = _list_of_elements_in_session.item_count - 1
	_select_element_at_index(new_element_index)


func _handle_back_to_menu_button_pressed() -> void:
	hide()


func _add_element_to_display_list(new_element: SessionElement) -> void:
	_list_of_elements_in_session.add_item(new_element.get_display_name())


func _handle_list_of_elements_in_session_item_selected(index: int) -> void:
	_select_element_at_index(index)


func _select_element_at_index(index: int) -> void:
	_list_of_elements_in_session.select(index)
	_selected_index = index
	var selected_display_name: String = _list_of_elements_in_session.get_item_text(index)
	var selected_element: SessionElement = open_session_data.get_element_by_display_name(selected_display_name)
	_set_selected_element_and_populate_edit_container(selected_element)


func _set_selected_element_and_populate_edit_container(element: SessionElement) -> void:
	if _selected_element != null:
		_selected_element.on_display_name_changed.disconnect(_handle_selected_element_display_name_changed)
		
	for child in _edit_element_grid_container.get_children():
		_edit_element_grid_container.remove_child(child)
		
	for child in _edit_element_root_container.get_children():
		if child != _edit_element_grid_container:
			_edit_element_root_container.remove_child(child)
	
	_selected_element = element
	if _selected_element == null:
		return
		
	_selected_element.on_display_name_changed.connect(_handle_selected_element_display_name_changed)
	
	_add_string_prop_to_edit_container("Name:", element.get_display_name_ref())
	_add_float_prop_to_edit_container("Start Time:", element.get_start_time_ref())
	_add_float_prop_to_edit_container("End Time:", element.get_end_time_ref())
	
	if _selected_element is SessionElement_Subliminal:
		_add_float_prop_to_edit_container("Time Per Message:", element.get_time_per_message_ref())
		var subliminal_edit_pane = SessionElementSubliminalEditPaneScene.instantiate()
		_edit_element_root_container.add_child(subliminal_edit_pane)
		subliminal_edit_pane.set_editing_element(_selected_element)
	else: if _selected_element is SessionElement_Interact:
		var interact_edit_pane = SessionElementInteractEditPaneScene.instantiate()
		_edit_element_root_container.add_child(interact_edit_pane)
		interact_edit_pane.set_editing_element(_selected_element)
	else: if _selected_element is SessionElement_Audio:
		var audio_edit_pane = SessionElementAudioEditPaneScene.instantiate()
		_edit_element_root_container.add_child(audio_edit_pane)
		audio_edit_pane.set_editing_element(_selected_element)
	else: if _selected_element is SessionElement_Image:
		var image_edit_pane = SessionElementImageEditPaneScene.instantiate()
		_edit_element_root_container.add_child(image_edit_pane)
		image_edit_pane.set_editing_element(_selected_element)

	
	var delete_button: Button = Button.new()
	delete_button.text = "Delete Element"
	delete_button.pressed.connect(_handle_delete_element_button_pressed)
	_edit_element_root_container.add_child(delete_button)
	

func _add_label_to_edit_container(text: String) -> void:
	var new_label: Label = Label.new()
	new_label.text = text;
	_edit_element_grid_container.add_child(new_label)


func _add_float_prop_to_edit_container(label_text: String, prop_ref: FloatObj) -> void:
	_add_label_to_edit_container(label_text)
	var new_float_entry: FloatPropLineEdit = FloatPropLineEdit.new()
	new_float_entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_float_entry.set_property_reference(prop_ref)
	_edit_element_grid_container.add_child(new_float_entry)


func _add_string_prop_to_edit_container(label_text: String, prop_ref: StringObj) -> void:
	_add_label_to_edit_container(label_text)
	var new_string_entry: StringPropLineEdit = StringPropLineEdit.new()
	new_string_entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_string_entry.set_property_reference(prop_ref)
	_edit_element_grid_container.add_child(new_string_entry)


func _handle_selected_element_display_name_changed(_old_name: String, _new_name: String) -> void:
	open_session_data.update_display_name_of_element_to_be_unique(_selected_element)
	_list_of_elements_in_session.set_item_text(_selected_index, _selected_element._display_name.get_value())


func _handle_delete_element_button_pressed():
	open_session_data.delete_element(_selected_element)
	refresh()


func _handle_save_session_button_pressed() -> void:
	var save_dialog: FileDialog = SaveSessionDialogScene.instantiate()
	add_child(save_dialog)
	save_dialog.file_selected.connect(_handle_save_file_selected)
	save_dialog.popup()


func _handle_save_file_selected(path: String) -> void:
	open_session_data.save_to(path)


func _handle_visibility_changed() -> void:
	if _canvas_layer != null:
		_canvas_layer.visible = visible


func _handle_new_session_button_pressed() -> void:
	_new_session_confirmation_dialog.popup()


func _handle_new_session_confirmation_dialog_confirmed() -> void:
	on_new_session_confirmed.emit()


func set_session_data(in_session_data: SessionData) -> void:
	open_session_data = in_session_data
	refresh()

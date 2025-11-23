extends Node2D

const SESSION_SELECTED_LABEL_DEFAULT_VALUE = "Loaded file:\nNothing loaded"


var _canvas: CanvasLayer
var _session_selected_label: Label
var _scene_container: Node2D
var _select_session_dialog: FileDialog
var session_data : SessionData

var _hypno_scene_res: Resource = preload("res://Scenes/HypnoScene.tscn")
var _hypno_scene: Node2D

var _editing_scene_res: Resource = preload("res://Scenes/EditingScene.tscn")
var _editing_scene: EditingScene


func _ready() -> void:
	_canvas = $MainMenuUI
	_session_selected_label = $MainMenuUI/SessionSelectedLabel
	_scene_container = $SceneContainer
	_select_session_dialog = $MainMenuUI/SelectSession
	
	_session_selected_label.text = SESSION_SELECTED_LABEL_DEFAULT_VALUE
	_select_session_dialog.on_session_file_selected.connect(_handle_session_file_selected)
	
	session_data = SessionData.new()
	add_child(session_data)


func _start_hypno() -> void:
	_set_main_menu_visibility(false)
	if _hypno_scene == null:
		_hypno_scene = _hypno_scene_res.instantiate()
		_scene_container.add_child(_hypno_scene)
		_hypno_scene.hidden.connect(_handle_hypno_scene_hidden)
	_hypno_scene.set_session_data(session_data)
	_hypno_scene.show()
	_hypno_scene.begin_session()


func _start_editing() -> void:
	_set_main_menu_visibility(false)
	if _editing_scene == null:
		_editing_scene = _editing_scene_res.instantiate()
		_scene_container.add_child(_editing_scene)
		_editing_scene.hidden.connect(_handle_editing_scene_hidden)
		_editing_scene.on_new_session_confirmed.connect(_handle_editing_scene_new_session_confirmed)
	_editing_scene.set_session_data(session_data)
	_editing_scene.show()


func _load_session(path) -> void:
	session_data.load_from_file(path)
	_session_selected_label.text = "Loaded file:\n" + path.get_file()  # don't clobber up the label with a really long path


func _go_to_main_menu() -> void:
	_set_main_menu_visibility(true)


func _exit() -> void:
	# Never called?
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_exit_pressed() -> void:
	_exit()

	
func _set_main_menu_visibility(in_visible: bool) -> void:
	_canvas.visible = in_visible


func _handle_begin_hypnosis_pressed() -> void:
	_start_hypno()


func _handle_hypno_scene_hidden() -> void:
	_go_to_main_menu()


func _handle_begin_editing_button_pressed() -> void:
	_start_editing()


func _handle_editing_scene_hidden() -> void:
	_editing_scene.set_session_data(null)
	_go_to_main_menu()


func _handle_editing_scene_new_session_confirmed() -> void:
	remove_child(session_data)
	session_data = SessionData.new()
	add_child(session_data)
	_session_selected_label.text = SESSION_SELECTED_LABEL_DEFAULT_VALUE
	_editing_scene.set_session_data(session_data)

func _handle_session_file_selected(path: String) -> void:
	_load_session(path)

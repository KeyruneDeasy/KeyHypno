extends Node2D

var main_menu_ui: CanvasLayer
var SessionSelectedLabel: Label
var scene_container: Node2D
var selectedSessionPath: String
var reader: ZIPReader

var hypno_scene_res: Resource
var hypno_scene: Node2D
var hypno_scene_audio_player: AudioStreamPlayer
var hypno_scene_subliminal_label: Label

var editing_scene_res: Resource
var editing_scene: EditingScene

const HYPNO_SCENE_PATH = "res://Scenes/HypnoScene.tscn"
const EDITING_SCENE_PATH = "res://Scenes/EditingScene.tscn"


func _ready():
	main_menu_ui = $MainMenuUI
	SessionSelectedLabel = $MainMenuUI/SessionSelectedLabel
	scene_container = $SceneContainer
	ResourceLoader.load_threaded_request(HYPNO_SCENE_PATH)
	ResourceLoader.load_threaded_request(EDITING_SCENE_PATH)


func start_hypno():
	if hypno_scene == null:
		hypno_scene_res = ResourceLoader.load_threaded_get(HYPNO_SCENE_PATH)
		hypno_scene = hypno_scene_res.instantiate()
		scene_container.add_child(hypno_scene)
		hypno_scene_audio_player = $SceneContainer/HypnoScene/Control/ASPlayer2D
		hypno_scene_subliminal_label = $SceneContainer/HypnoScene/CanvasLayer/sub
		hypno_scene_audio_player.finished.connect(_on_play_finished)
		hypno_scene.hidden.connect(_on_hypno_scene_hidden)
	hypno_scene.set_visibility(true)
	main_menu_ui.visible = false
	hypno_scene.active_session_data = $SessionData
	hypno_scene.zip_reader = reader
	hypno_scene.begin_session()


func start_editing():
	if editing_scene == null:
		editing_scene_res = ResourceLoader.load_threaded_get(EDITING_SCENE_PATH)
		editing_scene = editing_scene_res.instantiate()
		scene_container.add_child(editing_scene)
		editing_scene.hidden.connect(_on_editing_scene_hidden)
	editing_scene.open_session_data = $SessionData
	editing_scene.set_visibility(true)
	main_menu_ui.visible = false


func setSessionPath(path):
	selectedSessionPath = path
	var session_data: SessionData = $SessionData
	reader = ZIPReader.new()
	reader.open(selectedSessionPath)
	var files = reader.get_files()
	files.sort()
	print(files)
	load_hypsav(session_data, reader)
	SessionSelectedLabel.text = "Loaded file:\n" + path.get_file()  # don't clobber up the label with a really long path


func go_to_main_menu():
	if hypno_scene != null:
		hypno_scene.set_visibility(false)
	if editing_scene != null:
		editing_scene.set_visibility(false)
	main_menu_ui.visible = true


func exit():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _on_exit_pressed():
	exit()


func _on_begin_hypnosis_pressed():
	start_hypno()


func _on_play_finished():
	go_to_main_menu()


func _on_hypno_scene_hidden() -> void:
	go_to_main_menu()


func _on_begin_editing_button_pressed():
	start_editing()


func _on_editing_scene_hidden() -> void:
	go_to_main_menu()


func decode(data: String) -> Array:
	# parse data
	var json = JSON.new()
	var error = json.parse(data)
	# verify data
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_ARRAY:
			data_received.sort_custom(func(a, b): return a["start_time"] < b["start_time"])  # sort by time so we can assume events are in order
			return data_received
		else:
			print("data is of invalid type")
			return []
	else:
		print(
			"JSON Parse Error: ",
			json.get_error_message(),
			" in ",
			data,
			" at line ",
			json.get_error_line()
		)
		return []


func encode(data: Array) -> String:
	return JSON.stringify(data)


func load_hypsav(session_data: SessionData, zip_reader: ZIPReader) -> void:
	var data = zip_reader.read_file("session.hypsav").get_string_from_utf8()
	session_data.reset_and_clear()
	var sav = decode(data)
	for e in sav:
		match e["type"]:
			"SUBLIMINAL":
				var s = session_data.add_element_of_class(session_data.SubliminalClass)
				s._type = "SUBLIMINAL"
				s._start_time = e["start_time"]
				s._end_time = e["end_time"]
				s._time_per_message = e["time_per_message"]
				for line in e["messages"]:
					s._messages.append(line)
			"AUDIO":
				var s = session_data.add_element_of_class(session_data.AudioClass)
				s._type = "AUDIO"
				s._start_time = e["start_time"]
				s._end_time = e["end_time"]
				s.path = e["path"]
			_:
				print("invalid event type" + e.type)
	#create_hypsav(session_data)


func create_hypsav(session_data: SessionData) -> String:
	var sav = []
	for e in session_data._elements:
		match e._type:
			"SUBLIMINAL":
				sav.append(
					{
						"type": e._type,
						"start_time": e._start_time,
						"end_time": e._end_time,
						"time_per_message": e._time_per_message,
						"messages": e._messages
					}
				)
			"AUDIO":
				sav.append(
					{
						"type": e._type,
						"start_time": e._start_time,
						"end_time": e._end_time,
						"path": e.path
					}
				)
			_:
				print("invalid event type" + e._type)

	return encode(sav)

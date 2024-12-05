extends Node2D

var main_menu_ui: CanvasLayer
var MP3SelectedLabel: Label
var SubSelectedLabel: Label
var scene_container: Node2D
var selectedAudioPath: String
var selectedSubPath: String

var hypno_scene_res: Resource
var hypno_scene: Node2D
var hypno_scene_audio_player: AudioStreamPlayer2D
var hypno_scene_subliminal_label: Label

var editing_scene_res: Resource
var editing_scene: EditingScene

const HYPNO_SCENE_PATH = "res://Scenes/HypnoScene.tscn"
const EDITING_SCENE_PATH = "res://Scenes/EditingScene.tscn"


func _ready():
	main_menu_ui = $MainMenuUI
	MP3SelectedLabel = $MainMenuUI/MP3SelectedLabel
	SubSelectedLabel = $MainMenuUI/SubSelectedLabel
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
	load_audio_from_path(selectedAudioPath)
	load_subliminal_from_path(selectedSubPath)
	hypno_scene_audio_player.play()
	main_menu_ui.visible = false
	hypno_scene.active_session_data = $SessionData
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


func setAudioPath(path):
	selectedAudioPath = path
	MP3SelectedLabel.text = "Loaded file:\n" + path


func setSubPath(path):
	selectedSubPath = path
	SubSelectedLabel.text = "Loaded file:\n" + path


func load_audio_from_path(path: String):
	if path.is_empty():
		return
	match path.right(3).to_lower():
		"ogg":
			hypno_scene_audio_player.stream = AudioStreamOggVorbis.load_from_file(path)
		"mp3":
			var file = FileAccess.open(path, FileAccess.READ)
			var mp3 = AudioStreamMP3.new()
			mp3.data = file.get_buffer(file.get_length())
			hypno_scene_audio_player.stream = mp3
		_:
			print("unexpected file type")


func load_subliminal_from_path(path: String):
	if path.is_empty():
		return
	if path.right(3).to_lower() == "txt":
		var file = FileAccess.open(path, FileAccess.READ)
		var text = file.get_as_text()
		var list = text.split("\n")
		print(list)
		hypno_scene_subliminal_label.list = list
		hypno_scene_subliminal_label.text = list[0]
	else:
		print("unexpected file type")


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


func load_hypsav(session_data: SessionData, data: String) -> void:
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
			_:
				print("invalid event type" + e._type)

	return encode(sav)


func _on_demo_session_1_button_pressed() -> void:
	var session_data: SessionData = $SessionData
	var file = FileAccess.open("res://Scripts/DemoSession1.hypsav", FileAccess.READ)
	var text = file.get_as_text()
	load_hypsav(session_data, text)

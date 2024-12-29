extends FileDialog

var selectedfile
var Main: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Main = $"../.."
	pass # Replace with function body.

func _on_FileDialog_file_selected(path: String):
	match path.right(6).to_lower():
		"hypsav":
			Main.setSessionPath(path)
		_:
			print("unexpected file type")
	

func _on_load_file_pressed():
	popup()


func _on_demo_session_1_button_pressed() -> void:
	pass # Replace with function body.

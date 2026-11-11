extends CanvasLayer
## Esc pause: Save / Load / Resume / Main Menu.

@onready var _root: Control = $Root
@onready var _status: Label = %Status
@onready var _save: Button = %SaveButton
@onready var _load: Button = %LoadButton
@onready var _resume: Button = %ResumeButton
@onready var _menu: Button = %MenuButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_root.visible = false
	_save.pressed.connect(_on_save)
	_load.pressed.connect(_on_load)
	_resume.pressed.connect(close)
	_menu.pressed.connect(_on_menu)
	SaveManager.save_completed.connect(_on_save_msg)
	SaveManager.load_completed.connect(_on_load_msg)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		if visible:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()


func open() -> void:
	if get_tree().current_scene and get_tree().current_scene.scene_file_path.ends_with("main_menu.tscn"):
		return
	if GameState.in_dialogue or GameState.awaiting_choice:
		return
	Inventory.close()
	visible = true
	_root.visible = true
	GameState.paused = true
	get_tree().paused = true
	_status.text = "Save slot: user://hp_remaster_slot0.json"
	if SaveManager.has_save():
		_load.disabled = false
		_status.text += " · save found"
	else:
		_load.disabled = false  # still allow; will show message
	_resume.grab_focus()


func close() -> void:
	visible = false
	_root.visible = false
	GameState.paused = false
	get_tree().paused = false


func _on_save() -> void:
	SaveManager.save_game()


func _on_load() -> void:
	close()
	SaveManager.load_game()


func _on_menu() -> void:
	close()
	GameState.go_to_scene("res://scenes/main_menu.tscn")


func _on_save_msg(ok: bool, message: String) -> void:
	_status.text = message if ok else "Save failed: %s" % message


func _on_load_msg(ok: bool, message: String) -> void:
	_status.text = message if ok else "Load failed: %s" % message

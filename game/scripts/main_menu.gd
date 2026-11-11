extends Control

@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _start: Button = %StartButton
@onready var _load: Button = %LoadButton
@onready var _quit: Button = %QuitButton
@onready var _save_hint: Label = %SaveHint


func _ready() -> void:
	_title.text = "Harry Potter"
	_subtitle.text = "and the Philosopher's Stone — Remaster"
	_start.pressed.connect(_on_start)
	_load.pressed.connect(_on_load)
	_quit.pressed.connect(_on_quit)
	_refresh_load()
	_start.grab_focus()
	var tween := create_tween().set_loops()
	tween.tween_property(_title, "modulate", Color(1.05, 0.98, 0.85, 1.0), 1.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_title, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.6).set_trans(Tween.TRANS_SINE)
	SaveManager.load_completed.connect(func(ok, msg): _save_hint.text = msg if ok else "Load failed: %s" % msg)


func _refresh_load() -> void:
	var has := SaveManager.has_save()
	_load.disabled = not has
	_save_hint.text = "Continue available (Esc saves in-game)" if has else "No save yet — Esc in-game to save"


func _on_start() -> void:
	_reset_new_game()
	get_tree().change_scene_to_file("res://scenes/privet_drive.tscn")


func _reset_new_game() -> void:
	GameState.from_save_dict({})
	Inventory.from_save_dict({})
	SpellBook.from_save_dict({"unlocked": ["lumos", "leviosa", "flipendo"], "selected": "lumos"})


func _on_load() -> void:
	SaveManager.load_game()


func _on_quit() -> void:
	get_tree().quit()

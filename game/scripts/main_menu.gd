extends Control

@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _start: Button = %StartButton
@onready var _quit: Button = %QuitButton


func _ready() -> void:
	_title.text = "Harry Potter"
	_subtitle.text = "and the Philosopher's Stone — Remaster"
	_start.pressed.connect(_on_start)
	_quit.pressed.connect(_on_quit)
	_start.grab_focus()
	# Soft title breathe — intentional motion #1
	var tween := create_tween().set_loops()
	tween.tween_property(_title, "modulate", Color(1.05, 0.98, 0.85, 1.0), 1.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_title, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.6).set_trans(Tween.TRANS_SINE)


func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/privet_drive.tscn")


func _on_quit() -> void:
	get_tree().quit()

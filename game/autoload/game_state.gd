extends Node
## Lightweight flags for the vertical-slice scaffold.

signal dialogue_started(lines: PackedStringArray, speaker: String)
signal dialogue_ended

var in_dialogue: bool = false
var lumos_active: bool = false


func start_dialogue(speaker: String, lines: PackedStringArray) -> void:
	in_dialogue = true
	dialogue_started.emit(lines, speaker)


func end_dialogue() -> void:
	in_dialogue = false
	dialogue_ended.emit()

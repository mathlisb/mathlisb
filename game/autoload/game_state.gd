extends Node
## Lightweight flags for the Diagon Alley vertical slice.

signal dialogue_started(lines: PackedStringArray, speaker: String)
signal dialogue_ended

var in_dialogue: bool = false
var lumos_active: bool = false
var talked_to_shopkeep: bool = false
var crate_puzzle_done: bool = false


func blocks_player() -> bool:
	return in_dialogue or Inventory.is_open


func start_dialogue(speaker: String, lines: PackedStringArray) -> void:
	Inventory.close()
	in_dialogue = true
	dialogue_started.emit(lines, speaker)


func end_dialogue() -> void:
	in_dialogue = false
	dialogue_ended.emit()

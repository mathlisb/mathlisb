extends Node
## Story flags, house affinity, and dialogue for Year One rooms.

signal dialogue_started(lines: PackedStringArray, speaker: String)
signal dialogue_choices_ready(prompt: String, choices: Array)
signal dialogue_ended
signal flags_changed

var in_dialogue: bool = false
var awaiting_choice: bool = false
var lumos_active: bool = false
var talked_to_shopkeep: bool = false
var crate_puzzle_done: bool = false

## Story progress
var visited_privet: bool = false
var left_privet: bool = false
var visited_diagon: bool = false
var reached_hogwarts: bool = false
var sorting_hint: String = ""

## Light RPG
var house_affinity: Dictionary = {
	&"gryffindor": 0,
	&"hufflepuff": 0,
	&"ravenclaw": 0,
	&"slytherin": 0,
}
var ron_trust: int = 0
var hermione_trust: int = 0

var _pending_choices: Array = []
var _choice_prompt: String = ""


func blocks_player() -> bool:
	return in_dialogue or awaiting_choice or Inventory.is_open


func start_dialogue(speaker: String, lines: PackedStringArray, choices: Array = [], choice_prompt: String = "What do you do?") -> void:
	Inventory.close()
	in_dialogue = true
	awaiting_choice = false
	_pending_choices = choices.duplicate(true)
	_choice_prompt = choice_prompt
	dialogue_started.emit(lines, speaker)


func request_choices_if_any() -> bool:
	if _pending_choices.is_empty():
		return false
	awaiting_choice = true
	dialogue_choices_ready.emit(_choice_prompt, _pending_choices)
	return true


func apply_choice(choice: Dictionary) -> void:
	awaiting_choice = false
	_pending_choices.clear()
	var effects: Dictionary = choice.get("effects", {})
	for key in effects:
		_apply_effect(StringName(str(key)), effects[key])
	flags_changed.emit()
	end_dialogue()


func end_dialogue() -> void:
	in_dialogue = false
	awaiting_choice = false
	_pending_choices.clear()
	dialogue_ended.emit()


func _apply_effect(key: StringName, value: Variant) -> void:
	match key:
		&"gryffindor", &"hufflepuff", &"ravenclaw", &"slytherin":
			house_affinity[key] = int(house_affinity.get(key, 0)) + int(value)
		&"ron_trust":
			ron_trust += int(value)
		&"hermione_trust":
			hermione_trust += int(value)
		&"sorting_hint":
			sorting_hint = str(value)
		_:
			set(String(key), value)


func leading_house() -> StringName:
	var best: StringName = &"gryffindor"
	var best_score := -999
	for h in house_affinity:
		if int(house_affinity[h]) > best_score:
			best_score = int(house_affinity[h])
			best = h
	return best


func go_to_scene(path: String) -> void:
	# Soft fade via modulate on current scene root if available.
	var tree := get_tree()
	if tree == null:
		return
	tree.change_scene_to_file(path)

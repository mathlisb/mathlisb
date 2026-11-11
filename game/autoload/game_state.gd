extends Node
## Story flags, house affinity, dialogue, and save serialization.

signal dialogue_started(lines: PackedStringArray, speaker: String)
signal dialogue_choices_ready(prompt: String, choices: Array)
signal dialogue_ended
signal flags_changed

var in_dialogue: bool = false
var awaiting_choice: bool = false
var paused: bool = false
var lumos_active: bool = false
var talked_to_shopkeep: bool = false
var crate_puzzle_done: bool = false

## Story progress
var visited_privet: bool = false
var left_privet: bool = false
var visited_diagon: bool = false
var reached_hogwarts: bool = false
var charms_lesson_done: bool = false
var defense_lesson_done: bool = false
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
	return in_dialogue or awaiting_choice or paused or Inventory.is_open


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
	var tree := get_tree()
	if tree == null:
		return
	paused = false
	tree.paused = false
	tree.change_scene_to_file(path)


func to_save_dict() -> Dictionary:
	var affinity := {}
	for h in house_affinity:
		affinity[String(h)] = int(house_affinity[h])
	return {
		"talked_to_shopkeep": talked_to_shopkeep,
		"crate_puzzle_done": crate_puzzle_done,
		"visited_privet": visited_privet,
		"left_privet": left_privet,
		"visited_diagon": visited_diagon,
		"reached_hogwarts": reached_hogwarts,
		"charms_lesson_done": charms_lesson_done,
		"defense_lesson_done": defense_lesson_done,
		"sorting_hint": sorting_hint,
		"house_affinity": affinity,
		"ron_trust": ron_trust,
		"hermione_trust": hermione_trust,
		"lumos_active": lumos_active,
	}


func from_save_dict(data: Dictionary) -> void:
	talked_to_shopkeep = bool(data.get("talked_to_shopkeep", false))
	crate_puzzle_done = bool(data.get("crate_puzzle_done", false))
	visited_privet = bool(data.get("visited_privet", false))
	left_privet = bool(data.get("left_privet", false))
	visited_diagon = bool(data.get("visited_diagon", false))
	reached_hogwarts = bool(data.get("reached_hogwarts", false))
	charms_lesson_done = bool(data.get("charms_lesson_done", false))
	defense_lesson_done = bool(data.get("defense_lesson_done", false))
	sorting_hint = str(data.get("sorting_hint", ""))
	ron_trust = int(data.get("ron_trust", 0))
	hermione_trust = int(data.get("hermione_trust", 0))
	lumos_active = bool(data.get("lumos_active", false))
	var affinity: Dictionary = data.get("house_affinity", {})
	for h in [&"gryffindor", &"hufflepuff", &"ravenclaw", &"slytherin"]:
		house_affinity[h] = int(affinity.get(String(h), 0))
	in_dialogue = false
	awaiting_choice = false
	paused = false
	_pending_choices.clear()
	flags_changed.emit()

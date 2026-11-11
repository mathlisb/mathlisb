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
var reached_platform: bool = false
var boarded_express: bool = false
var visited_express: bool = false
var lakeside_arrived: bool = false
var reached_hogwarts: bool = false
var visited_corridor: bool = false
var forbidden_tease_done: bool = false
var fluffy_teased: bool = false
var trapdoor_ready: bool = false
var charms_lesson_done: bool = false
var defense_lesson_done: bool = false
var potions_lesson_started: bool = false
var potions_lesson_done: bool = false
## Modest undercroft-prep tonic brewed in Potions (Year One craft).
var undercroft_tonic_ready: bool = false
var undercroft_entered: bool = false
var keys_chamber_done: bool = false
var chess_chamber_done: bool = false
var undercroft_logic_done: bool = false
var mirror_reached: bool = false
var sorting_hint: String = ""
## Empty until Sorting ceremony locks a house.
var sorted_house: String = ""
var house_locked: bool = false

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
			if not house_locked:
				house_affinity[key] = int(house_affinity.get(key, 0)) + int(value)
		&"ron_trust":
			ron_trust += int(value)
		&"hermione_trust":
			hermione_trust += int(value)
		&"sorting_hint":
			sorting_hint = str(value)
		&"lock_house":
			# value may be house name, or true to lock current leading house
			if typeof(value) == TYPE_STRING and str(value) != "":
				lock_house(str(value))
			else:
				lock_house(String(leading_house()))
		_:
			set(String(key), value)


func leading_house() -> StringName:
	if house_locked and sorted_house != "":
		return StringName(sorted_house)
	var best: StringName = &"gryffindor"
	var best_score := -999
	for h in house_affinity:
		if int(house_affinity[h]) > best_score:
			best_score = int(house_affinity[h])
			best = h
	return best


func lock_house(house: String = "") -> void:
	var pick := house.strip_edges().to_lower()
	if pick == "":
		pick = String(leading_house())
	if pick not in ["gryffindor", "hufflepuff", "ravenclaw", "slytherin"]:
		pick = String(leading_house())
	sorted_house = pick
	sorting_hint = pick
	house_locked = true
	# Ensure the chosen house leads for UI / future checks
	house_affinity[StringName(pick)] = maxi(int(house_affinity.get(StringName(pick), 0)), 5)
	flags_changed.emit()


func is_sorted() -> bool:
	return house_locked and sorted_house != ""


func house_display() -> String:
	if is_sorted():
		return sorted_house.capitalize()
	return String(leading_house()).capitalize() + " lean"


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
		"reached_platform": reached_platform,
		"boarded_express": boarded_express,
		"visited_express": visited_express,
		"lakeside_arrived": lakeside_arrived,
		"reached_hogwarts": reached_hogwarts,
		"visited_corridor": visited_corridor,
		"forbidden_tease_done": forbidden_tease_done,
		"fluffy_teased": fluffy_teased,
		"trapdoor_ready": trapdoor_ready,
		"charms_lesson_done": charms_lesson_done,
		"defense_lesson_done": defense_lesson_done,
		"potions_lesson_started": potions_lesson_started,
		"potions_lesson_done": potions_lesson_done,
		"undercroft_tonic_ready": undercroft_tonic_ready,
		"undercroft_entered": undercroft_entered,
		"keys_chamber_done": keys_chamber_done,
		"chess_chamber_done": chess_chamber_done,
		"undercroft_logic_done": undercroft_logic_done,
		"mirror_reached": mirror_reached,
		"sorting_hint": sorting_hint,
		"sorted_house": sorted_house,
		"house_locked": house_locked,
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
	reached_platform = bool(data.get("reached_platform", false))
	boarded_express = bool(data.get("boarded_express", false))
	visited_express = bool(data.get("visited_express", false))
	lakeside_arrived = bool(data.get("lakeside_arrived", false))
	reached_hogwarts = bool(data.get("reached_hogwarts", false))
	visited_corridor = bool(data.get("visited_corridor", false))
	forbidden_tease_done = bool(data.get("forbidden_tease_done", false))
	fluffy_teased = bool(data.get("fluffy_teased", false))
	trapdoor_ready = bool(data.get("trapdoor_ready", false))
	charms_lesson_done = bool(data.get("charms_lesson_done", false))
	defense_lesson_done = bool(data.get("defense_lesson_done", false))
	potions_lesson_started = bool(data.get("potions_lesson_started", false))
	potions_lesson_done = bool(data.get("potions_lesson_done", false))
	undercroft_tonic_ready = bool(data.get("undercroft_tonic_ready", false))
	undercroft_entered = bool(data.get("undercroft_entered", false))
	keys_chamber_done = bool(data.get("keys_chamber_done", false))
	chess_chamber_done = bool(data.get("chess_chamber_done", false))
	undercroft_logic_done = bool(data.get("undercroft_logic_done", false))
	mirror_reached = bool(data.get("mirror_reached", false))
	sorting_hint = str(data.get("sorting_hint", ""))
	sorted_house = str(data.get("sorted_house", ""))
	house_locked = bool(data.get("house_locked", false))
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

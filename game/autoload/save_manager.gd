extends Node
## JSON save/load under user:// for the macOS demo.

const SAVE_PATH := "user://hp_remaster_slot0.json"
const SAVE_VERSION := 1

signal save_completed(ok: bool, message: String)
signal load_completed(ok: bool, message: String)


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func current_scene_path() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	return scene.scene_file_path


func save_game() -> bool:
	var payload := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_datetime_string_from_system(),
		"scene": current_scene_path(),
		"game_state": GameState.to_save_dict(),
		"inventory": Inventory.to_save_dict(),
		"spell_book": SpellBook.to_save_dict(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		save_completed.emit(false, "Could not write save file.")
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	save_completed.emit(true, "Game saved.")
	return true


func load_game() -> bool:
	if not has_save():
		load_completed.emit(false, "No save found.")
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		load_completed.emit(false, "Could not read save file.")
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		load_completed.emit(false, "Save file corrupted.")
		return false
	var data: Dictionary = parsed
	GameState.from_save_dict(data.get("game_state", {}))
	Inventory.from_save_dict(data.get("inventory", {}))
	SpellBook.from_save_dict(data.get("spell_book", {}))
	var scene_path := str(data.get("scene", "res://scenes/privet_drive.tscn"))
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		scene_path = "res://scenes/privet_drive.tscn"
	load_completed.emit(true, "Game loaded.")
	GameState.go_to_scene(scene_path)
	return true

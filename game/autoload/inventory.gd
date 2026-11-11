extends Node
## Simple inventory stub — serializable for SaveManager.

signal changed
signal opened
signal closed

const MAX_SLOTS := 8

var items: Array[Dictionary] = []
var is_open: bool = false
var _booted: bool = false


func _ready() -> void:
	if items.is_empty():
		_give_starter_kit()
	_booted = true


func _give_starter_kit() -> void:
	items.clear()
	add_item(&"wand", "Holly Wand", "Eleven inches. Swishy. Placeholder.", "res://assets/pixel/item_wand.png", 1)
	add_item(&"letter", "Hogwarts Letter", "You're accepted — Diagon Alley awaits.", "res://assets/pixel/item_letter.png", 1)
	add_item(&"knuts", "Knuts", "A modest pouch for shop windows.", "res://assets/pixel/item_knuts.png", 17)


func add_item(id: StringName, display_name: String, description: String, icon_path: String, qty: int = 1) -> void:
	for item in items:
		if item["id"] == id or str(item["id"]) == String(id):
			item["qty"] = int(item["qty"]) + qty
			changed.emit()
			return
	items.append({
		"id": String(id),
		"name": display_name,
		"description": description,
		"icon": icon_path,
		"qty": qty,
	})
	changed.emit()


func has_item(id: StringName, qty: int = 1) -> bool:
	for item in items:
		if str(item["id"]) == String(id) and int(item["qty"]) >= qty:
			return true
	return false


func count_item(id: StringName) -> int:
	for item in items:
		if str(item["id"]) == String(id):
			return int(item["qty"])
	return 0


## Returns true if the qty was removed.
func consume_item(id: StringName, qty: int = 1) -> bool:
	for i in items.size():
		var item: Dictionary = items[i]
		if str(item["id"]) != String(id):
			continue
		if int(item["qty"]) < qty:
			return false
		item["qty"] = int(item["qty"]) - qty
		if int(item["qty"]) <= 0:
			items.remove_at(i)
		changed.emit()
		return true
	return false


func toggle() -> void:
	if GameState.in_dialogue or GameState.paused:
		return
	is_open = not is_open
	if is_open:
		opened.emit()
	else:
		closed.emit()


func close() -> void:
	if not is_open:
		return
	is_open = false
	closed.emit()


func to_save_dict() -> Dictionary:
	return {"items": items.duplicate(true)}


func from_save_dict(data: Dictionary) -> void:
	items.clear()
	var raw: Array = data.get("items", [])
	for entry in raw:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		items.append({
			"id": str(entry.get("id", "")),
			"name": str(entry.get("name", "")),
			"description": str(entry.get("description", "")),
			"icon": str(entry.get("icon", "")),
			"qty": int(entry.get("qty", 1)),
		})
	if items.is_empty():
		_give_starter_kit()
	is_open = false
	changed.emit()

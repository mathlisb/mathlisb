extends Node
## Simple inventory stub for the Diagon Alley vertical slice.

signal changed
signal opened
signal closed

const MAX_SLOTS := 8

## Each entry: { id, name, description, icon, qty }
var items: Array[Dictionary] = []
var is_open: bool = false


func _ready() -> void:
	# Starting kit for the slice — original placeholders, not ROM data.
	add_item(&"wand", "Holly Wand", "Eleven inches. Swishy. Placeholder.", "res://assets/placeholders/item_wand.png", 1)
	add_item(&"letter", "Hogwarts Letter", "You're accepted — Diagon Alley awaits.", "res://assets/placeholders/item_letter.png", 1)
	add_item(&"knuts", "Knuts", "A modest pouch for shop windows.", "res://assets/placeholders/item_knuts.png", 17)


func add_item(id: StringName, display_name: String, description: String, icon_path: String, qty: int = 1) -> void:
	for item in items:
		if item["id"] == id:
			item["qty"] = int(item["qty"]) + qty
			changed.emit()
			return
	items.append({
		"id": id,
		"name": display_name,
		"description": description,
		"icon": icon_path,
		"qty": qty,
	})
	changed.emit()


func toggle() -> void:
	if GameState.in_dialogue:
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

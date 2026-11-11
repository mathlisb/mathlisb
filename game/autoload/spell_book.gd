extends Node
## Starter + mid-tier spells. Unlocks persist via SaveManager.

signal spell_selected(spell_id: StringName)
signal spell_cast(spell_id: StringName, origin: Vector2, facing: Vector2)
signal unlocks_changed

const ALL_SPELLS := {
	&"lumos": {
		"display": "Lumos",
		"hint": "Light the dark corners.",
		"color": Color("fff0b4"),
		"cooldown": 0.35,
		"slot": 1,
	},
	&"leviosa": {
		"display": "Wingardium Leviosa",
		"hint": "Lift crates just enough.",
		"color": Color("b4dcc8"),
		"cooldown": 0.55,
		"slot": 2,
	},
	&"flipendo": {
		"display": "Flipendo",
		"hint": "A firm shove.",
		"color": Color("c87850"),
		"cooldown": 0.45,
		"slot": 3,
	},
	&"incendio": {
		"display": "Incendio",
		"hint": "Kindle a careful flame — Charms mid-tier.",
		"color": Color("ff8a3d"),
		"cooldown": 0.5,
		"slot": 4,
	},
	&"protego": {
		"display": "Protego",
		"hint": "Raise a shield — Defense Against the Dark Arts.",
		"color": Color("7ec8e8"),
		"cooldown": 0.6,
		"slot": 5,
	},
	&"immobulus": {
		"display": "Immobulus",
		"hint": "Freeze a foe mid-lunge for a breath.",
		"color": Color("a8dde8"),
		"cooldown": 0.7,
		"slot": 6,
	},
}

var selected: StringName = &"lumos"
var unlocked: Array[StringName] = [&"lumos", &"leviosa", &"flipendo"]
var _cooldown_left: float = 0.0
var protego_active: bool = false
var protego_time: float = 0.0


func _process(delta: float) -> void:
	if _cooldown_left > 0.0:
		_cooldown_left = maxf(0.0, _cooldown_left - delta)
	if protego_active:
		protego_time = maxf(0.0, protego_time - delta)
		if protego_time <= 0.0:
			protego_active = false


func unlocked_ordered() -> Array[StringName]:
	var out: Array[StringName] = []
	for id in [&"lumos", &"leviosa", &"flipendo", &"incendio", &"protego", &"immobulus"]:
		if id in unlocked:
			out.append(id)
	return out


func is_unlocked(spell_id: StringName) -> bool:
	return spell_id in unlocked


func unlock_spell(spell_id: StringName) -> bool:
	if not ALL_SPELLS.has(spell_id) or spell_id in unlocked:
		return false
	unlocked.append(spell_id)
	unlocks_changed.emit()
	select_spell(spell_id)
	return true


func select_spell(spell_id: StringName) -> void:
	if not ALL_SPELLS.has(spell_id) or not is_unlocked(spell_id):
		return
	selected = spell_id
	spell_selected.emit(selected)


func select_by_slot(slot: int) -> void:
	for id in unlocked_ordered():
		if int(ALL_SPELLS[id]["slot"]) == slot:
			select_spell(id)
			return


func can_cast() -> bool:
	return _cooldown_left <= 0.0 and is_unlocked(selected)


func cast(origin: Vector2, facing: Vector2) -> bool:
	if not can_cast():
		return false
	var data: Dictionary = ALL_SPELLS[selected]
	_cooldown_left = float(data["cooldown"])
	if selected == &"protego":
		protego_active = true
		protego_time = 1.6
	spell_cast.emit(selected, origin, facing.normalized())
	return true


func display_name(spell_id: StringName = selected) -> String:
	return str(ALL_SPELLS[spell_id]["display"])


func spell_color(spell_id: StringName = selected) -> Color:
	return ALL_SPELLS[spell_id]["color"] as Color


func to_save_dict() -> Dictionary:
	var ids: Array = []
	for id in unlocked:
		ids.append(String(id))
	return {
		"selected": String(selected),
		"unlocked": ids,
	}


func from_save_dict(data: Dictionary) -> void:
	unlocked.clear()
	var raw: Array = data.get("unlocked", ["lumos", "leviosa", "flipendo"])
	for id in raw:
		var sn := StringName(str(id))
		if ALL_SPELLS.has(sn) and sn not in unlocked:
			unlocked.append(sn)
	if unlocked.is_empty():
		unlocked = [&"lumos", &"leviosa", &"flipendo"]
	var sel := StringName(str(data.get("selected", "lumos")))
	selected = sel if is_unlocked(sel) else unlocked[0]
	unlocks_changed.emit()
	spell_selected.emit(selected)

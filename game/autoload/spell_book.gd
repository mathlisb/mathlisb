extends Node
## Starter spells for the Diagon Alley vertical slice.

signal spell_selected(spell_id: StringName)
signal spell_cast(spell_id: StringName, origin: Vector2, facing: Vector2)

enum SpellId { LUMOS, LEVIOSA, FLIPENDO }

const SPELLS := {
	&"lumos": {
		"display": "Lumos",
		"hint": "Light the dark corners of Diagon Alley.",
		"color": Color("fff0b4"),
		"cooldown": 0.35,
	},
	&"leviosa": {
		"display": "Wingardium Leviosa",
		"hint": "Lift crates and shop signs just enough.",
		"color": Color("b4dcc8"),
		"cooldown": 0.55,
	},
	&"flipendo": {
		"display": "Flipendo",
		"hint": "A firm shove — doors, barrels, mischief.",
		"color": Color("c87850"),
		"cooldown": 0.45,
	},
}

var selected: StringName = &"lumos"
var _cooldown_left: float = 0.0


func _process(delta: float) -> void:
	if _cooldown_left > 0.0:
		_cooldown_left = maxf(0.0, _cooldown_left - delta)


func select_spell(spell_id: StringName) -> void:
	if not SPELLS.has(spell_id):
		return
	selected = spell_id
	spell_selected.emit(selected)


func can_cast() -> bool:
	return _cooldown_left <= 0.0


func cast(origin: Vector2, facing: Vector2) -> bool:
	if not can_cast():
		return false
	var data: Dictionary = SPELLS[selected]
	_cooldown_left = float(data["cooldown"])
	spell_cast.emit(selected, origin, facing.normalized())
	return true


func display_name(spell_id: StringName = selected) -> String:
	return str(SPELLS[spell_id]["display"])


func spell_color(spell_id: StringName = selected) -> Color:
	return SPELLS[spell_id]["color"] as Color

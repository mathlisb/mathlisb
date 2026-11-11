extends Node2D
## Year One Potions — gather asphodel + wormwood, Lumos the brew, bottle a modest undercroft tonic.
## No new spells; uses inventory + Lumos only (see docs/year-one-spells.md).

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _snape: Area2D = $Interactables/Snape
@onready var _shelf_a: Area2D = $Interactables/AsphodelShelf
@onready var _shelf_w: Area2D = $Interactables/WormwoodShelf
@onready var _cauldron: Area2D = $Interactables/Cauldron
@onready var _brew_glow: Polygon2D = $Interactables/Cauldron/BrewGlow
@onready var _hint: Label = $HUDHints/Hint
@onready var _status: Label = $HUDHints/Status
@onready var _objective: Label = $HUDHints/Objective
@onready var _ambient: CanvasModulate = $CanvasModulate

var _awaiting_start: bool = false
var _brew_inspected: bool = false


func _ready() -> void:
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for area in [_snape, _shelf_a, _shelf_w, _cauldron]:
		area.body_entered.connect(_on_near.bind(area, true))
		area.body_exited.connect(_on_near.bind(area, false))
	SpellBook.spell_cast.connect(_on_spell_cast)
	Inventory.changed.connect(_refresh_status)
	GameState.dialogue_ended.connect(_on_dialogue_ended)
	GameState.flags_changed.connect(_refresh_objective)
	_brew_glow.modulate.a = 0.25
	_hint.text = "WASD · E · I satchel · 1 Lumos at the cauldron"
	_refresh_status()
	_refresh_objective()
	_apply_lumos()
	await get_tree().create_timer(0.25).timeout
	if GameState.potions_lesson_done:
		GameState.start_dialogue(
			"Professor Snape",
			PackedStringArray([
				"Your tonic is already bottled. Don't spill it in the corridors.",
				"When the undercroft opens, that draught may steady a first-year nerve. Modestly.",
			])
		)
	else:
		GameState.start_dialogue(
			"Professor Snape",
			PackedStringArray([
				"Potions. Not Charms. Not waving lights for applause.",
				"Speak to me for today's assignment — a simple Herbology bridge tonic. Inventory and patience. No theatrics.",
			])
		)


func _on_near(body: Node2D, area: Area2D, show: bool) -> void:
	if not body.is_in_group("player"):
		return
	var p: Label = area.get_node_or_null("Prompt")
	if p:
		p.visible = show and not GameState.blocks_player()


func _build_floor() -> void:
	var root: Node2D = $Floor/Tiles
	var tex: Texture2D = preload("res://assets/pixel/tile_stone.png")
	for y in range(-4, 5):
		for x in range(-6, 7):
			var spr := Sprite2D.new()
			spr.texture = tex
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = Vector2(x * 64 + 16, y * 64 + 16)
			spr.scale = Vector2(2, 2)
			spr.z_index = -2
			root.add_child(spr)


func _refresh_status() -> void:
	_status.text = "Satchel: asphodel %d · wormwood %d%s" % [
		Inventory.count_item(&"asphodel"),
		Inventory.count_item(&"wormwood"),
		" · tonic ready" if GameState.undercroft_tonic_ready else "",
	]


func _refresh_objective() -> void:
	if GameState.potions_lesson_done:
		_objective.text = "Next: Hall · undercroft prep flagged"
	elif not GameState.potions_lesson_started:
		_objective.text = "Next: talk to Snape for the brew assignment"
	elif not Inventory.has_item(&"asphodel") or not Inventory.has_item(&"wormwood"):
		_objective.text = "Next: take asphodel + wormwood from the shelves (E)"
	elif not _brew_inspected and not GameState.lumos_active:
		_objective.text = "Next: Lumos (1) at the cauldron, then E to brew"
	elif not _brew_inspected:
		_objective.text = "Next: E at the cauldron to bottle the tonic"
	else:
		_objective.text = "Next: E at the cauldron to finish the brew"


func _apply_lumos() -> void:
	_ambient.color = Color(0.9, 0.88, 0.7, 1.0) if GameState.lumos_active else Color(0.55, 0.58, 0.62, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if _in(_snape):
		_talk_snape()
	elif _in(_shelf_a):
		_take_asphodel()
	elif _in(_shelf_w):
		_take_wormwood()
	elif _in(_cauldron):
		_use_cauldron()


func _in(area: Area2D) -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _talk_snape() -> void:
	if GameState.potions_lesson_done:
		GameState.start_dialogue(
			"Professor Snape",
			PackedStringArray([
				"The tonic is yours. Undercroft prep — nothing more glamorous.",
				"Do not confuse this with Living Death. You are not ready.",
			])
		)
		return
	if GameState.potions_lesson_started:
		var missing: PackedStringArray = []
		if not Inventory.has_item(&"asphodel"):
			missing.append("asphodel")
		if not Inventory.has_item(&"wormwood"):
			missing.append("wormwood")
		if missing.is_empty():
			GameState.start_dialogue(
				"Professor Snape",
				PackedStringArray([
					"Ingredients in the satchel. Good.",
					"Lumos at the cauldron — read the simmer — then bottle it. I will know if you guessed.",
				])
			)
		else:
			GameState.start_dialogue(
				"Professor Snape",
				PackedStringArray([
					"Still missing: %s. Shelves. Not the floor." % ", ".join(missing),
				])
			)
		return
	_awaiting_start = true
	GameState.start_dialogue(
		"Professor Snape",
		PackedStringArray([
			"Assignment: a Herbology bridge tonic — asphodel root and dried wormwood.",
			"Gather both from my shelves. Lumos to judge the brew. Bottle it for later undercroft nerves. That is all.",
		]),
		[
			{"text": "Yes, Professor.", "effects": {"slytherin": 1}},
			{"text": "I'll follow the steps exactly.", "effects": {"ravenclaw": 1}},
			{"text": "As long as it helps my friends later.", "effects": {"hufflepuff": 1, "hermione_trust": 1}},
		],
		"Accept the Potions assignment?"
	)


func _on_dialogue_ended() -> void:
	if not _awaiting_start:
		return
	_awaiting_start = false
	GameState.potions_lesson_started = true
	GameState.flags_changed.emit()
	_refresh_objective()
	_status.text = "Assignment accepted — shelves, then cauldron"


func _take_asphodel() -> void:
	if not GameState.potions_lesson_started:
		GameState.start_dialogue("Shelf", PackedStringArray(["Snape's stores. Speak to him before you touch anything."]))
		return
	if Inventory.has_item(&"asphodel"):
		GameState.start_dialogue("Asphodel", PackedStringArray(["You already have asphodel root in your satchel (I)."]))
		return
	Inventory.add_item(
		&"asphodel",
		"Asphodel Root",
		"Pale root for a first-year bridge tonic.",
		"res://assets/pixel/item_asphodel.png",
		1
	)
	_refresh_status()
	_refresh_objective()
	GameState.start_dialogue("Asphodel", PackedStringArray(["Asphodel root tucked into the satchel."]))


func _take_wormwood() -> void:
	if not GameState.potions_lesson_started:
		GameState.start_dialogue("Shelf", PackedStringArray(["Snape's stores. Speak to him before you touch anything."]))
		return
	if Inventory.has_item(&"wormwood"):
		GameState.start_dialogue("Wormwood", PackedStringArray(["Dried wormwood already packed."]))
		return
	Inventory.add_item(
		&"wormwood",
		"Dried Wormwood",
		"Bitter leaves for a first-year bridge tonic.",
		"res://assets/pixel/item_wormwood.png",
		1
	)
	_refresh_status()
	_refresh_objective()
	GameState.start_dialogue("Wormwood", PackedStringArray(["Dried wormwood added to the satchel."]))


func _use_cauldron() -> void:
	if GameState.potions_lesson_done:
		GameState.start_dialogue("Cauldron", PackedStringArray(["The cauldron rests. Your tonic is already bottled."]))
		return
	if not GameState.potions_lesson_started:
		GameState.start_dialogue("Cauldron", PackedStringArray(["A simmering pot. Assignment first — speak to Snape."]))
		return
	if not Inventory.has_item(&"asphodel") or not Inventory.has_item(&"wormwood"):
		GameState.start_dialogue(
			"Cauldron",
			PackedStringArray(["Need asphodel and wormwood in the satchel before you brew."])
		)
		return
	if not GameState.lumos_active and not _brew_inspected:
		GameState.start_dialogue(
			"Cauldron",
			PackedStringArray([
				"The surface is murky. Cast Lumos (1) toward the cauldron to read the colour — then E again.",
			])
		)
		return
	_finish_brew()


func _on_spell_cast(spell_id: StringName, origin: Vector2, facing: Vector2) -> void:
	if spell_id == &"lumos":
		_apply_lumos()
		_refresh_objective()
	if spell_id != &"lumos":
		return
	if origin.distance_to(_cauldron.global_position) > 120.0:
		return
	var to_c := (_cauldron.global_position - origin).normalized()
	if facing.length() > 0.1 and to_c.dot(facing) < 0.05:
		return
	if not GameState.potions_lesson_started or GameState.potions_lesson_done:
		return
	if not Inventory.has_item(&"asphodel") or not Inventory.has_item(&"wormwood"):
		return
	_brew_inspected = true
	_brew_glow.modulate = Color(0.45, 0.95, 0.55, 0.85)
	_refresh_objective()
	GameState.start_dialogue(
		"Cauldron",
		PackedStringArray([
			"Lumos. The brew clears to a soft herb-green — correct for a bridge tonic.",
			"Press E to bottle it into your satchel.",
		])
	)


func _finish_brew() -> void:
	if not Inventory.has_item(&"asphodel") or not Inventory.has_item(&"wormwood"):
		GameState.start_dialogue("Cauldron", PackedStringArray(["Ingredients missing. Check the satchel."]))
		return
	Inventory.consume_item(&"asphodel", 1)
	Inventory.consume_item(&"wormwood", 1)
	Inventory.add_item(
		&"bridge_tonic",
		"Herbology Bridge Tonic",
		"A modest first-year draught. Undercroft nerves, not glory.",
		"res://assets/pixel/item_tonic.png",
		1
	)
	GameState.potions_lesson_done = true
	GameState.undercroft_tonic_ready = true
	GameState.flags_changed.emit()
	_brew_glow.modulate = Color(0.35, 0.8, 0.5, 0.5)
	_refresh_status()
	_refresh_objective()
	GameState.start_dialogue(
		"Professor Snape",
		PackedStringArray([
			"Acceptable. The tonic is in your satchel — undercroft prep, nothing heroic.",
			"Esc to save. Do not waste my ingredients again.",
		])
	)

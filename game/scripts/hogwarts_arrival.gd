extends Node2D
## Great Hall — Sorting ceremony locks house; Hermione teaches Alohomora; corridors unlock after.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _ron: Area2D = $Interactables/Ron
@onready var _hermione: Area2D = $Interactables/Hermione
@onready var _hat: Area2D = $Interactables/SortingHat
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective
@onready var _status: Label = $HUDHints/Status


func _ready() -> void:
	GameState.reached_hogwarts = true
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for area in [_ron, _hermione, _hat]:
		area.body_entered.connect(_make_prompt_cb(area, true))
		area.body_exited.connect(_make_prompt_cb(area, false))
	_hint.text = "WASD · E · Sort · Hermione · Charms/Defense/Potions"
	_refresh_objective()
	_refresh_status()
	GameState.flags_changed.connect(_refresh_status)
	GameState.flags_changed.connect(_refresh_objective)
	SpellBook.unlocks_changed.connect(_refresh_objective)

	await get_tree().create_timer(0.3).timeout
	if not GameState.is_sorted():
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"The Great Hall. Torches, long tables — and the Sorting Hat waiting for your name.",
				"Next: speak to the Hat. House lock opens the north corridors. Hermione has Alohomora when you're ready.",
			])
		)
	else:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"Sorted into %s. Charms east, Defense west, corridors north." % GameState.sorted_house.capitalize(),
			])
		)


func _make_prompt_cb(area: Area2D, show: bool) -> Callable:
	return func(body: Node2D) -> void:
		if body.is_in_group("player"):
			var prompt: Label = area.get_node_or_null("Prompt")
			if prompt:
				prompt.visible = show and not GameState.blocks_player()


func _build_floor() -> void:
	var root: Node2D = $Floor/Tiles
	var tex: Texture2D = preload("res://assets/pixel/tile_stone.png")
	for y in range(-4, 5):
		for x in range(-7, 8):
			var spr := Sprite2D.new()
			spr.texture = tex
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = Vector2(x * 64 + 16, y * 64 + 16)
			spr.scale = Vector2(2, 2)
			spr.z_index = -2
			root.add_child(spr)


func _refresh_objective() -> void:
	if not GameState.is_sorted():
		_objective.text = "Next: Sorting Hat ceremony (house lock)"
	elif GameState.mirror_reached:
		_objective.text = "Mirror reached · classes · corridor revisit OK"
	elif GameState.trapdoor_ready and GameState.undercroft_tonic_ready:
		_objective.text = "Next: corridor trapdoor → undercroft (tonic ready)"
	elif GameState.trapdoor_ready and not GameState.potions_lesson_done:
		_objective.text = "Next: Potions tonic (optional) · or corridor trapdoor"
	elif GameState.trapdoor_ready:
		_objective.text = "Next: corridor trapdoor → undercroft"
	elif GameState.fluffy_teased:
		_objective.text = "Next: trapdoor under Fluffy (north corridor)"
	elif GameState.forbidden_tease_done:
		_objective.text = "Next: Fluffy tease in the Forbidden Corridor"
	elif not SpellBook.is_unlocked(&"alohomora"):
		_objective.text = "Next: Hermione for Alohomora (4) · then north seal"
	elif GameState.visited_corridor:
		_objective.text = "Next: Alohomora on the sealed third-floor door"
	else:
		_objective.text = "Next: north corridors · classes · Potions SE"


func _refresh_status() -> void:
	_status.text = "House: %s · Ron %d · Hermione %d" % [
		GameState.house_display(),
		GameState.ron_trust,
		GameState.hermione_trust,
	]


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if _in(_ron):
		_talk_ron()
	elif _in(_hermione):
		_talk_hermione()
	elif _in(_hat):
		_talk_hat()


func _in(area: Area2D) -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _talk_ron() -> void:
	if GameState.is_sorted():
		GameState.start_dialogue(
			"Ron",
			PackedStringArray([
				"Sorted already? Brilliant. Stick with your table — and don't poke Fluffy alone.",
				"Corridors north when you're ready. Classes east and west.",
			]),
			[
				{"text": "We'll scout together later.", "effects": {"ron_trust": 1, "gryffindor": 0}},
				{"text": "Classes first.", "effects": {"ron_trust": 1}},
			],
			"How do you answer Ron?"
		)
		return
	GameState.start_dialogue(
		"Ron",
		PackedStringArray([
			"I'm Ron. Hat's waiting — don't overthink it. Mum says the Hat already knows.",
			"After you're Sorted, the north door opens the corridors. Third floor's out of bounds.",
		]),
		[
			{"text": "Stick with me after Sorting.", "effects": {"ron_trust": 2, "gryffindor": 1}},
			{"text": "Any tips for the Hat?", "effects": {"ron_trust": 1, "hufflepuff": 1}},
			{"text": "I want the best table.", "effects": {"slytherin": 1}},
		],
		"How do you answer Ron?"
	)


func _talk_hermione() -> void:
	var unlocked_now := SpellBook.unlock_spell(&"alohomora")
	if GameState.is_sorted():
		var lines := PackedStringArray([
			"%s suits the data so far. Alohomora is on your bar (4) — use it on the third-floor seal, then mind Fluffy." % GameState.sorted_house.capitalize(),
			"Charms east for Incendio (5). Defense west for Protego and Immobulus (6–7).",
		])
		if not unlocked_now and SpellBook.is_unlocked(&"alohomora"):
			lines = PackedStringArray([
				"Alohomora (4) is ready. Seal first — Fluffy and the trapdoor after. Classes east and west.",
			])
		GameState.start_dialogue(
			"Hermione",
			lines,
			[
				{"text": "Study first, then corridors.", "effects": {"hermione_trust": 1}},
				{"text": "I'll Alohomora the seal carefully.", "effects": {"hermione_trust": 1, "ravenclaw": 0}},
			],
			"How do you answer Hermione?"
		)
		_refresh_objective()
		return

	var lines := PackedStringArray([
		"Hermione. The Sorting isn't a suggestion — speak to the Hat before you wander.",
		"Alohomora opens simple locks. I'll place it on your bar — slot 4 — for the sealed corridor after you're Sorted.",
	])
	if not unlocked_now and SpellBook.is_unlocked(&"alohomora"):
		lines = PackedStringArray([
			"Alohomora is already on your bar (4). Sort first — then the third-floor seal.",
		])
	GameState.start_dialogue(
		"Hermione",
		lines,
		[
			{"text": "I'll Sort, then find you.", "effects": {"hermione_trust": 2, "ravenclaw": 1}},
			{"text": "Thanks for Alohomora.", "effects": {"hermione_trust": 1, "gryffindor": 1}},
			{"text": "Tonight's for meeting people.", "effects": {"hufflepuff": 1}},
		],
		"How do you answer Hermione?"
	)
	_refresh_objective()


func _talk_hat() -> void:
	if GameState.is_sorted():
		GameState.start_dialogue(
			"Sorting Hat",
			PackedStringArray([
				"Already decided. %s. The castle remembers — and so do I." % GameState.sorted_house.capitalize(),
				"North door's open. Mind the third floor.",
			])
		)
		_refresh_status()
		return

	var lean := GameState.leading_house()
	GameState.sorting_hint = String(lean)
	GameState.start_dialogue(
		"Sorting Hat",
		PackedStringArray([
			"Hmm… difficult. Courage, loyalty, wit, ambition — you've shown traces of each.",
			"The lean so far is %s. One last word before I call it." % String(lean).capitalize(),
			"Speak, and I lock your house for Year One.",
		]),
		[
			{
				"text": "Put me where I'll stand with friends.",
				"effects": {"gryffindor": 2, "lock_house": "gryffindor"},
			},
			{
				"text": "Put me where hard work is honored.",
				"effects": {"hufflepuff": 2, "lock_house": "hufflepuff"},
			},
			{
				"text": "Put me where questions are welcome.",
				"effects": {"ravenclaw": 2, "lock_house": "ravenclaw"},
			},
			{
				"text": "Put me where ambition finds a path.",
				"effects": {"slytherin": 2, "lock_house": "slytherin"},
			},
		],
		"How do you answer the Sorting Hat?"
	)
	_refresh_status()

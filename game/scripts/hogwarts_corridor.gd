extends Node2D
## Forbidden Corridor — Alohomora opens the seal → Fluffy tease → trapdoor stub.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _door: Area2D = $Interactables/ForbiddenDoor
@onready var _prefect: Area2D = $Interactables/Prefect
@onready var _fluffy: Area2D = $Interactables/Fluffy
@onready var _harp: Area2D = $Interactables/Harp
@onready var _trapdoor: Area2D = $Interactables/Trapdoor
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective
@onready var _ambient: CanvasModulate = $CanvasModulate

var _offer_descent_after: bool = false


func _ready() -> void:
	GameState.visited_corridor = true
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for area in [_door, _prefect, _fluffy, _harp, _trapdoor]:
		area.body_entered.connect(_make_prompt_cb(area, true))
		area.body_exited.connect(_make_prompt_cb(area, false))
	SpellBook.spell_cast.connect(_on_spell_cast)
	GameState.dialogue_ended.connect(_on_dialogue_ended)
	_apply_lumos_light()
	_hint.text = "WASD · E · 1 Lumos · 4 Alohomora · trapdoor when ready"
	_refresh_visibility()
	_refresh_objective()
	GameState.flags_changed.connect(_refresh_objective)
	GameState.flags_changed.connect(_refresh_visibility)
	await get_tree().create_timer(0.3).timeout
	if not GameState.forbidden_tease_done:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"Third-floor corridor. Rope, a lock — and something breathing beyond it.",
				"Next: Alohomora (4) on the sealed latch. Fluffy waits past it. The trapdoor is for later undercroft work.",
			])
		)
	elif not GameState.fluffy_teased:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"The seal is behind you. Three pairs of eyes ahead. Mind the harp — and the hatch in the floor.",
			])
		)


func _make_prompt_cb(area: Area2D, show: bool) -> Callable:
	return func(body: Node2D) -> void:
		if body.is_in_group("player"):
			var prompt: Label = area.get_node_or_null("Prompt")
			if prompt:
				prompt.visible = show and not GameState.blocks_player() and area.visible


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


func _refresh_visibility() -> void:
	var past := GameState.forbidden_tease_done
	_fluffy.visible = past
	_harp.visible = past
	_trapdoor.visible = past
	_fluffy.monitoring = past
	_harp.monitoring = past
	_trapdoor.monitoring = past
	var door_prompt: Label = _door.get_node_or_null("Prompt")
	if door_prompt:
		door_prompt.text = "E — Corridor seal" if past else "E — Sealed latch"


func _refresh_objective() -> void:
	if GameState.mirror_reached:
		_objective.text = "Mirror reached · Hall / classes · trapdoor revisit OK"
	elif GameState.trapdoor_ready:
		if GameState.undercroft_tonic_ready:
			_objective.text = "Next: E trapdoor → undercroft (tonic ready)"
		else:
			_objective.text = "Next: E trapdoor → undercroft (tonic optional via Potions)"
	elif GameState.fluffy_teased:
		_objective.text = "Next: inspect the trapdoor under Fluffy"
	elif GameState.forbidden_tease_done:
		_objective.text = "Next: Fluffy · harp · then the trapdoor"
	elif SpellBook.is_unlocked(&"alohomora"):
		_objective.text = "Next: cast Alohomora (4) on the sealed door"
	else:
		_objective.text = "Next: learn Alohomora from Hermione, then return"


func _apply_lumos_light() -> void:
	_ambient.color = Color(0.85, 0.88, 0.72, 1.0) if GameState.lumos_active else Color(0.42, 0.48, 0.46, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if _in(_door):
		_inspect_door()
	elif _in(_prefect):
		_talk_prefect()
	elif GameState.forbidden_tease_done and _in(_fluffy):
		_tease_fluffy()
	elif GameState.forbidden_tease_done and _in(_harp):
		_play_harp()
	elif GameState.forbidden_tease_done and _in(_trapdoor):
		_inspect_trapdoor()


func _in(area: Area2D) -> bool:
	if not area.visible or not area.monitoring:
		return false
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _inspect_door() -> void:
	if GameState.forbidden_tease_done:
		GameState.start_dialogue(
			"Corridor Seal",
			PackedStringArray([
				"The latch answered Alohomora. Beyond: three heads, a harp, and a hatch that shouldn't be here.",
			])
		)
		return
	if SpellBook.is_unlocked(&"alohomora"):
		GameState.start_dialogue(
			"Forbidden Corridor",
			PackedStringArray([
				"Rope, latch, and a lock that looks almost polite.",
				"Select Alohomora (4) and cast (J) toward the seal.",
			])
		)
	else:
		GameState.start_dialogue(
			"Forbidden Corridor",
			PackedStringArray([
				"Locked. A simple charm would open this — the kind Hermione knows.",
				"Learn Alohomora in the Great Hall, then return.",
			])
		)


func _on_spell_cast(spell_id: StringName, origin: Vector2, facing: Vector2) -> void:
	if spell_id == &"lumos":
		_apply_lumos_light()
		return
	if spell_id != &"alohomora" or GameState.forbidden_tease_done:
		return
	var door_pos: Vector2 = _door.global_position
	if origin.distance_to(door_pos) > 110.0:
		return
	var to_door := (door_pos - origin).normalized()
	if facing.length() > 0.1 and to_door.dot(facing) < 0.1:
		return
	_complete_tease()


func _complete_tease() -> void:
	GameState.forbidden_tease_done = true
	GameState.flags_changed.emit()
	_refresh_visibility()
	_refresh_objective()
	GameState.start_dialogue(
		"Forbidden Corridor",
		PackedStringArray([
			"Alohomora. The latch softens. Warm breath. A growl in three throats at once.",
			"Hagrid's… dog. Fluffy. And under one massive paw — a trapdoor.",
			"Next: ease Fluffy, then mark the hatch. The undercroft comes later.",
		]),
		[
			{"text": "Steady. We go carefully.", "effects": {"gryffindor": 1}},
			{"text": "Note everything before we move.", "effects": {"ravenclaw": 1, "hermione_trust": 1}},
			{"text": "Stay close — no one alone.", "effects": {"hufflepuff": 1, "ron_trust": 1}},
		],
		"How do you enter?"
	)


func _tease_fluffy() -> void:
	GameState.fluffy_teased = true
	_refresh_objective()
	GameState.start_dialogue(
		"Fluffy",
		PackedStringArray([
			"Three pairs of eyes track you. One head yawns; another snarls; the third watches the harp.",
			"Music helps — Hagrid said as much. Don't rush the hatch while he's alert.",
		]),
		[
			{"text": "Easy, boy. Easy…", "effects": {"hufflepuff": 1}},
			{"text": "Reach for the harp first.", "effects": {"ravenclaw": 1}},
			{"text": "Hold ground. No sudden moves.", "effects": {"gryffindor": 1}},
		],
		"How do you face Fluffy?"
	)


func _play_harp() -> void:
	if not GameState.fluffy_teased:
		GameState.start_dialogue(
			"Harp",
			PackedStringArray([
				"A battered harp leans by the wall. Fluffy's ears twitch toward it — try talking to him first.",
			])
		)
		return
	GameState.start_dialogue(
		"Harp",
		PackedStringArray([
			"A few soft notes. The growls thin. One head droops; then another.",
			"Fluffy sleeps — for now. The trapdoor is clear enough to mark.",
		]),
		[
			{"text": "Keep playing quietly.", "effects": {"hufflepuff": 1}},
			{"text": "Mark the hatch while he sleeps.", "effects": {"ravenclaw": 1}},
		],
		"What do you do?"
	)


func _inspect_trapdoor() -> void:
	if not GameState.fluffy_teased:
		GameState.start_dialogue(
			"Trapdoor",
			PackedStringArray([
				"Iron ring in the floorboards — under Fluffy's paw. Not while three heads are watching.",
			])
		)
		return
	GameState.trapdoor_ready = true
	_refresh_objective()
	if GameState.mirror_reached:
		GameState.start_dialogue(
			"Trapdoor",
			PackedStringArray([
				"The shaft still drops to keys, chess, bottles, and the Mirror.",
				"Enter again? E once more when this dialogue ends — or use the hatch prompt.",
			])
		)
		_offer_descent_after = true
		return
	var lines := PackedStringArray([
		"The hatch lifts. Cold air. Keys, a chess aisle, bottles, and a Mirror wait below.",
	])
	if GameState.undercroft_tonic_ready:
		lines.append("Bridge tonic ready — undercroft prep complete. Descent is open.")
	else:
		lines.append("No tonic yet — Potions can still help, but the shaft will take you either way.")
	_offer_descent_after = true
	GameState.start_dialogue(
		"Trapdoor",
		lines,
		[
			{"text": "Climb down.", "effects": {"gryffindor": 1}},
			{"text": "Check the satchel once more, then down.", "effects": {"ravenclaw": 1}},
			{"text": "Wish Ron and Hermione were here — then down.", "effects": {"hufflepuff": 1}},
		],
		"Enter the undercroft?"
	)


func _talk_prefect() -> void:
	var lines := PackedStringArray([
		"First years don't wander the third floor. Dumbledore's orders — and mine.",
		"If that latch yields to Alohomora, read the warning — then mind Fluffy. Great Hall is south.",
	])
	if GameState.mirror_reached:
		lines = PackedStringArray([
			"You came back pale. I don't want to know. Hall. Now.",
		])
	elif GameState.trapdoor_ready:
		lines = PackedStringArray([
			"You look like you've seen something you shouldn't. Keep it quiet — and keep walking south.",
		])
	elif GameState.forbidden_tease_done:
		lines = PackedStringArray([
			"That door was sealed for a reason. If Hagrid's dog is awake, you leave. Now.",
		])
	GameState.start_dialogue(
		"Prefect",
		lines,
		[
			{"text": "Heading back to the Hall.", "effects": {"hufflepuff": 1}},
			{"text": "Why guard this floor so hard?", "effects": {"ravenclaw": 1}},
			{"text": "I'll decide where I walk.", "effects": {"slytherin": 1}},
		],
		"What do you say to the prefect?"
	)


func _on_dialogue_ended() -> void:
	if not _offer_descent_after:
		return
	_offer_descent_after = false
	if GameState.trapdoor_ready:
		GameState.go_to_scene("res://scenes/undercroft_keys.tscn")

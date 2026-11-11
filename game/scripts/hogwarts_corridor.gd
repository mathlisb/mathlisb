extends Node2D
## Forbidden Corridor — sealed door → Fluffy tease → trapdoor stub (undercroft later).

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _door: Area2D = $Interactables/ForbiddenDoor
@onready var _prefect: Area2D = $Interactables/Prefect
@onready var _fluffy: Area2D = $Interactables/Fluffy
@onready var _harp: Area2D = $Interactables/Harp
@onready var _trapdoor: Area2D = $Interactables/Trapdoor
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective


func _ready() -> void:
	GameState.visited_corridor = true
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for area in [_door, _prefect, _fluffy, _harp, _trapdoor]:
		area.body_entered.connect(_make_prompt_cb(area, true))
		area.body_exited.connect(_make_prompt_cb(area, false))
	_hint.text = "WASD · E · Lumos · Esc save"
	_refresh_visibility()
	_refresh_objective()
	GameState.flags_changed.connect(_refresh_objective)
	GameState.flags_changed.connect(_refresh_visibility)
	await get_tree().create_timer(0.3).timeout
	if not GameState.forbidden_tease_done:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"Third-floor corridor. Rope, a seal — and something breathing beyond it.",
				"Next: open the sealed door. Fluffy waits. The trapdoor is for later undercroft work.",
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
	# Past the seal: Fluffy, harp, trapdoor become the active set.
	var past := GameState.forbidden_tease_done
	_fluffy.visible = past
	_harp.visible = past
	_trapdoor.visible = past
	_fluffy.monitoring = past
	_harp.monitoring = past
	_trapdoor.monitoring = past
	# Sealed door stays for re-read, but prompt updates
	var door_prompt: Label = _door.get_node_or_null("Prompt")
	if door_prompt:
		door_prompt.text = "E — Corridor seal" if past else "E — Sealed door"


func _refresh_objective() -> void:
	if GameState.trapdoor_ready:
		_objective.text = "Next: undercroft later · return to Hall for classes"
	elif GameState.fluffy_teased:
		_objective.text = "Next: inspect the trapdoor under Fluffy"
	elif GameState.forbidden_tease_done:
		_objective.text = "Next: Fluffy · harp · then the trapdoor"
	else:
		_objective.text = "Next: open the sealed third-floor door"


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
				"The rope hangs loose now. Beyond: three heads, a harp, and a hatch that shouldn't be here.",
			])
		)
		return
	GameState.forbidden_tease_done = true
	_refresh_visibility()
	_refresh_objective()
	GameState.start_dialogue(
		"Forbidden Corridor",
		PackedStringArray([
			"The seal yields. Warm breath. A growl in three throats at once.",
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
	GameState.start_dialogue(
		"Trapdoor",
		PackedStringArray([
			"The hatch lifts a finger's width. Cold air. A shaft into dark — keys, puzzles, and worse wait below.",
			"You've marked the way. The undercroft is flagged for later. Don't drop in tonight.",
		]),
		[
			{"text": "Close it. We'll return prepared.", "effects": {"ravenclaw": 1, "hermione_trust": 1}},
			{"text": "One look — then back to the Hall.", "effects": {"gryffindor": 1}},
			{"text": "Tell Ron and Hermione what we found.", "effects": {"hufflepuff": 1, "ron_trust": 1}},
		],
		"How do you leave the hatch?"
	)


func _talk_prefect() -> void:
	var lines := PackedStringArray([
		"First years don't wander the third floor. Dumbledore's orders — and mine.",
		"Great Hall is south. Charms and Defense are off the Hall.",
	])
	if GameState.trapdoor_ready:
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

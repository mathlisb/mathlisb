extends Node2D
## Mid-castle corridor stub — GBC-style path toward the Forbidden / third-floor corridor.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _door: Area2D = $Interactables/ForbiddenDoor
@onready var _prefect: Area2D = $Interactables/Prefect
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective


func _ready() -> void:
	GameState.visited_corridor = true
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for area in [_door, _prefect]:
		area.body_entered.connect(_make_prompt_cb(area, true))
		area.body_exited.connect(_make_prompt_cb(area, false))
	_hint.text = "WASD · E · Lumos for dark stretches"
	_refresh_objective()
	await get_tree().create_timer(0.3).timeout
	if not GameState.forbidden_tease_done:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"Stone corridors twist like a riddle with too many answers.",
				"Ahead: a sealed door and a prefect who would rather you turned around.",
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
	if GameState.forbidden_tease_done:
		_objective.text = "Next: return to the Great Hall · classes await"
	else:
		_objective.text = "Next: inspect the sealed third-floor door"


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if _in(_door):
		_inspect_door()
	elif _in(_prefect):
		_talk_prefect()


func _in(area: Area2D) -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _inspect_door() -> void:
	GameState.forbidden_tease_done = true
	_refresh_objective()
	GameState.start_dialogue(
		"Forbidden Corridor",
		PackedStringArray([
			"A heavy door. Rope across the latch. A note in firm handwriting: Out of Bounds to all who value their lives.",
			"Something large breathes on the other side — not yet. The castle will open this path when Year One is ready.",
		]),
		[
			{"text": "I'll come back when I'm ready.", "effects": {"gryffindor": 1}},
			{"text": "Note every detail. This is a puzzle for later.", "effects": {"ravenclaw": 1, "hermione_trust": 1}},
			{"text": "Warn the others to stay clear for now.", "effects": {"hufflepuff": 1, "ron_trust": 1}},
		],
		"How do you answer the sealed door?"
	)


func _talk_prefect() -> void:
	GameState.start_dialogue(
		"Prefect",
		PackedStringArray([
			"First years don't wander the third floor. Dumbledore's orders — and mine.",
			"Great Hall is south. Charms and Defense are off the Hall. Stay on the lit stairs.",
		]),
		[
			{"text": "Just looking. Heading back now.", "effects": {"hufflepuff": 1}},
			{"text": "Why is that door forbidden?", "effects": {"ravenclaw": 1}},
			{"text": "I'll decide where I walk, thanks.", "effects": {"slytherin": 1}},
		],
		"What do you say to the prefect?"
	)

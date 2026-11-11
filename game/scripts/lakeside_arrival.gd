extends Node2D
## Hogwarts Express / Black Lake arrival — between Platform 9¾ and the Great Hall.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _carriage: Area2D = $Interactables/Carriage
@onready var _boat: Area2D = $Interactables/Boat
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective


func _ready() -> void:
	GameState.visited_express = true
	GameState.lakeside_arrived = true
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for area in [_carriage, _boat]:
		area.body_entered.connect(_make_prompt_cb(area, true))
		area.body_exited.connect(_make_prompt_cb(area, false))
	_hint.text = "WASD · E · Next: boats to the castle"
	_refresh_objective()
	await get_tree().create_timer(0.3).timeout
	if not GameState.reached_hogwarts:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"The Express slows. Mist lifts off the Black Lake — Hogwarts waits on the far shore.",
				"Next: leave the carriage, take a boat. Sorting waits in the Great Hall.",
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
	var path: Texture2D = preload("res://assets/pixel/tile_path.png")
	var stone: Texture2D = preload("res://assets/pixel/tile_stone.png")
	for y in range(-4, 5):
		for x in range(-7, 8):
			var spr := Sprite2D.new()
			# Shore band near the bottom of the lake backdrop
			spr.texture = path if y >= 1 else stone
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = Vector2(x * 64 + 16, y * 64 + 16)
			spr.scale = Vector2(2, 2)
			spr.z_index = -2
			root.add_child(spr)


func _refresh_objective() -> void:
	_objective.text = "Next: boats to Great Hall · Sorting ahead"


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if _in(_carriage):
		_talk_carriage()
	elif _in(_boat):
		_talk_boat()


func _in(area: Area2D) -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _talk_carriage() -> void:
	GameState.start_dialogue(
		"Hogwarts Express",
		PackedStringArray([
			"Scarlet paint, brass fittings, and the last whistle fading over the trees.",
			"First years don't stay aboard — the lake path is the way in.",
		]),
		[
			{"text": "One last look from the window.", "effects": {"ravenclaw": 1}},
			{"text": "Right — down to the boats.", "effects": {"gryffindor": 1}},
		],
		"What do you do?"
	)


func _talk_boat() -> void:
	GameState.start_dialogue(
		"Lake Boats",
		PackedStringArray([
			"Small boats bump the shore. Torches glitter on the castle windows across the water.",
			"Sit steady. The Great Hall — and the Sorting Hat — wait on the other side.",
		]),
		[
			{"text": "Push off. I'm ready.", "effects": {"gryffindor": 1}},
			{"text": "Count the lanterns. Don't tip us.", "effects": {"hufflepuff": 1}},
			{"text": "Memorize the silhouette of the towers.", "effects": {"ravenclaw": 1}},
		],
		"How do you cross?"
	)

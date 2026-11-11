extends Node2D
## King's Cross / Platform 9¾ — GBC-faithful beat between Diagon and Hogwarts.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _barrier: Area2D = $Interactables/Barrier
@onready var _porter: Area2D = $Interactables/Porter
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective


func _ready() -> void:
	GameState.reached_platform = true
	GameState.visited_diagon = true
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for area in [_barrier, _porter]:
		area.body_entered.connect(_make_prompt_cb(area, true))
		area.body_exited.connect(_make_prompt_cb(area, false))
	_hint.text = "WASD · E · Next: board the Express"
	_refresh_objective()
	await get_tree().create_timer(0.3).timeout
	if not GameState.boarded_express:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"King's Cross. Ordinary platforms left and right — and a brick wall that isn't ordinary at all.",
				"Next: walk straight at the barrier between nine and ten. Don't stop.",
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
	var stone: Texture2D = preload("res://assets/pixel/tile_stone.png")
	var path: Texture2D = preload("res://assets/pixel/tile_path.png")
	for y in range(-4, 5):
		for x in range(-7, 8):
			var spr := Sprite2D.new()
			spr.texture = path if abs(x) <= 1 else stone
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = Vector2(x * 64 + 16, y * 64 + 16)
			spr.scale = Vector2(2, 2)
			spr.z_index = -2
			root.add_child(spr)


func _refresh_objective() -> void:
	if GameState.boarded_express:
		_objective.text = "Next: Express / Black Lake (north door)"
	else:
		_objective.text = "Next: run the barrier · talk to the porter"


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if _in(_barrier):
		_run_barrier()
	elif _in(_porter):
		_talk_porter()


func _in(area: Area2D) -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _run_barrier() -> void:
	GameState.boarded_express = true
	_refresh_objective()
	GameState.start_dialogue(
		"Barrier 9¾",
		PackedStringArray([
			"Brick softens — then yields. Steam, scarlet coaches, and a whistle that belongs to another world.",
			"You're through. The Hogwarts Express waits on Platform Nine and Three-Quarters.",
		]),
		[
			{"text": "Find a seat and watch the countryside unroll.", "effects": {"hufflepuff": 1}},
			{"text": "Head for the front — I want to see everything.", "effects": {"gryffindor": 1}},
			{"text": "Check the carriage map twice before sitting.", "effects": {"ravenclaw": 1}},
		],
		"How do you board?"
	)


func _talk_porter() -> void:
	GameState.start_dialogue(
		"Station Porter",
		PackedStringArray([
			"First years? Straight at the wall between nine and ten. Trolley and all — don't hesitate.",
			"Once you're through, the Express takes you to Hogwarts. No side trips.",
		]),
		[
			{"text": "Understood. Straight through.", "effects": {"gryffindor": 1}},
			{"text": "Any advice for the journey?", "effects": {"ravenclaw": 1, "hermione_trust": 1}},
		],
		"What do you say?"
	)

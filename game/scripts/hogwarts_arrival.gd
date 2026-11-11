extends Node2D
## Hogwarts arrival stub — Great Hall / courtyard beat.

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
	_hint.text = "WASD · E · Corridors north · Charms E · Defense W"
	_refresh_objective()
	_refresh_status()
	GameState.flags_changed.connect(_refresh_status)
	GameState.flags_changed.connect(_refresh_objective)
	await get_tree().create_timer(0.3).timeout
	GameState.start_dialogue(
		"Narrator",
		PackedStringArray([
			"Hogwarts. Meet Ron and Hermione, hear the Sorting Hat — then the north door opens the castle corridors.",
			"Charms is east. Defense is west. The sealed third-floor door waits up the corridor path.",
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
		_objective.text = "Next: Charms east · Defense west · classes"
	elif GameState.visited_corridor:
		_objective.text = "Next: sealed third-floor door (north corridor)"
	else:
		_objective.text = "Next: friends · Hat · north corridors"


func _refresh_status() -> void:
	_status.text = "House lean: %s · Ron %d · Hermione %d" % [
		String(GameState.leading_house()).capitalize(),
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
	GameState.start_dialogue(
		"Ron",
		PackedStringArray([
			"I'm Ron. First years get lost — stick to the Hall until you know the stairs.",
			"Heard there's a corridor upstairs that's out of bounds. We're not going near it. Yet.",
		]),
		[
			{"text": "Stick with me — we'll figure it out.", "effects": {"ron_trust": 2, "gryffindor": 1}},
			{"text": "Any tips before classes?", "effects": {"ron_trust": 1, "hufflepuff": 1}},
			{"text": "I want the best seat near the feast.", "effects": {"slytherin": 1}},
		],
		"How do you answer Ron?"
	)


func _talk_hermione() -> void:
	GameState.start_dialogue(
		"Hermione",
		PackedStringArray([
			"Hermione. Charms east, Defense west — and don't poke the third-floor seal without a plan.",
			"I've mapped a route. Classes first; forbidden corridors later.",
		]),
		[
			{"text": "I'd love to study with you.", "effects": {"hermione_trust": 2, "ravenclaw": 1}},
			{"text": "After we scout the corridors?", "effects": {"hermione_trust": 1, "gryffindor": 1}},
			{"text": "Tonight's for meeting people.", "effects": {"hufflepuff": 1}},
		],
		"How do you answer Hermione?"
	)


func _talk_hat() -> void:
	var lean := GameState.leading_house()
	GameState.sorting_hint = String(lean)
	GameState.start_dialogue(
		"Sorting Hat",
		PackedStringArray([
			"Not a full Sorting — a lean for now. Classes and choices will finish the work.",
			"I sense… %s. North lies the corridor you shouldn't open yet." % String(lean).capitalize(),
		])
	)
	_refresh_status()

extends Node2D
## Short Privet Drive intro beat before Diagon Alley.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _letter: Area2D = $Interactables/Letter
@onready var _hagrid: Area2D = $Interactables/Hagrid
@onready var _hint: Label = $HUDHints/Hint


func _ready() -> void:
	GameState.visited_privet = true
	_build_ground()
	_camera.zoom = Vector2(2.35, 2.35)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_letter.body_entered.connect(func(b): _set_prompt(_letter, b, true))
	_letter.body_exited.connect(func(b): _set_prompt(_letter, b, false))
	_hagrid.body_entered.connect(func(b): _set_prompt(_hagrid, b, true))
	_hagrid.body_exited.connect(func(b): _set_prompt(_hagrid, b, false))
	_hint.text = "WASD · E · Next: letter → Hagrid → Diagon Alley"
	await get_tree().create_timer(0.35).timeout
	if not GameState.left_privet:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"Number four, Privet Drive. Read the letter. Talk to Hagrid. Then the garden gate opens Diagon Alley.",
			])
		)


func _build_ground() -> void:
	var root: Node2D = $Floor/Tiles
	var lawn: Texture2D = preload("res://assets/pixel/tile_lawn.png")
	var path: Texture2D = preload("res://assets/pixel/tile_path.png")
	for y in range(-4, 5):
		for x in range(-7, 8):
			var spr := Sprite2D.new()
			spr.texture = path if abs(x) <= 1 else lawn
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = Vector2(x * 64 + 16, y * 64 + 16)
			spr.scale = Vector2(2, 2)
			spr.z_index = -2
			root.add_child(spr)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if _player_in(_letter):
		_talk_letter()
	elif _player_in(_hagrid):
		_talk_hagrid()


func _player_in(area: Area2D) -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _set_prompt(area: Area2D, body: Node2D, show: bool) -> void:
	if not body.is_in_group("player"):
		return
	var prompt: Label = area.get_node_or_null("Prompt")
	if prompt:
		prompt.visible = show and not GameState.in_dialogue


func _talk_letter() -> void:
	_set_prompt(_letter, $Player, false)
	GameState.start_dialogue(
		"Hogwarts Letter",
		PackedStringArray([
			"You have been accepted at Hogwarts School of Witchcraft and Wizardry.",
			"Term begins on 1 September. Please find enclosed a list of all necessary books and equipment.",
		]),
		[
			{"text": "Read it aloud — loud enough for the whole street.", "effects": {"gryffindor": 1}},
			{"text": "Study every line twice. Details matter.", "effects": {"ravenclaw": 1}},
			{"text": "Fold it carefully. Keep it safe.", "effects": {"hufflepuff": 1}},
		],
		"How do you answer the letter?"
	)


func _talk_hagrid() -> void:
	_set_prompt(_hagrid, $Player, false)
	GameState.left_privet = true
	GameState.start_dialogue(
		"Hagrid",
		PackedStringArray([
			"Yeh weren't meant ter grow up without knowin' who yeh are.",
			"Next stop: Diagon Alley for yer wand an' kit — then King's Cross, Platform 9¾, then Hogwarts.",
			"Garden gate's open when yer ready.",
		]),
		[
			{"text": "I'm ready. Diagon Alley.", "effects": {"gryffindor": 1}},
			{"text": "Walk me through the whole route first.", "effects": {"ravenclaw": 1, "hermione_trust": 1}},
			{"text": "As long as we stick together.", "effects": {"hufflepuff": 1, "ron_trust": 1}},
		],
		"What do you say to Hagrid?"
	)

extends Node2D
## Mirror of Erised vault — look sets mirror_reached; north opens Quirrell/Stone climax.
## Tone shaped by PS climax staging; dialogue is original.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _mirror: Area2D = $Interactables/Mirror
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective
@onready var _ambient: CanvasModulate = $CanvasModulate
@onready var _to_climax: Node = $ToClimax

var _advance_to_climax: bool = false


func _ready() -> void:
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	create_tween().tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_mirror.body_entered.connect(_prompt.bind(true))
	_mirror.body_exited.connect(_prompt.bind(false))
	SpellBook.spell_cast.connect(_on_spell_cast)
	GameState.dialogue_ended.connect(_on_dialogue_ended)
	_ambient.color = Color(0.75, 0.78, 0.9, 1.0) if GameState.lumos_active else Color(0.45, 0.48, 0.62, 1.0)
	_hint.text = "WASD · E Mirror · north after looking"
	if _to_climax:
		_to_climax.visible = GameState.mirror_reached
	_refresh_objective()
	await get_tree().create_timer(0.3).timeout
	if GameState.year_one_complete:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"The glass is only glass again. The Stone is secure. North still leads to the quiet vault — or south climbs home.",
			])
		)
	elif GameState.mirror_reached:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"You've already looked. Something waits beyond the glass — a man who wants the Stone more than truth.",
				"North when you're ready.",
			])
		)
	else:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"A tall glass in a quiet vault. It shows the heart — never the pocket.",
				"Look. Then the path behind the wish opens.",
			])
		)


func _prompt(body: Node2D, show: bool) -> void:
	if body.is_in_group("player"):
		var p: Label = _mirror.get_node_or_null("Prompt")
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


func _refresh_objective() -> void:
	if GameState.year_one_complete:
		_objective.text = "Year One complete · north vault or south corridor"
	elif GameState.mirror_reached:
		_objective.text = "Next: north — Quirrell and the Stone"
	else:
		_objective.text = "Next: E — look into the Mirror of Erised"


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	for body in _mirror.get_overlapping_bodies():
		if body.is_in_group("player"):
			_look_mirror()
			return


func _on_spell_cast(spell_id: StringName, _o: Vector2, _f: Vector2) -> void:
	if spell_id == &"lumos":
		_ambient.color = Color(0.75, 0.78, 0.9, 1.0) if GameState.lumos_active else Color(0.45, 0.48, 0.62, 1.0)


func _look_mirror() -> void:
	if GameState.year_one_complete:
		GameState.start_dialogue(
			"Mirror of Erised",
			PackedStringArray([
				"Only memory now — a wish kept, a Stone secured. The Hall is warmer than this glass.",
			])
		)
		return
	if GameState.mirror_reached:
		_advance_to_climax = true
		GameState.start_dialogue(
			"Mirror of Erised",
			PackedStringArray([
				"The wish still glows — then a footstep behind the glass that isn't yours.",
				"Quirrell. The Stone. First-year tools only. Ready?",
			]),
			[
				{"text": "I'm ready.", "effects": {"gryffindor": 1}},
				{"text": "Steady. Think first.", "effects": {"ravenclaw": 1}},
			],
			"Enter the Stone vault?"
		)
		return
	GameState.mirror_reached = true
	GameState.flags_changed.emit()
	if _to_climax:
		_to_climax.visible = true
	_refresh_objective()
	var house := GameState.house_display()
	_advance_to_climax = true
	GameState.start_dialogue(
		"Mirror of Erised",
		PackedStringArray([
			"Warmth that isn't in the vault — a table, laughter, belonging.",
			"House: %s. The glass keeps the heart; it will not hand over the Stone." % house,
			"A stammering shadow steps from the dark. He came for what you will not give.",
		]),
		[
			{"text": "Face him.", "effects": {"gryffindor": 2}},
			{"text": "Mark the room. Then face him.", "effects": {"ravenclaw": 1, "hermione_trust": 1}},
			{"text": "For everyone upstairs.", "effects": {"hufflepuff": 1, "ron_trust": 1}},
		],
		"How do you answer the Mirror?"
	)


func _on_dialogue_ended() -> void:
	if not _advance_to_climax:
		return
	_advance_to_climax = false
	if GameState.mirror_reached and not GameState.year_one_complete:
		GameState.go_to_scene("res://scenes/undercroft_climax.tscn")

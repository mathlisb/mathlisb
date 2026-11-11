extends Node2D
## Undercroft climax tease — Mirror of Erised. Sets mirror_reached; no final boss yet.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _mirror: Area2D = $Interactables/Mirror
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective
@onready var _ambient: CanvasModulate = $CanvasModulate


func _ready() -> void:
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	create_tween().tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_mirror.body_entered.connect(_prompt.bind(true))
	_mirror.body_exited.connect(_prompt.bind(false))
	SpellBook.spell_cast.connect(_on_spell_cast)
	_ambient.color = Color(0.75, 0.78, 0.9, 1.0) if GameState.lumos_active else Color(0.45, 0.48, 0.62, 1.0)
	_hint.text = "WASD · E Mirror · Esc save · portal south back up"
	_refresh_objective()
	await get_tree().create_timer(0.3).timeout
	if GameState.mirror_reached:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"The Mirror still waits. Year One ends in a look — not a duel. Not yet.",
			])
		)
	else:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"A tall glass in a quiet vault. Desire without a wand to win it.",
				"Next: look. This is the tease — the Stone's keeper is a story for a later build.",
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
	if GameState.mirror_reached:
		_objective.text = "Year One tease complete · south portal → corridor"
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
	GameState.mirror_reached = true
	GameState.flags_changed.emit()
	_refresh_objective()
	var house := GameState.house_display()
	GameState.start_dialogue(
		"Mirror of Erised",
		PackedStringArray([
			"You see warmth that isn't in the vault — family, friends, a table that feels like home.",
			"House lean: %s. The glass shows the heart, not the Stone." % house,
			"A figure might stand behind this wish in a fuller game. For now: you reached the Mirror. Year One holds its breath.",
		]),
		[
			{"text": "I'll come back when I'm ready.", "effects": {"gryffindor": 1}},
			{"text": "Map every step for Hermione.", "effects": {"ravenclaw": 1, "hermione_trust": 1}},
			{"text": "Find Ron. No one faces this alone.", "effects": {"hufflepuff": 1, "ron_trust": 1}},
		],
		"How do you leave the Mirror?"
	)

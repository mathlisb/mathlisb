extends Node2D
## Undercroft chamber 1 — flying keys. Leviosa or Flipendo settles a key; door opens north.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _key: Area2D = $Interactables/FlyingKey
@onready var _door: Area2D = $Interactables/KeyedDoor
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective
@onready var _ambient: CanvasModulate = $CanvasModulate
@onready var _key_sprite: Sprite2D = $Interactables/FlyingKey/Sprite

var _key_settled: bool = false
var _key_base: Vector2
var _advance_after_dialogue: bool = false


func _ready() -> void:
	GameState.undercroft_entered = true
	if GameState.keys_chamber_done:
		_key_settled = true
	_key_base = _key.position
	_build_floor()
	_camera.zoom = Vector2(2.3, 2.3)
	create_tween().tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for area in [_key, _door]:
		area.body_entered.connect(_prompt.bind(area, true))
		area.body_exited.connect(_prompt.bind(area, false))
	SpellBook.spell_cast.connect(_on_spell_cast)
	GameState.dialogue_ended.connect(_on_dialogue_ended)
	_ambient.color = Color(0.85, 0.86, 0.7, 1.0) if GameState.lumos_active else Color(0.38, 0.4, 0.48, 1.0)
	_hint.text = "WASD · 2 Leviosa / 3 Flipendo on the key · E door"
	_refresh_objective()
	if not _key_settled:
		_start_key_drift()
	await get_tree().create_timer(0.25).timeout
	var lines := PackedStringArray([
		"Wings of brass and silver — keys circling a locked hatch north.",
		"Year One tools: Leviosa to settle one, or Flipendo to knock it down. Then the door.",
	])
	if GameState.undercroft_tonic_ready:
		lines.append("The bridge tonic steadies your hands. Good. You prepared.")
	elif GameState.trapdoor_ready:
		lines.append("No tonic — nerves raw. You can still try.")
	GameState.start_dialogue("Narrator", lines)


func _start_key_drift() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(_key, "position:x", _key_base.x + 40.0, 1.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_key, "position:x", _key_base.x - 40.0, 1.1).set_trans(Tween.TRANS_SINE)


func _prompt(body: Node2D, area: Area2D, show: bool) -> void:
	if body.is_in_group("player"):
		var p: Label = area.get_node_or_null("Prompt")
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
	if GameState.keys_chamber_done:
		_objective.text = "Next: north door → chess chamber"
	elif _key_settled:
		_objective.text = "Next: E on the keyed door"
	else:
		_objective.text = "Next: Leviosa or Flipendo the flying key"


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if _in(_door):
		_try_door()
	elif _in(_key):
		GameState.start_dialogue(
			"Flying Key",
			PackedStringArray([
				"Too quick to grab by hand. Leviosa (2) or Flipendo (3), then J." if not _key_settled else "The key rests. Use the door.",
			])
		)


func _in(area: Area2D) -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _on_spell_cast(spell_id: StringName, origin: Vector2, facing: Vector2) -> void:
	if spell_id == &"lumos":
		_ambient.color = Color(0.85, 0.86, 0.7, 1.0) if GameState.lumos_active else Color(0.38, 0.4, 0.48, 1.0)
	if _key_settled or GameState.keys_chamber_done:
		return
	if spell_id not in [&"leviosa", &"flipendo"]:
		return
	if origin.distance_to(_key.global_position) > 130.0:
		return
	var to_k := (_key.global_position - origin).normalized()
	if facing.length() > 0.1 and to_k.dot(facing) < 0.0:
		return
	_settle_key(spell_id)


func _settle_key(spell_id: StringName) -> void:
	_key_settled = true
	# Stop drift by killing tweens on key
	for c in _key.get_children():
		pass
	_key.position = _key_base + Vector2(0, 30)
	var tw := create_tween()
	tw.tween_property(_key_sprite, "modulate", Color(1.1, 1.0, 0.7, 1.0), 0.2)
	_refresh_objective()
	var verb := "Leviosa steadies" if spell_id == &"leviosa" else "Flipendo knocks down"
	GameState.start_dialogue(
		"Flying Key",
		PackedStringArray([
			"%s a brass key. It falls warm into reach." % verb,
			"The north door will take it — E when ready.",
		])
	)


func _try_door() -> void:
	if GameState.keys_chamber_done:
		GameState.go_to_scene("res://scenes/undercroft_chess.tscn")
		return
	if not _key_settled:
		GameState.start_dialogue("Keyed Door", PackedStringArray(["Locked. Settle a flying key first."]))
		return
	GameState.keys_chamber_done = true
	GameState.flags_changed.emit()
	_refresh_objective()
	_advance_after_dialogue = true
	GameState.start_dialogue(
		"Keyed Door",
		PackedStringArray([
			"The key turns. Beyond: a cold chamber of stone pieces — a chessboard that wants shoving.",
		]),
		[
			{"text": "Go on.", "effects": {"gryffindor": 1}},
			{"text": "Note the lock for later maps.", "effects": {"ravenclaw": 1}},
		],
		"Enter the next chamber?"
	)


func _on_dialogue_ended() -> void:
	if not _advance_after_dialogue:
		return
	_advance_after_dialogue = false
	GameState.go_to_scene("res://scenes/undercroft_chess.tscn")

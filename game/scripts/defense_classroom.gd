extends Node2D
## Defense Against the Dark Arts — unlock Protego + Immobulus; train on a dummy.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _teacher: Area2D = $Interactables/Teacher
@onready var _dummy: Area2D = $Interactables/Dummy
@onready var _hint: Label = $HUDHints/Hint
@onready var _status: Label = $HUDHints/Status
@onready var _shield: Polygon2D = $Player/ProtegoShield

var _awaiting_unlock: bool = false


func _ready() -> void:
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_teacher.body_entered.connect(_on_near.bind(_teacher, true))
	_teacher.body_exited.connect(_on_near.bind(_teacher, false))
	_dummy.defeated.connect(_on_dummy_defeated)
	SpellBook.unlocks_changed.connect(_refresh_status)
	SpellBook.spell_cast.connect(_on_spell_cast)
	GameState.dialogue_ended.connect(_on_dialogue_ended)
	_shield.modulate.a = 0.0
	_hint.text = "WASD · E talk · 5 Protego · 6 Immobulus · J cast · Esc save"
	_refresh_status()
	await get_tree().create_timer(0.25).timeout
	if GameState.defense_lesson_done:
		GameState.start_dialogue(
			"Defense Professor",
			PackedStringArray([
				"Back for more drills? Protego and Immobulus are still on your bar.",
				"Keep the dummy honest — shield first, then freeze, then finish.",
			])
		)
	else:
		GameState.start_dialogue(
			"Defense Professor",
			PackedStringArray([
				"Defense Against the Dark Arts. Today: Protego and Immobulus.",
				"Speak with me to learn them, then defeat the training dummy.",
			])
		)


func _on_near(body: Node2D, area: Area2D, show: bool) -> void:
	if not body.is_in_group("player"):
		return
	var p: Label = area.get_node_or_null("Prompt")
	if p:
		p.visible = show and not GameState.blocks_player()


func _build_floor() -> void:
	var root: Node2D = $Floor/Tiles
	var tex: Texture2D = preload("res://assets/pixel/tile_defense.png")
	for y in range(-4, 5):
		for x in range(-6, 7):
			var spr := Sprite2D.new()
			spr.texture = tex
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = Vector2(x * 64 + 16, y * 64 + 16)
			spr.scale = Vector2(2, 2)
			spr.z_index = -2
			root.add_child(spr)


func _refresh_status() -> void:
	var names: PackedStringArray = []
	for id in SpellBook.unlocked_ordered():
		names.append(String(id))
	_status.text = "Spells: %s%s" % [
		", ".join(names),
		" · drill complete" if GameState.defense_lesson_done else "",
	]


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if _player_in(_teacher):
		_talk_teacher()


func _player_in(area: Area2D) -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _talk_teacher() -> void:
	if SpellBook.is_unlocked(&"protego") and SpellBook.is_unlocked(&"immobulus"):
		GameState.start_dialogue(
			"Defense Professor",
			PackedStringArray([
				"Protego (5) raises your shield. Immobulus (6) freezes the dummy.",
				"Flipendo or Incendio finishes the bout. Reset? Walk away and return later.",
			])
		)
		if not GameState.defense_lesson_done and _dummy.has_method("reset_dummy"):
			pass
		return
	_awaiting_unlock = true
	GameState.start_dialogue(
		"Defense Professor",
		PackedStringArray([
			"Protego! A shimmering wall — then Immobulus to pin the threat.",
			"I'll place both charms on your wand. Clear the dummy to pass.",
		]),
		[
			{"text": "Teach me — I'll stand my ground.", "effects": {"gryffindor": 1}},
			{"text": "I'll study the timing carefully.", "effects": {"ravenclaw": 1}},
			{"text": "As long as no one gets hurt for real.", "effects": {"hufflepuff": 1}},
		],
		"Begin the Defense lesson?"
	)


func _on_dialogue_ended() -> void:
	if not _awaiting_unlock:
		return
	_awaiting_unlock = false
	var got := false
	got = SpellBook.unlock_spell(&"protego") or got
	got = SpellBook.unlock_spell(&"immobulus") or got
	if got or SpellBook.is_unlocked(&"protego"):
		_refresh_status()
		_status.text = "Unlocked: Protego (5) · Immobulus (6) — defeat the dummy!"
		if _dummy.has_method("reset_dummy"):
			_dummy.reset_dummy()


func _on_spell_cast(spell_id: StringName, _origin: Vector2, _facing: Vector2) -> void:
	if spell_id == &"protego":
		_shield.modulate = Color(0.55, 0.85, 1.0, 0.65)
		var tween := create_tween()
		tween.tween_property(_shield, "modulate:a", 0.65, 0.08)
		tween.tween_interval(1.2)
		tween.tween_property(_shield, "modulate:a", 0.0, 0.35)


func _on_dummy_defeated() -> void:
	if GameState.defense_lesson_done:
		return
	GameState.defense_lesson_done = true
	GameState.flags_changed.emit()
	_refresh_status()
	await get_tree().create_timer(0.4).timeout
	GameState.start_dialogue(
		"Defense Professor",
		PackedStringArray([
			"Well fought! Protego and Immobulus are yours — they save with the rest.",
			"Esc to save, then back through the hall when you're ready.",
		])
	)

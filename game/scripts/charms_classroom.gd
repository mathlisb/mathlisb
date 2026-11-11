extends Node2D
## Hogwarts Charms lesson — unlock Incendio by lighting the practice candle.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _flitwick: Area2D = $Interactables/Flitwick
@onready var _candle: Area2D = $Interactables/Candle
@onready var _candle_flame: Polygon2D = $Interactables/Candle/Flame
@onready var _ambient: CanvasModulate = $CanvasModulate
@onready var _hint: Label = $HUDHints/Hint
@onready var _status: Label = $HUDHints/Status

var _candle_lit: bool = false
var _awaiting_lesson_choice: bool = false


func _ready() -> void:
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_candle_flame.modulate.a = 0.15
	_flitwick.body_entered.connect(_on_near.bind(_flitwick, true))
	_flitwick.body_exited.connect(_on_near.bind(_flitwick, false))
	_candle.body_entered.connect(_on_near.bind(_candle, true))
	_candle.body_exited.connect(_on_near.bind(_candle, false))
	SpellBook.spell_cast.connect(_on_spell_cast)
	SpellBook.unlocks_changed.connect(_refresh_status)
	GameState.dialogue_ended.connect(_on_dialogue_ended)
	_hint.text = "WASD · E talk · 4 Incendio (after lesson) · Esc save"
	_refresh_status()
	await get_tree().create_timer(0.25).timeout
	if GameState.charms_lesson_done:
		_set_candle_lit(true)
		GameState.start_dialogue(
			"Professor Flitwick",
			PackedStringArray([
				"Back again? Your Incendio is already on the spell bar — slot 4.",
				"A careful flame only, mind. Charms rewards precision.",
			])
		)
	else:
		GameState.start_dialogue(
			"Professor Flitwick",
			PackedStringArray([
				"Welcome to Charms! Today: Incendio — a controlled spark.",
				"Speak with me for the charm, then light the practice candle with it.",
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
	var tex: Texture2D = preload("res://assets/pixel/tile_wood_floor.png")
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
	_status.text = "Spells: %s%s" % [", ".join(names), " · lesson complete" if GameState.charms_lesson_done else ""]


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if _in(_flitwick):
		_talk_flitwick()
	elif _in(_candle):
		_hint_candle()


func _in(area: Area2D) -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _talk_flitwick() -> void:
	if GameState.charms_lesson_done:
		GameState.start_dialogue(
			"Professor Flitwick",
			PackedStringArray([
				"Excellent work. Incendio is yours — press 4, then J near a wick.",
				"House points for careful casting. Off you go!",
			])
		)
		return
	_awaiting_lesson_choice = true
	GameState.start_dialogue(
		"Professor Flitwick",
		PackedStringArray([
			"Incendio! Swish toward the wick — not the curtains.",
			"I'll place the charm on your wand. Light the candle to finish the lesson.",
		]),
		[
			{"text": "I'm ready — teach me Incendio.", "effects": {"ravenclaw": 1}},
			{"text": "I'll be careful with the flame.", "effects": {"hufflepuff": 1}},
			{"text": "Let's make it spectacular.", "effects": {"gryffindor": 1}},
		],
		"Begin the Charms lesson?"
	)


func _on_dialogue_ended() -> void:
	if not _awaiting_lesson_choice:
		return
	_awaiting_lesson_choice = false
	if SpellBook.unlock_spell(&"incendio"):
		_refresh_status()
		_status.text = "Unlocked: Incendio (4) — light the candle!"


func _hint_candle() -> void:
	if _candle_lit:
		GameState.start_dialogue("Practice Candle", PackedStringArray(["The wick glows steadily. Lesson complete."]))
	elif SpellBook.is_unlocked(&"incendio"):
		GameState.start_dialogue(
			"Practice Candle",
			PackedStringArray(["Select Incendio (4) and cast (J) toward the candle."])
		)
	else:
		GameState.start_dialogue(
			"Practice Candle",
			PackedStringArray(["Speak to Professor Flitwick first — Incendio isn't on your bar yet."])
		)


func _on_spell_cast(spell_id: StringName, origin: Vector2, facing: Vector2) -> void:
	if spell_id != &"incendio":
		return
	var candle_pos: Vector2 = _candle.global_position
	if origin.distance_to(candle_pos) > 100.0:
		return
	var to_c := (candle_pos - origin).normalized()
	if facing.length() > 0.1 and to_c.dot(facing) < 0.15:
		return
	_set_candle_lit(true)
	if not GameState.charms_lesson_done:
		GameState.charms_lesson_done = true
		GameState.flags_changed.emit()
		_refresh_status()
		await get_tree().create_timer(0.35).timeout
		GameState.start_dialogue(
			"Professor Flitwick",
			PackedStringArray([
				"Perfect! Incendio is yours for good — saved with the rest of your progress.",
				"Press Esc to save before you wander the castle.",
			])
		)


func _set_candle_lit(lit: bool) -> void:
	_candle_lit = lit
	var target_a := 1.0 if lit else 0.15
	var amb := Color(1.0, 0.9, 0.75, 1.0) if lit else Color(0.72, 0.74, 0.88, 1.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_candle_flame, "modulate:a", target_a, 0.35)
	tween.tween_property(_ambient, "color", amb, 0.4)
	if lit:
		tween.tween_property(_candle_flame, "scale", Vector2(1.3, 1.3), 0.2)
		tween.chain().tween_property(_candle_flame, "scale", Vector2.ONE, 0.25)

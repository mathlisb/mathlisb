extends Node2D
## Year One climax stub — Quirrell before the Stone.
## Staging inspired by PS climax shape (Mirror → keeper → Stone), original dialogue only.
## Combat: Protego + Immobulus + Flipendo/Incendio. No Patronum.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _quirrell: Area2D = $Interactables/Quirrell
@onready var _stone: Sprite2D = $Stone
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective
@onready var _status: Label = $HUDHints/Status
@onready var _ambient: CanvasModulate = $CanvasModulate
@onready var _shield: Polygon2D = $Player/ProtegoShield
@onready var _epilogue: CanvasLayer = $Epilogue
@onready var _epilogue_label: Label = $Epilogue/Panel/Label
@onready var _hall_portal: Node = $ToHall

var _fight_started: bool = false
var _awaiting_fight_start: bool = false


func _ready() -> void:
	_build_floor()
	_camera.zoom = Vector2(2.35, 2.35)
	create_tween().tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_shield.modulate.a = 0.0
	_epilogue.visible = false
	_hall_portal.visible = GameState.year_one_complete
	SpellBook.spell_cast.connect(_on_spell_cast)
	GameState.dialogue_ended.connect(_on_dialogue_ended)
	if _quirrell.has_signal("defeated"):
		_quirrell.defeated.connect(_on_quirrell_defeated)
	_ambient.color = Color(0.7, 0.55, 0.55, 1.0) if not GameState.year_one_complete else Color(0.75, 0.78, 0.85, 1.0)
	_hint.text = "WASD · 6 Protego · 7 Immobulus · 3 Flipendo · J"
	_refresh_ui()
	await get_tree().create_timer(0.3).timeout
	if GameState.year_one_complete:
		_show_epilogue(false)
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"The vault is quiet. The Stone is gone from this place — secured beyond Quirrell's reach.",
				"Year One holds. The Hall waits above when you're ready.",
			])
		)
	else:
		_awaiting_fight_start = true
		GameState.start_dialogue(
			"Professor Quirrell",
			PackedStringArray([
				"So… the Mirror showed you kindness. How… touching.",
				"I need what it hides. You will stand aside — or I will make you.",
				"No ancient lights. No borrowed miracles. Just your first-year tricks against mine.",
			]),
			[
				{"text": "I won't let you take it.", "effects": {"gryffindor": 2}},
				{"text": "Think. This ends badly for you.", "effects": {"ravenclaw": 1}},
				{"text": "Stay behind me — whatever you are.", "effects": {"hufflepuff": 1}},
			],
			"Face Quirrell?"
		)


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


func _refresh_ui() -> void:
	if GameState.year_one_complete:
		_objective.text = "Year One complete · E south → Great Hall"
		_status.text = "Stone secured"
		_hint.text = "WASD · E Hall portal · Esc save"
	elif _fight_started:
		_objective.text = "Protego (6) · Immobulus (7) · Flipendo (3) / Incendio (5)"
		_status.text = "Hold the vault"
	else:
		_objective.text = "Next: confront Quirrell"
		_status.text = "Climax"


func _on_dialogue_ended() -> void:
	if not _awaiting_fight_start or GameState.year_one_complete:
		return
	_awaiting_fight_start = false
	_fight_started = true
	_refresh_ui()
	if _quirrell.has_method("begin_combat"):
		_quirrell.begin_combat()


func _on_spell_cast(spell_id: StringName, _o: Vector2, _f: Vector2) -> void:
	if spell_id == &"protego":
		_shield.modulate = Color(0.55, 0.85, 1.0, 0.65)
		var tween := create_tween()
		tween.tween_property(_shield, "modulate:a", 0.65, 0.08)
		tween.tween_interval(1.2)
		tween.tween_property(_shield, "modulate:a", 0.0, 0.35)
	if spell_id == &"lumos":
		_ambient.color = Color(0.85, 0.7, 0.65, 1.0) if GameState.lumos_active else Color(0.7, 0.55, 0.55, 1.0)


func _on_quirrell_defeated() -> void:
	if GameState.year_one_complete:
		return
	GameState.quirrell_defeated = true
	GameState.stone_secured = true
	GameState.year_one_complete = true
	GameState.flags_changed.emit()
	_hall_portal.visible = true
	_ambient.color = Color(0.78, 0.8, 0.88, 1.0)
	_stone.modulate = Color(1.2, 1.05, 0.7, 1.0)
	_refresh_ui()
	_show_epilogue(true)
	await get_tree().create_timer(0.45).timeout
	GameState.start_dialogue(
		"Narrator",
		PackedStringArray([
			"Quirrell falls. The vault exhales. Whatever wore his shadow cannot hold.",
			"The Stone never belonged in greedy hands — and tonight, it doesn't.",
			"Year One is yours: friends above, a house that claimed you, and a quiet victory no crowd will see.",
			"When you're ready, the south door climbs back toward the Great Hall.",
		]),
		[
			{"text": "For my friends.", "effects": {"hufflepuff": 1, "ron_trust": 1, "hermione_trust": 1}},
			{"text": "For the castle.", "effects": {"gryffindor": 1}},
			{"text": "Remember every step.", "effects": {"ravenclaw": 1}},
		],
		"How do you leave the vault?"
	)


func _show_epilogue(animate: bool) -> void:
	_epilogue.visible = true
	_epilogue_label.text = "Year One — complete\nThe Stone is secure.\nThe Hall waits above."
	if animate:
		_epilogue_label.modulate.a = 0.0
		create_tween().tween_property(_epilogue_label, "modulate:a", 1.0, 0.8)

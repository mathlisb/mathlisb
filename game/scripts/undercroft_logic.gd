extends Node2D
## Undercroft chamber 3 — bottle logic. Lumos reveals labels; pick the safe brew (or use bridge tonic).

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective
@onready var _ambient: CanvasModulate = $CanvasModulate
@onready var _safe: Area2D = $Interactables/SafeBottle
@onready var _poison_a: Area2D = $Interactables/PoisonA
@onready var _poison_b: Area2D = $Interactables/PoisonB
@onready var _exit: Area2D = $Interactables/NorthExit

var _labels_lit: bool = false
var _advance_after_dialogue: bool = false


func _ready() -> void:
	_build_floor()
	_camera.zoom = Vector2(2.3, 2.3)
	create_tween().tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for area in [_safe, _poison_a, _poison_b, _exit]:
		area.body_entered.connect(_prompt.bind(area, true))
		area.body_exited.connect(_prompt.bind(area, false))
	SpellBook.spell_cast.connect(_on_spell_cast)
	GameState.dialogue_ended.connect(_on_dialogue_ended)
	_ambient.color = Color(0.82, 0.84, 0.7, 1.0) if GameState.lumos_active else Color(0.36, 0.4, 0.46, 1.0)
	_hint.text = "WASD · 1 Lumos to read labels · E bottle · I tonic"
	_refresh_objective()
	_set_bottle_prompts_hidden()
	await get_tree().create_timer(0.25).timeout
	if GameState.undercroft_logic_done:
		GameState.start_dialogue("Narrator", PackedStringArray(["The safe path is already chosen. North to the Mirror."]))
	else:
		var lines := PackedStringArray([
			"Three bottles. One forward, two regret. Lumos (1) to read the labels — Year One eyes, not guesswork.",
		])
		if GameState.undercroft_tonic_ready and Inventory.has_item(&"bridge_tonic"):
			lines.append("Or drink your Herbology bridge tonic (E on the safe stand after Lumos, or use the tonic vial from the satchel at the exit).")
		GameState.start_dialogue("Narrator", lines)


func _set_bottle_prompts_hidden() -> void:
	for area in [_safe, _poison_a, _poison_b]:
		var p: Label = area.get_node_or_null("Prompt")
		if p and not _labels_lit:
			p.text = "E — Bottle"


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
	if GameState.undercroft_logic_done:
		_objective.text = "Next: E north → Mirror of Erised"
	elif not _labels_lit:
		_objective.text = "Next: Lumos (1) near the bottles to read labels"
	else:
		_objective.text = "Next: drink the nettle-safe brew (middle) or use bridge tonic"


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if _in(_exit):
		_try_exit()
	elif _in(_safe):
		_pick_safe()
	elif _in(_poison_a) or _in(_poison_b):
		_pick_poison()


func _in(area: Area2D) -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _on_spell_cast(spell_id: StringName, origin: Vector2, _facing: Vector2) -> void:
	if spell_id == &"lumos":
		_ambient.color = Color(0.82, 0.84, 0.7, 1.0) if GameState.lumos_active else Color(0.36, 0.4, 0.46, 1.0)
	if spell_id != &"lumos" or _labels_lit or GameState.undercroft_logic_done:
		return
	if origin.distance_to(_safe.global_position) > 160.0:
		return
	_labels_lit = true
	_safe.get_node("Prompt").text = "E — Nettle-safe"
	_poison_a.get_node("Prompt").text = "E — Bane"
	_poison_b.get_node("Prompt").text = "E — Bane"
	_refresh_objective()
	GameState.start_dialogue(
		"Bottle Labels",
		PackedStringArray([
			"Lumos catches ink: left bane, middle nettle-safe forward, right bane.",
			"Drink the middle — or spend your bridge tonic at the north exit.",
		])
	)


func _pick_safe() -> void:
	if GameState.undercroft_logic_done:
		GameState.start_dialogue("Bottle", PackedStringArray(["Already chosen. Go north."]))
		return
	if not _labels_lit:
		GameState.start_dialogue("Bottle", PackedStringArray(["Unmarked in this light. Cast Lumos first."]))
		return
	_complete_logic("The nettle-safe brew burns clean. The north door unlatches.")


func _pick_poison() -> void:
	if GameState.undercroft_logic_done:
		return
	if not _labels_lit:
		GameState.start_dialogue("Bottle", PackedStringArray(["Unmarked. Lumos first — guessing here is how first-years vanish."]))
		return
	GameState.start_dialogue(
		"Bottle",
		PackedStringArray([
			"Bitter, wrong. You spit it out — floor spins, then steadies. Not this one.",
		])
	)


func _try_exit() -> void:
	if GameState.undercroft_logic_done:
		_advance_after_dialogue = true
		GameState.start_dialogue("Logic Gate", PackedStringArray(["North: the Mirror waits."]))
		return
	if GameState.undercroft_tonic_ready and Inventory.has_item(&"bridge_tonic"):
		Inventory.consume_item(&"bridge_tonic", 1)
		_complete_logic("You drink the Herbology bridge tonic. The gate accepts the substitute — undercroft prep well spent.")
		return
	if not _labels_lit:
		GameState.start_dialogue("Logic Gate", PackedStringArray(["Solve the bottles (Lumos + safe brew) or bring a bridge tonic."]))
		return
	GameState.start_dialogue("Logic Gate", PackedStringArray(["Drink the nettle-safe bottle first — or use your tonic here."]))


func _complete_logic(line: String) -> void:
	GameState.undercroft_logic_done = true
	GameState.flags_changed.emit()
	_refresh_objective()
	_advance_after_dialogue = true
	GameState.start_dialogue(
		"Logic Gate",
		PackedStringArray([line, "Beyond: a tall glass and a wish that isn't a weapon."]),
		[{"text": "Approach the Mirror.", "effects": {"ravenclaw": 1}}],
		"Continue?"
	)


func _on_dialogue_ended() -> void:
	if not _advance_after_dialogue:
		return
	_advance_after_dialogue = false
	if GameState.undercroft_logic_done:
		GameState.go_to_scene("res://scenes/undercroft_mirror.tscn")

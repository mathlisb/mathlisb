extends Node2D
## Undercroft chamber 2 — shove chess pieces with Flipendo (or Leviosa lift) to clear the path.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _hint: Label = $HUDHints/Hint
@onready var _objective: Label = $HUDHints/Objective
@onready var _exit: Area2D = $Interactables/NorthExit
@onready var _ambient: CanvasModulate = $CanvasModulate

var _advance_after_dialogue: bool = false
var _pieces_cleared: int = 0


func _ready() -> void:
	_build_floor()
	_camera.zoom = Vector2(2.3, 2.3)
	create_tween().tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_exit.body_entered.connect(_prompt.bind(_exit, true))
	_exit.body_exited.connect(_prompt.bind(_exit, false))
	SpellBook.spell_cast.connect(_on_spell_cast)
	GameState.dialogue_ended.connect(_on_dialogue_ended)
	_ambient.color = Color(0.8, 0.82, 0.7, 1.0) if GameState.lumos_active else Color(0.4, 0.42, 0.5, 1.0)
	_hint.text = "WASD · 3 Flipendo shove pieces · E north when clear"
	_refresh_objective()
	for child in $Interactables.get_children():
		if child.is_in_group("spellable"):
			child.set_meta("spawn", child.position)
	await get_tree().create_timer(0.25).timeout
	if GameState.chess_chamber_done:
		GameState.start_dialogue("Narrator", PackedStringArray(["Stone pieces already aside. North exit is open."]))
	else:
		GameState.start_dialogue(
			"Narrator",
			PackedStringArray([
				"Giant chess — or a stub of it. Two white pieces block the north aisle.",
				"Flipendo (3) to shove them clear. Leviosa helps if you need lift. No blood on this board tonight.",
			])
		)


func _prompt(body: Node2D, area: Area2D, show: bool) -> void:
	if body.is_in_group("player"):
		var p: Label = area.get_node_or_null("Prompt")
		if p:
			p.visible = show and not GameState.blocks_player()


func _build_floor() -> void:
	var root: Node2D = $Floor/Tiles
	var a: Texture2D = preload("res://assets/pixel/tile_stone.png")
	var b: Texture2D = preload("res://assets/pixel/tile_path.png")
	for y in range(-4, 5):
		for x in range(-6, 7):
			var spr := Sprite2D.new()
			spr.texture = a if (x + y) % 2 == 0 else b
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = Vector2(x * 64 + 16, y * 64 + 16)
			spr.scale = Vector2(2, 2)
			spr.z_index = -2
			root.add_child(spr)


func _refresh_objective() -> void:
	if GameState.chess_chamber_done:
		_objective.text = "Next: E north → logic bottles"
	else:
		_objective.text = "Next: Flipendo the blocking pieces (%d/2)" % mini(_pieces_cleared, 2)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact") or GameState.blocks_player():
		return
	if not _in(_exit):
		return
	if not GameState.chess_chamber_done and _pieces_cleared < 2:
		GameState.start_dialogue("Blocked Aisle", PackedStringArray(["Stone pieces still block the way. Flipendo them aside."]))
		return
	if not GameState.chess_chamber_done:
		GameState.chess_chamber_done = true
		GameState.flags_changed.emit()
	_advance_after_dialogue = true
	GameState.start_dialogue(
		"Chess Chamber",
		PackedStringArray([
			"The aisle opens. Ahead: a table of bottles — a logic gate before the Mirror.",
		]),
		[{"text": "Continue.", "effects": {"ravenclaw": 1}}],
		"Enter the bottle chamber?"
	)


func _in(area: Area2D) -> bool:
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false


func _on_spell_cast(spell_id: StringName, origin: Vector2, _facing: Vector2) -> void:
	if spell_id == &"lumos":
		_ambient.color = Color(0.8, 0.82, 0.7, 1.0) if GameState.lumos_active else Color(0.4, 0.42, 0.5, 1.0)
	if spell_id not in [&"flipendo", &"leviosa"]:
		return
	await get_tree().create_timer(0.25).timeout
	_pieces_cleared = 0
	for child in $Interactables.get_children():
		if not child.is_in_group("spellable"):
			continue
		var spawn: Vector2 = child.get_meta("spawn", child.position)
		if child.position.distance_to(spawn) > 28.0:
			_pieces_cleared += 1
	if _pieces_cleared >= 2 and not GameState.chess_chamber_done:
		GameState.chess_chamber_done = true
		GameState.flags_changed.emit()
		_refresh_objective()
		GameState.start_dialogue(
			"Chess Chamber",
			PackedStringArray(["Both pieces clear the aisle. North exit is open — E when ready."])
		)
	else:
		_refresh_objective()


func _on_dialogue_ended() -> void:
	if not _advance_after_dialogue:
		return
	_advance_after_dialogue = false
	GameState.go_to_scene("res://scenes/undercroft_logic.tscn")

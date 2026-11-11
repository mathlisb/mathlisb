extends Node2D
## Playable Diagon Alley vertical slice: walk, talk, inventory, starter spells.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _ambient: CanvasModulate = $CanvasModulate
@onready var _shopkeep: Area2D = $Interactables/Shopkeep
@onready var _prompt: Label = $Interactables/Shopkeep/Prompt
@onready var _hint: Label = $HUDHints/Hint


func _ready() -> void:
	_camera.zoom = Vector2(2.35, 2.35)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.75).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_ambient.color = Color(0.62, 0.7, 0.88, 1.0)
	_prompt.visible = false
	_shopkeep.body_entered.connect(_on_shopkeep_entered)
	_shopkeep.body_exited.connect(_on_shopkeep_exited)
	SpellBook.spell_cast.connect(_on_spell_cast)
	_hint.text = "WASD move · E talk · I satchel · 1–3 spells · J cast"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not GameState.blocks_player():
		for body in _shopkeep.get_overlapping_bodies():
			if body.is_in_group("player"):
				_start_shop_dialogue()
				break


func _on_shopkeep_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not GameState.in_dialogue:
		_prompt.visible = true


func _on_shopkeep_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_prompt.visible = false


func _start_shop_dialogue() -> void:
	_prompt.visible = false
	GameState.talked_to_shopkeep = true
	var lines := PackedStringArray([
		"Welcome to Diagon Alley — cobbles still warm from the day's last deliveries.",
		"Ollivanders is just ahead. Before you go, try your wand: Lumos for light, Leviosa for that crate, Flipendo for a shove.",
		"Press I for your satchel. Knuts and your letter are already packed.",
	])
	if GameState.crate_puzzle_done:
		lines.append("Ah — floating crates already? You'll fit right in at Hogwarts.")
	GameState.start_dialogue("Shopkeep", lines)


func _on_spell_cast(spell_id: StringName, _origin: Vector2, _facing: Vector2) -> void:
	if spell_id != &"lumos":
		return
	await get_tree().process_frame
	var target := Color(1.0, 0.95, 0.82, 1.0) if GameState.lumos_active else Color(0.62, 0.7, 0.88, 1.0)
	var tween := create_tween()
	tween.tween_property(_ambient, "color", target, 0.35)

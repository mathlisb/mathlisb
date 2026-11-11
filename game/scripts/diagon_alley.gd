extends Node2D
## Pixel-art Diagon Alley vertical slice.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _ambient: CanvasModulate = $CanvasModulate
@onready var _shopkeep: Area2D = $Interactables/Shopkeep
@onready var _hint: Label = $HUDHints/Hint


func _ready() -> void:
	GameState.visited_diagon = true
	_build_cobbles()
	_camera.zoom = Vector2(2.4, 2.4)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_ambient.color = Color(0.58, 0.66, 0.86, 1.0)
	_shopkeep.body_entered.connect(_on_shopkeep_entered)
	_shopkeep.body_exited.connect(_on_shopkeep_exited)
	SpellBook.spell_cast.connect(_on_spell_cast)
	_hint.text = "WASD · E talk · I · 1–3/J · Next: King's Cross (north)"


func _build_cobbles() -> void:
	var root: Node2D = $Floor/Cobbles
	var tex_a: Texture2D = preload("res://assets/pixel/tile_cobble.png")
	var tex_b: Texture2D = preload("res://assets/pixel/tile_cobble_b.png")
	var scale := Vector2(2, 2)
	var i := 0
	for y in range(-5, 6):
		for x in range(-8, 9):
			var spr := Sprite2D.new()
			spr.texture = tex_a if (x + y + i) % 2 == 0 else tex_b
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = Vector2(x * 32 * scale.x + 16, y * 32 * scale.y + 16)
			spr.scale = scale
			spr.z_index = -2
			root.add_child(spr)
			i += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not GameState.blocks_player():
		for body in _shopkeep.get_overlapping_bodies():
			if body.is_in_group("player"):
				_start_shop_dialogue()
				break


func _on_shopkeep_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not GameState.in_dialogue:
		if _shopkeep.has_method("set_prompt_visible"):
			_shopkeep.set_prompt_visible(true)


func _on_shopkeep_exited(body: Node2D) -> void:
	if body.is_in_group("player") and _shopkeep.has_method("set_prompt_visible"):
		_shopkeep.set_prompt_visible(false)


func _start_shop_dialogue() -> void:
	if _shopkeep.has_method("set_prompt_visible"):
		_shopkeep.set_prompt_visible(false)
	GameState.talked_to_shopkeep = true
	var lines := PackedStringArray([
		"Diagon Alley — last stop before the station. Gear first, then King's Cross.",
		"Year One starters on your bar: Lumos, Leviosa, Flipendo (1–3). Lift and shove the crates — every charm earns its keep.",
		"North door → Platform 9¾. At Hogwarts you'll learn Alohomora, Incendio, then Defense.",
	])
	if GameState.crate_puzzle_done:
		lines.append("Floating crates already? Keep that wand-hand steady on the Express.")
	var choices: Array = [
		{"text": "I'll practice 1–3, then the station.", "effects": {"ravenclaw": 1}},
		{"text": "Point me at Platform 9¾.", "effects": {"gryffindor": 1}},
		{"text": "Any kindness for a first-timer?", "effects": {"hufflepuff": 1, "hermione_trust": 1}},
	]
	GameState.start_dialogue("Shopkeep", lines, choices, "How do you answer the shopkeep?")


func _on_spell_cast(spell_id: StringName, _origin: Vector2, _facing: Vector2) -> void:
	if spell_id != &"lumos":
		return
	await get_tree().process_frame
	var target := Color(1.0, 0.96, 0.84, 1.0) if GameState.lumos_active else Color(0.58, 0.66, 0.86, 1.0)
	var tween := create_tween()
	tween.tween_property(_ambient, "color", target, 0.4)

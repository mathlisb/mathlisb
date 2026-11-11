extends Node2D
## Placeholder outdoor Diagon Alley room for the vertical slice.

@onready var _camera: Camera2D = $Player/Camera2D
@onready var _ambient: CanvasModulate = $CanvasModulate
@onready var _shopkeep: Area2D = $Interactables/Shopkeep


func _ready() -> void:
	# Camera ease on room enter — intentional motion #2
	_camera.zoom = Vector2(2.4, 2.4)
	var tween := create_tween()
	tween.tween_property(_camera, "zoom", Vector2(2.0, 2.0), 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_ambient.color = Color(0.72, 0.78, 0.92, 1.0)
	_shopkeep.body_entered.connect(_on_shopkeep_entered)
	SpellBook.spell_cast.connect(_on_spell_cast)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not GameState.in_dialogue:
		for body in _shopkeep.get_overlapping_bodies():
			if body.is_in_group("player"):
				_start_shop_dialogue()
				break


func _on_shopkeep_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not GameState.in_dialogue:
		pass  # Prompt handled by HUD / interact


func _start_shop_dialogue() -> void:
	GameState.start_dialogue(
		"Shopkeep",
		PackedStringArray([
			"Welcome to Diagon Alley, young witch or wizard.",
			"Ollivanders is just ahead — but first, try your wand. Lumos lights the way.",
			"Press 1–3 to choose a spell, J to cast. E to talk.",
		])
	)


func _on_spell_cast(spell_id: StringName, _origin: Vector2, _facing: Vector2) -> void:
	if spell_id == &"lumos":
		GameState.lumos_active = not GameState.lumos_active
		var target := Color(1.0, 0.95, 0.82, 1.0) if GameState.lumos_active else Color(0.72, 0.78, 0.92, 1.0)
		var tween := create_tween()
		tween.tween_property(_ambient, "color", target, 0.35)

extends CharacterBody2D
## Top-down controller for the Diagon Alley vertical slice.

const SPEED := 128.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _cast_point: Marker2D = $CastPoint
@onready var _anim: AnimationPlayer = $AnimationPlayer
@onready var _glow: Polygon2D = $WandGlow

var facing: Vector2 = Vector2.DOWN


func _ready() -> void:
	_glow.modulate.a = 0.0
	var breathe := create_tween().set_loops()
	breathe.tween_property(_sprite, "scale", Vector2(1.28, 1.22), 0.9).set_trans(Tween.TRANS_SINE)
	breathe.tween_property(_sprite, "scale", Vector2(1.25, 1.25), 0.9).set_trans(Tween.TRANS_SINE)
	SpellBook.spell_cast.connect(_on_spell_cast_local)


func _physics_process(_delta: float) -> void:
	if GameState.blocks_player():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vec.length() > 0.1:
		facing = input_vec.normalized()
		_cast_point.position = facing * 18.0
		_sprite.flip_h = facing.x < 0.0
	velocity = input_vec * SPEED
	move_and_slide()

	if Input.is_action_just_pressed("spell_lumos"):
		SpellBook.select_spell(&"lumos")
	elif Input.is_action_just_pressed("spell_leviosa"):
		SpellBook.select_spell(&"leviosa")
	elif Input.is_action_just_pressed("spell_flipendo"):
		SpellBook.select_spell(&"flipendo")

	if Input.is_action_just_pressed("cast_spell"):
		_try_cast()


func _try_cast() -> void:
	if SpellBook.cast(global_position, facing):
		if _anim and _anim.has_animation("cast"):
			_anim.play("cast")
		var fx := preload("res://scenes/spell_fx.tscn").instantiate()
		get_parent().add_child(fx)
		fx.global_position = _cast_point.global_position
		fx.setup(SpellBook.selected, SpellBook.spell_color())


func _on_spell_cast_local(spell_id: StringName, _origin: Vector2, _facing: Vector2) -> void:
	if spell_id != &"lumos":
		return
	GameState.lumos_active = not GameState.lumos_active
	var target_a := 0.55 if GameState.lumos_active else 0.0
	var tween := create_tween()
	tween.tween_property(_glow, "modulate:a", target_a, 0.3)

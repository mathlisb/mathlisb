extends CharacterBody2D
## Top-down stub controller for the Diagon Alley slice.

const SPEED := 120.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _cast_point: Marker2D = $CastPoint
@onready var _anim: AnimationPlayer = $AnimationPlayer

var facing: Vector2 = Vector2.DOWN


func _physics_process(_delta: float) -> void:
	if GameState.in_dialogue:
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

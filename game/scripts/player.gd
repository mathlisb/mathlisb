extends CharacterBody2D
## Pixel-art player for the Diagon Alley vertical slice.

const SPEED := 128.0

@onready var _anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _cast_point: Marker2D = $CastPoint
@onready var _glow: Polygon2D = $WandGlow
@onready var _cast_flash: Polygon2D = $CastFlash

var facing: Vector2 = Vector2.DOWN
var _facing_name: String = "down"


func _ready() -> void:
	_setup_frames()
	_glow.modulate.a = 0.0
	_cast_flash.modulate.a = 0.0
	_anim_sprite.play("idle_down")
	# Idle breathe on the whole sprite — intentional motion
	var breathe := create_tween().set_loops()
	breathe.tween_property(_anim_sprite, "position:y", -1.0, 0.85).set_trans(Tween.TRANS_SINE)
	breathe.tween_property(_anim_sprite, "position:y", 0.0, 0.85).set_trans(Tween.TRANS_SINE)
	SpellBook.spell_cast.connect(_on_spell_cast_local)


func _setup_frames() -> void:
	var sheet: Texture2D = preload("res://assets/pixel/player_sheet.png")
	var frames := SpriteFrames.new()
	var defs := {
		"idle_down": [0, 7],
		"walk_down": [1, 0, 2, 0],
		"idle_up": [3],
		"walk_up": [3],
		"idle_side": [4],
		"walk_side": [4, 5],
		"cast": [6, 6, 0],
	}
	for anim_name in defs:
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, anim_name != "cast")
		frames.set_animation_speed(anim_name, 6.0 if anim_name.begins_with("walk") else (10.0 if anim_name == "cast" else 2.0))
		for idx in defs[anim_name]:
			var atlas := AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(idx * 32, 0, 32, 32)
			frames.add_frame(anim_name, atlas)
	_anim_sprite.sprite_frames = frames
	_anim_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _physics_process(_delta: float) -> void:
	if GameState.blocks_player():
		velocity = Vector2.ZERO
		_play_idle()
		move_and_slide()
		return

	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vec.length() > 0.1:
		facing = input_vec.normalized()
		_cast_point.position = facing * 18.0
		_update_facing_name(facing)
		_anim_sprite.flip_h = _facing_name == "side" and facing.x < 0.0
		_play_walk()
	else:
		_play_idle()

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


func _update_facing_name(dir: Vector2) -> void:
	if absf(dir.y) > absf(dir.x):
		_facing_name = "up" if dir.y < 0.0 else "down"
	else:
		_facing_name = "side"


func _play_idle() -> void:
	if _anim_sprite.animation == "cast" and _anim_sprite.is_playing():
		return
	var anim := "idle_down"
	if _facing_name == "up":
		anim = "idle_up"
	elif _facing_name == "side":
		anim = "idle_side"
	if _anim_sprite.animation != anim:
		_anim_sprite.play(anim)


func _play_walk() -> void:
	if _anim_sprite.animation == "cast" and _anim_sprite.is_playing():
		return
	var anim := "walk_down"
	if _facing_name == "up":
		anim = "walk_up"
	elif _facing_name == "side":
		anim = "walk_side"
	if _anim_sprite.animation != anim:
		_anim_sprite.play(anim)


func _try_cast() -> void:
	if SpellBook.cast(global_position, facing):
		_anim_sprite.play("cast")
		# Cast flash — intentional motion
		_cast_flash.modulate = Color(SpellBook.spell_color().r, SpellBook.spell_color().g, SpellBook.spell_color().b, 0.85)
		var tween := create_tween()
		tween.tween_property(_cast_flash, "modulate:a", 0.0, 0.35)
		var fx := preload("res://scenes/spell_fx.tscn").instantiate()
		get_parent().add_child(fx)
		fx.global_position = _cast_point.global_position
		fx.setup(SpellBook.selected, SpellBook.spell_color())


func _on_spell_cast_local(spell_id: StringName, _origin: Vector2, _facing: Vector2) -> void:
	if spell_id != &"lumos":
		return
	GameState.lumos_active = not GameState.lumos_active
	var target_a := 0.6 if GameState.lumos_active else 0.0
	var tween := create_tween()
	tween.tween_property(_glow, "modulate:a", target_a, 0.35)
	if GameState.lumos_active:
		# Soft light pulse
		tween.tween_property(_glow, "scale", Vector2(1.15, 1.15), 0.25)
		tween.tween_property(_glow, "scale", Vector2.ONE, 0.35)

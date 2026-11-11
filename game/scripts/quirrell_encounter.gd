extends Area2D
## Year One climax stub: Quirrell lunges; Protego blocks; Immobulus freezes; Flipendo/Incendio damage.
## No Patronum — see docs/year-one-spells.md.

signal defeated

@onready var _sprite: Sprite2D = $Sprite
@onready var _hp_label: Label = $HpLabel
@onready var _status: Label = $StatusLabel
@onready var _flash: Polygon2D = $HitFlash

var hp: int = 4
var _frozen: float = 0.0
var _attack_cd: float = 1.4
var _base_pos: Vector2
var _alive: bool = true
var _combat_active: bool = false


func _ready() -> void:
	_base_pos = position
	_flash.modulate.a = 0.0
	_refresh()
	SpellBook.spell_cast.connect(_on_spell_cast)
	body_entered.connect(_on_body_entered)
	monitoring = true
	collision_layer = 4
	collision_mask = 2
	if GameState.quirrell_defeated:
		_alive = false
		_combat_active = false
		_sprite.modulate.a = 0.35
		_status.text = "Fallen"
		_hp_label.text = "Secure"


func begin_combat() -> void:
	if GameState.quirrell_defeated:
		return
	_combat_active = true
	_alive = true
	hp = 4
	_frozen = 0.0
	_attack_cd = 1.0
	_sprite.modulate = Color.WHITE
	_refresh()
	_status.text = "Attack!"


func _physics_process(delta: float) -> void:
	if not _alive or not _combat_active or GameState.blocks_player():
		return
	if _frozen > 0.0:
		_frozen = maxf(0.0, _frozen - delta)
		_status.text = "Immobulus!" if _frozen > 0.0 else ""
		return
	_attack_cd -= delta
	if _attack_cd > 0.0:
		return
	_attack_cd = 1.5
	_lunge()


func _lunge() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var dir := (player.global_position - global_position).normalized()
	var tween := create_tween()
	tween.tween_property(self, "position", position + dir * 32.0, 0.14).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(_try_hit_player.bind(player))
	tween.tween_property(self, "position", _base_pos, 0.28)


func _try_hit_player(player: Node2D) -> void:
	if not _alive or not _combat_active:
		return
	if global_position.distance_to(player.global_position) > 52.0:
		return
	if SpellBook.protego_active:
		_status.text = "Protego!"
		_flash.color = Color(0.5, 0.85, 1.0, 1.0)
		_flash.modulate.a = 0.85
		create_tween().tween_property(_flash, "modulate:a", 0.0, 0.3)
		return
	_status.text = "Hit!"
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate", Color(1.25, 0.55, 0.55, 1.0), 0.08)
	tween.tween_property(_sprite, "modulate", Color.WHITE, 0.22)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and _alive and _combat_active and _frozen <= 0.0:
		_try_hit_player(body)


func _on_spell_cast(spell_id: StringName, origin: Vector2, facing: Vector2) -> void:
	if not _alive or not _combat_active:
		return
	if global_position.distance_to(origin) > 120.0:
		return
	var to_me := (global_position - origin).normalized()
	if facing.length() > 0.1 and to_me.dot(facing) < 0.08:
		return
	match spell_id:
		&"immobulus":
			_frozen = 2.0
			_status.text = "Immobulus!"
			_sprite.modulate = Color(0.7, 0.9, 1.0, 1.0)
			create_tween().tween_property(_sprite, "modulate", Color.WHITE, 2.0)
		&"flipendo":
			_take_damage(1)
		&"incendio":
			_take_damage(2)
		&"protego":
			_status.text = "Shield up!"
		_:
			pass


func _take_damage(amount: int) -> void:
	hp = maxi(0, hp - amount)
	_refresh()
	_flash.color = Color(1.0, 0.35, 0.25, 1.0)
	_flash.modulate.a = 0.9
	var tween := create_tween()
	tween.tween_property(_flash, "modulate:a", 0.0, 0.25)
	tween.parallel().tween_property(_sprite, "scale", Vector2(2.0, 1.6), 0.08)
	tween.tween_property(_sprite, "scale", Vector2(1.8, 1.8), 0.12)
	if hp <= 0:
		_alive = false
		_combat_active = false
		_status.text = "Down!"
		defeated.emit()
		tween.tween_property(_sprite, "modulate:a", 0.35, 0.45)


func _refresh() -> void:
	_hp_label.text = "HP %d/4" % hp

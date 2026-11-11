extends StaticBody2D
## Crate / barrel that reacts to Leviosa (lift) and Flipendo (shove).

@export var prop_name: String = "Crate"
@export var can_lift: bool = true
@export var can_shove: bool = true

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _label: Label = $Feedback

var _base_pos: Vector2
var _lifted: bool = false
var _busy: bool = false


func _ready() -> void:
	_base_pos = position
	_label.visible = false
	add_to_group("spellable")
	SpellBook.spell_cast.connect(_on_spell_cast)


func _on_spell_cast(spell_id: StringName, origin: Vector2, facing: Vector2) -> void:
	if _busy:
		return
	if global_position.distance_to(origin) > 90.0:
		return
	# Prefer props roughly in facing direction when player is aiming.
	var to_prop := (global_position - origin).normalized()
	if facing.length() > 0.1 and to_prop.dot(facing) < -0.15:
		return

	match spell_id:
		&"leviosa":
			if can_lift:
				_do_leviosa()
		&"flipendo":
			if can_shove:
				_do_flipendo(facing)
		&"lumos":
			_flash("Lumos…")


func _do_leviosa() -> void:
	_busy = true
	_lifted = not _lifted
	var target_y := _base_pos.y - 28.0 if _lifted else _base_pos.y
	_show_feedback("Leviosa!" if _lifted else "Settles")
	var tween := create_tween()
	tween.tween_property(self, "position:y", target_y, 0.4).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_sprite, "modulate", Color(0.85, 1.0, 0.92, 1.0) if _lifted else Color.WHITE, 0.3)
	tween.tween_callback(func() -> void: _busy = false)
	if _lifted:
		GameState.crate_puzzle_done = true


func _do_flipendo(facing: Vector2) -> void:
	_busy = true
	_show_feedback("Flipendo!")
	var dir := facing if facing.length() > 0.1 else Vector2.RIGHT
	var bump := dir.normalized() * 36.0
	var tween := create_tween()
	tween.tween_property(self, "position", position + bump, 0.18).set_trans(Tween.TRANS_BACK)
	tween.tween_property(_sprite, "rotation_degrees", 12.0 if dir.x >= 0.0 else -12.0, 0.12)
	tween.tween_property(_sprite, "rotation_degrees", 0.0, 0.18)
	tween.tween_callback(func() -> void:
		_base_pos = position
		_busy = false
	)


func _flash(text: String) -> void:
	_show_feedback(text)
	var tween := create_tween()
	tween.tween_property(_sprite, "modulate", Color(1.1, 1.05, 0.85, 1.0), 0.1)
	tween.tween_property(_sprite, "modulate", Color.WHITE, 0.25)


func _show_feedback(text: String) -> void:
	_label.text = text
	_label.visible = true
	_label.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(_label, "position:y", _label.position.y - 8.0, 0.35)
	tween.parallel().tween_property(_label, "modulate:a", 0.0, 0.45)
	tween.tween_callback(func() -> void:
		_label.visible = false
		_label.position.y += 8.0
	)

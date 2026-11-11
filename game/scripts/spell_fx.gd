extends Node2D

@onready var _glow: Polygon2D = $Glow
@onready var _label: Label = $Label

var _pending_id: StringName = &""
var _pending_color: Color = Color.WHITE
var _configured: bool = false


func setup(spell_id: StringName, color: Color) -> void:
	_pending_id = spell_id
	_pending_color = color
	if is_node_ready():
		_apply()


func _ready() -> void:
	if _pending_id != &"":
		_apply()


func _apply() -> void:
	if _configured:
		return
	_configured = true
	_glow.color = _pending_color
	_label.text = SpellBook.display_name(_pending_id)
	_label.add_theme_color_override("font_color", _pending_color)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.6, 1.6), 0.35).set_trans(Tween.TRANS_BACK)
	tween.tween_property(_glow, "modulate:a", 0.0, 0.4)
	tween.chain().tween_callback(queue_free)

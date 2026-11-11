extends CanvasLayer

@onready var _label: Label = %SpellLabel
@onready var _icon: TextureRect = %SpellIcon


func _ready() -> void:
	SpellBook.spell_selected.connect(_refresh)
	SpellBook.spell_cast.connect(_on_cast)
	_refresh(SpellBook.selected)


func _refresh(spell_id: StringName) -> void:
	_label.text = "%s  [1–3 select · J cast]" % SpellBook.display_name(spell_id)
	_label.add_theme_color_override("font_color", SpellBook.spell_color(spell_id))
	var path := "res://assets/placeholders/spell_%s.png" % String(spell_id)
	if ResourceLoader.exists(path):
		_icon.texture = load(path)


func _on_cast(spell_id: StringName, _origin: Vector2, _facing: Vector2) -> void:
	_label.text = "✦ %s!" % SpellBook.display_name(spell_id)
	var tween := create_tween()
	tween.tween_property(_label, "scale", Vector2(1.08, 1.08), 0.08)
	tween.tween_property(_label, "scale", Vector2.ONE, 0.18)
	tween.tween_callback(func() -> void: _refresh(spell_id))

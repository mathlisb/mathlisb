extends CanvasLayer

@onready var _label: Label = %SpellLabel
@onready var _icon: TextureRect = %SpellIcon
@onready var _slots: HBoxContainer = %Slots


func _ready() -> void:
	SpellBook.spell_selected.connect(_refresh)
	SpellBook.spell_cast.connect(_on_cast)
	SpellBook.unlocks_changed.connect(_on_unlocks)
	_build_slots()
	_refresh(SpellBook.selected)


func _on_unlocks() -> void:
	_build_slots()
	_refresh(SpellBook.selected)


func _build_slots() -> void:
	for child in _slots.get_children():
		child.queue_free()
	for id in SpellBook.unlocked_ordered():
		var slot := int(SpellBook.ALL_SPELLS[id]["slot"])
		var chip := Label.new()
		chip.text = "%d %s" % [slot, SpellBook.display_name(id)]
		chip.add_theme_font_size_override("font_size", 12)
		chip.add_theme_color_override("font_color", SpellBook.spell_color(id).darkened(0.1))
		chip.add_theme_color_override("font_outline_color", Color(0.059, 0.102, 0.18, 1))
		chip.add_theme_constant_override("outline_size", 2)
		chip.set_meta("spell_id", id)
		_slots.add_child(chip)


func _refresh(spell_id: StringName) -> void:
	_label.text = "%s — J to cast" % SpellBook.display_name(spell_id)
	_label.add_theme_color_override("font_color", SpellBook.spell_color(spell_id))
	var path := "res://assets/pixel/spell_%s.png" % String(spell_id)
	if ResourceLoader.exists(path):
		_icon.texture = load(path)
		_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for chip in _slots.get_children():
		var id: StringName = chip.get_meta("spell_id")
		var selected := id == spell_id
		chip.add_theme_color_override("font_color", SpellBook.spell_color(id) if selected else Color(0.55, 0.62, 0.7, 1))
		chip.add_theme_font_size_override("font_size", 13 if selected else 12)


func _on_cast(spell_id: StringName, _origin: Vector2, _facing: Vector2) -> void:
	_label.text = "✦ %s!" % SpellBook.display_name(spell_id)
	var tween := create_tween()
	tween.tween_property(_label, "scale", Vector2(1.08, 1.08), 0.08)
	tween.tween_property(_label, "scale", Vector2.ONE, 0.18)
	tween.tween_callback(func() -> void: _refresh(spell_id))

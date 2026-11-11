extends CanvasLayer
## Parchment dialogue with optional light RPG choices.

@onready var _panel: PanelContainer = %Panel
@onready var _speaker: Label = %Speaker
@onready var _body: RichTextLabel = %Body
@onready var _hint: Label = %Hint
@onready var _choices: VBoxContainer = %Choices

var _lines: PackedStringArray = []
var _index: int = 0
var _showing_choices: bool = false


func _ready() -> void:
	visible = false
	_choices.visible = false
	GameState.dialogue_started.connect(_on_dialogue_started)
	GameState.dialogue_choices_ready.connect(_on_choices_ready)
	GameState.dialogue_ended.connect(_on_dialogue_ended)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _showing_choices:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_advance()
		get_viewport().set_input_as_handled()


func _on_dialogue_started(lines: PackedStringArray, speaker: String) -> void:
	_lines = lines
	_index = 0
	_showing_choices = false
	_choices.visible = false
	_clear_choices()
	_speaker.text = speaker
	visible = true
	_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_panel, "modulate:a", 1.0, 0.25)
	_show_line()


func _on_choices_ready(prompt: String, choices: Array) -> void:
	_showing_choices = true
	_choices.visible = true
	_body.text = prompt
	_hint.text = "Choose a reply"
	_clear_choices()
	for i in choices.size():
		var choice: Dictionary = choices[i]
		var btn := Button.new()
		btn.text = "%d. %s" % [i + 1, str(choice.get("text", "…"))]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_color_override("font_color", Color("1c1814"))
		btn.add_theme_color_override("font_hover_color", Color("1a3d2e"))
		btn.pressed.connect(_on_choice_pressed.bind(choice))
		_choices.add_child(btn)
		if i == 0:
			btn.grab_focus()


func _on_dialogue_ended() -> void:
	visible = false
	_showing_choices = false
	_choices.visible = false
	_clear_choices()


func _show_line() -> void:
	if _index >= _lines.size():
		if GameState.request_choices_if_any():
			return
		GameState.end_dialogue()
		return
	_body.text = _lines[_index]
	_hint.text = "E / Space — continue"


func _advance() -> void:
	_index += 1
	_show_line()


func _on_choice_pressed(choice: Dictionary) -> void:
	GameState.apply_choice(choice)


func _clear_choices() -> void:
	for child in _choices.get_children():
		child.queue_free()

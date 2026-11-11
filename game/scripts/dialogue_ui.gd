extends CanvasLayer
## Simple parchment dialogue stub.

@onready var _panel: PanelContainer = %Panel
@onready var _speaker: Label = %Speaker
@onready var _body: RichTextLabel = %Body
@onready var _hint: Label = %Hint

var _lines: PackedStringArray = []
var _index: int = 0


func _ready() -> void:
	visible = false
	GameState.dialogue_started.connect(_on_dialogue_started)
	GameState.dialogue_ended.connect(_on_dialogue_ended)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_advance()
		get_viewport().set_input_as_handled()


func _on_dialogue_started(lines: PackedStringArray, speaker: String) -> void:
	_lines = lines
	_index = 0
	_speaker.text = speaker
	visible = true
	_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_panel, "modulate:a", 1.0, 0.25)
	_show_line()


func _on_dialogue_ended() -> void:
	visible = false


func _show_line() -> void:
	if _index >= _lines.size():
		GameState.end_dialogue()
		return
	_body.text = _lines[_index]
	_hint.text = "E / Space — continue"


func _advance() -> void:
	_index += 1
	_show_line()

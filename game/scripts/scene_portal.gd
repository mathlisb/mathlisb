extends Area2D
## Walk into / press E to travel between Year One rooms.

@export var target_scene: String = ""
@export var prompt_text: String = "E — Enter"
@export var require_flag: StringName = &""
@export var auto_enter: bool = false

@onready var _prompt: Label = $Prompt

var _player_inside: bool = false


func _ready() -> void:
	body_entered.connect(_on_entered)
	body_exited.connect(_on_exited)
	_prompt.text = prompt_text
	_prompt.visible = false
	monitoring = true
	collision_layer = 0
	collision_mask = 2  # player


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside or GameState.blocks_player():
		return
	if event.is_action_pressed("interact"):
		_try_travel()
		get_viewport().set_input_as_handled()


func _on_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = true
	_prompt.visible = _can_travel()
	if auto_enter and _can_travel() and not GameState.blocks_player():
		_try_travel()


func _on_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_prompt.visible = false


func _can_travel() -> bool:
	if target_scene.is_empty():
		return false
	if require_flag == &"":
		return true
	return bool(GameState.get(String(require_flag)))


func _try_travel() -> void:
	if not _can_travel():
		_prompt.text = "Not yet…"
		_prompt.visible = true
		return
	GameState.go_to_scene(target_scene)

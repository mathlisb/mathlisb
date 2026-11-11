extends CanvasLayer
## Parchment inventory panel stub (I to toggle).

@onready var _root: Control = $Root
@onready var _panel: PanelContainer = %Panel
@onready var _list: VBoxContainer = %ItemList
@onready var _detail: RichTextLabel = %Detail


func _ready() -> void:
	visible = false
	Inventory.opened.connect(_show)
	Inventory.closed.connect(_hide)
	Inventory.changed.connect(_rebuild)
	_rebuild()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		Inventory.toggle()
		get_viewport().set_input_as_handled()
	elif visible and event.is_action_pressed("ui_cancel"):
		Inventory.close()
		get_viewport().set_input_as_handled()


func _show() -> void:
	visible = true
	_rebuild()
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.96, 0.96)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_panel, "modulate:a", 1.0, 0.2)
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK)


func _hide() -> void:
	visible = false


func _rebuild() -> void:
	for child in _list.get_children():
		child.queue_free()
	if Inventory.items.is_empty():
		_detail.text = "Your pockets are empty."
		return
	for i in Inventory.items.size():
		var item: Dictionary = Inventory.items[i]
		var row := Button.new()
		row.text = "%s  ×%d" % [item["name"], item["qty"]]
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.focus_mode = Control.FOCUS_ALL
		row.pressed.connect(_select.bind(item))
		_list.add_child(row)
		if i == 0:
			_select(item)
			row.grab_focus()


func _select(item: Dictionary) -> void:
	_detail.text = "[b]%s[/b]\n%s" % [item["name"], item["description"]]

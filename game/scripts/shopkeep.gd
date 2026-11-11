extends Area2D
## Animated shopkeep with idle breathe frames.

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _prompt: Label = $Prompt


func _ready() -> void:
	_setup_frames()
	_sprite.play("idle")
	_prompt.visible = false


func _setup_frames() -> void:
	var sheet: Texture2D = preload("res://assets/pixel/shopkeep_sheet.png")
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 2.0)
	for idx in [0, 1, 0, 2]:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(idx * 32, 0, 32, 32)
		frames.add_frame("idle", atlas)
	_sprite.sprite_frames = frames
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func set_prompt_visible(vis: bool) -> void:
	_prompt.visible = vis

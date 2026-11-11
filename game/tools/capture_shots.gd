extends SceneTree
## Headless-friendly screenshot helper.
## Usage:
##   godot --path game --script res://tools/capture_shots.gd
## Writes PNGs under user:// then copies via OS if DISPLAY is available.

const OUT_DIR := "user://captures"
const SHOTS := [
	{"scene": "res://scenes/main_menu.tscn", "file": "remaster-menu.png", "wait": 0.4},
	{"scene": "res://scenes/diagon_alley.tscn", "file": "remaster-diagon-alley.png", "wait": 0.8},
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OS.get_user_data_dir().path_join("captures"))
	for shot in SHOTS:
		await _capture(shot["scene"], shot["file"], shot["wait"])
	# Spell stub: load alley, cast Lumos once, capture.
	await _capture_spell()
	quit()


func _capture(scene_path: String, filename: String, wait_s: float) -> void:
	change_scene_to_file(scene_path)
	await process_frame
	await process_frame
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(wait_s * 1000.0):
		await process_frame
	var img := get_root().get_viewport().get_texture().get_image()
	var path := OUT_DIR.path_join(filename)
	var err := img.save_png(path)
	print("capture ", filename, " -> ", ProjectSettings.globalize_path(path), " err=", err)


func _capture_spell() -> void:
	change_scene_to_file("res://scenes/diagon_alley.tscn")
	await process_frame
	await process_frame
	await process_frame
	SpellBook.select_spell(&"lumos")
	var player := get_root().find_child("Player", true, false)
	if player and player.has_method("_try_cast"):
		player._try_cast()
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 350:
		await process_frame
	var img := get_root().get_viewport().get_texture().get_image()
	var path := OUT_DIR.path_join("remaster-spell-stub.png")
	var err := img.save_png(path)
	print("capture remaster-spell-stub.png -> ", ProjectSettings.globalize_path(path), " err=", err)

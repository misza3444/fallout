extends SceneTree
## Actual desktop OpenGL render; this script must not run with --headless.
var output_dir := "res://build/screenshots"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):
			output_dir = arg.trim_prefix("--output=")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var scene := load("res://scenes/main.tscn") as PackedScene
	var game: Node = scene.instantiate()
	root.add_child(game)
	game.set_process(false)
	game.terminal.reduce_motion = true
	await process_frame
	await _frame("01_menu.png")
	game._new_game()
	game.player.set_physics_process(false)
	await _frame("02_player_spawn.png")
	game.player.camera.current = false
	game.menu_camera.current = true
	game.hud_ui.hide()
	game.menu_camera.position = Vector3(-4.0, 5.5, -12.0)
	game.menu_camera.look_at(Vector3(-17.0, 2.0, -28.0))
	await _frame("03_station.png")
	game.menu_camera.position = Vector3(8.0, 2.8, -32.0)
	game.menu_camera.look_at(Vector3(3.3, 0.8, -38.0))
	await _frame("04_wreck.png")
	print("Desktop frames captured: ", output_dir)
	game.queue_free()
	await process_frame
	quit()

func _frame(filename: String) -> void:
	for i in range(4):
		await RenderingServer.frame_post_draw
	var frame := root.get_texture().get_image()
	var result := frame.save_png(output_dir.path_join(filename))
	var preview_result := frame.save_jpg(output_dir.path_join(filename.get_basename() + ".jpg"), 0.9)
	if result != OK or preview_result != OK:
		push_error("Could not save screenshot: " + filename)
		quit(1)

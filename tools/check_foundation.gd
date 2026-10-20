extends SceneTree
## Focused persistence regression check. Existing user files are restored afterwards.

var failed := false

func _initialize() -> void:
	call_deferred("_run")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failed = true
		push_error(message)

func _run() -> void:
	var state: Node = root.get_node("GameState")
	if OS.has_feature("portable") and not OS.has_feature("editor"):
		var expected := OS.get_executable_path().get_base_dir().path_join("userdata")
		_expect(state.storage_root == expected, "Portable storage is not beside executable")
		_expect(DirAccess.dir_exists_absolute(expected), "Portable userdata folder missing")
		print("Portable storage: ", state.storage_root)
	var originals: Dictionary = {}
	for path in [state.save_path, state.settings_path]:
		originals[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null

	var position := Vector3(4.5, 1.2, -18.0)
	_expect(state.save_position(position, 37.0, -12.0) == OK, "Valid save failed")
	var restored: Dictionary = state.read_position()
	_expect(restored.get("position") == position, "Position did not round-trip")
	_expect(restored.get("yaw") == 37.0 and restored.get("pitch") == -12.0, "Camera did not round-trip")
	_expect(state.save_position(Vector3(400, 0, 0), 0.0, 0.0) == ERR_INVALID_DATA, "Out-of-sector position accepted")
	_expect(state.read_position().get("position") == position, "Invalid save overwrote good save")
	_expect(state.save_position(position, NAN, 0.0) == ERR_INVALID_DATA, "Invalid angle accepted")

	var corrupt := ConfigFile.new()
	corrupt.set_value("player", "position", "not a vector")
	corrupt.save(state.save_path)
	_expect(state.read_position().is_empty(), "Corrupt position accepted")
	corrupt.clear()
	corrupt.set_value("player", "position", position)
	corrupt.set_value("player", "yaw", "bad angle")
	corrupt.set_value("player", "pitch", 0.0)
	corrupt.save(state.save_path)
	_expect(state.read_position().is_empty(), "Corrupt angle accepted")
	corrupt.clear()
	corrupt.set_value("other", "unused", true)
	corrupt.save(state.save_path)
	_expect(state.read_position().is_empty(), "Missing player section accepted")

	state.fov = 88.0
	state.sensitivity = 0.17
	_expect(state.store_settings() == OK, "Settings write failed")
	state.fov = 65.0
	state.sensitivity = 0.03
	state.load_settings()
	_expect(is_equal_approx(state.fov, 88.0) and is_equal_approx(state.sensitivity, 0.17), "Settings did not round-trip")

	var scene := load("res://scenes/main.tscn") as PackedScene
	var game: Node = scene.instantiate()
	root.add_child(game)
	_expect(game.terminal.save_btn.disabled, "Save enabled before a session")
	game._new_game()
	game._touch_set("up", true)
	game._touch_set("run", true)
	game._touch_set("jump", true)
	_expect(game.player.touch_axis.y < 0.0 and game.player.touch_running, "Touch test did not start movement")
	game._touch_set("menu", true)
	_expect(game.paused and game.player.touch_axis == Vector2.ZERO, "Pause retained touch movement")
	_expect(not game.player.touch_running and not Input.is_action_pressed("jump"), "Pause retained sprint or jump")
	game._manual_save()
	_expect(game.terminal.save_feedback.text == "STAN WYPRAWY ZAPISANY", "Pause-menu save feedback missing")
	game._start_play()
	_expect(game.player.touch_axis == Vector2.ZERO, "Resume restarted stale movement")
	game.player.velocity = Vector3(2, 4, 1)
	game._new_game()
	_expect(game.player.velocity == Vector3.ZERO, "New game retained velocity")
	game.queue_free()
	await process_frame

	for path in originals:
		if originals[path] == null:
			DirAccess.remove_absolute(path)
		else:
			var file := FileAccess.open(path, FileAccess.WRITE)
			if file != null:
				file.store_buffer(originals[path])
				file.close()
			else:
				_expect(false, "Could not restore original user file")
	print("Foundation persistence checks: ", "FAIL" if failed else "PASS")
	quit(1 if failed else 0)

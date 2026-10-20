extends RefCounted
## Checks bundled application behavior through its normal entry point.
## Invoked only by the explicit --portable-check application argument.

static func run(game: Node) -> int:
	var originals: Dictionary = {}
	for path in [GameState.save_path, GameState.settings_path, GameState.terminal_prefs_path]:
		originals[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
	var checks: Dictionary = {}
	var expected := OS.get_executable_path().get_base_dir().path_join("userdata")
	checks["storage_beside_exe"] = GameState.storage_root == expected
	checks["storage_directory"] = DirAccess.dir_exists_absolute(expected)
	var position := Vector3(4.5, 1.2, -18.0)
	checks["write_position"] = GameState.save_position(position, 37.0, -12.0) == OK
	var restored: Dictionary = GameState.read_position()
	checks["position_round_trip"] = restored.get("position") == position
	checks["camera_round_trip"] = restored.get("yaw") == 37.0 and restored.get("pitch") == -12.0
	checks["reject_bad_save"] = GameState.save_position(Vector3(400, 0, 0), 0.0, 0.0) == ERR_INVALID_DATA
	checks["preserve_good_save"] = GameState.read_position().get("position") == position
	GameState.fov = 88.0
	GameState.sensitivity = 0.17
	checks["write_settings"] = GameState.store_settings() == OK
	GameState.fov = 65.0
	GameState.sensitivity = 0.03
	GameState.load_settings()
	checks["settings_round_trip"] = is_equal_approx(GameState.fov, 88.0) and is_equal_approx(GameState.sensitivity, 0.17)
	checks["terminal_preferences"] = game.terminal._save_prefs() == OK
	game._new_game()
	game._touch_set("up", true)
	game._touch_set("run", true)
	game._touch_set("jump", true)
	game._touch_set("menu", true)
	checks["paused"] = game.paused
	checks["clear_movement"] = game.player.touch_axis == Vector2.ZERO and not game.player.touch_running
	checks["clear_jump"] = not Input.is_action_pressed("jump")
	game._manual_save()
	checks["save_feedback"] = game.terminal.save_feedback.text == "STAN WYPRAWY ZAPISANY"
	for path in originals:
		if originals[path] == null:
			DirAccess.remove_absolute(path)
		else:
			var original_file := FileAccess.open(path, FileAccess.WRITE)
			if original_file == null:
				checks["restore_" + str(path)] = false
			else:
				original_file.store_buffer(originals[path])
				original_file.close()
	var passed := true
	var report := ""
	for key in checks:
		report += str(key) + ": " + ("PASS" if checks[key] else "FAIL") + "\n"
		if not checks[key]:
			passed = false
	report += "Portable checks: " + ("PASS" if passed else "FAIL") + "\n"
	var report_file := FileAccess.open(expected.path_join("portable-check.txt"), FileAccess.WRITE)
	if report_file == null:
		return 1
	report_file.store_string(report)
	report_file.close()
	print(report)
	return 0 if passed else 1

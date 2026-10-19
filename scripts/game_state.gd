extends Node

const SETTINGS_PATH := "user://settings.cfg"
const SAVE_PATH := "user://save.cfg"

var sensitivity: float = 0.11
var fov: float = 76.0
var quality: int = 1
var has_save: bool = false

func _ready() -> void:
	load_settings()
	has_save = not read_position().is_empty()

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		sensitivity = clampf(float(config.get_value("controls", "sensitivity", 0.11)), 0.03, 0.4)
		fov = clampf(float(config.get_value("camera", "fov", 76)), 65, 100)
		quality = clampi(int(config.get_value("graphics", "quality", 1)), 0, 2)

func store_settings() -> Error:
	var config := ConfigFile.new()
	config.set_value("controls", "sensitivity", sensitivity)
	config.set_value("camera", "fov", fov)
	config.set_value("graphics", "quality", quality)
	return config.save(SETTINGS_PATH)

func save_position(pos: Vector3, yaw: float, pitch: float) -> Error:
	if not _valid_position(pos) or not is_finite(yaw) or not is_finite(pitch):
		return ERR_INVALID_DATA
	var config := ConfigFile.new()
	config.set_value("player", "position", pos)
	config.set_value("player", "yaw", yaw)
	config.set_value("player", "pitch", pitch)
	var result := config.save(SAVE_PATH)
	has_save = not read_position().is_empty()
	return result

func read_position() -> Dictionary:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return {}
	var p: Variant = config.get_value("player", "position", null)
	if not p is Vector3:
		return {}
	if not _valid_position(p):
		return {}
	var yaw: Variant = config.get_value("player", "yaw", null)
	var pitch: Variant = config.get_value("player", "pitch", null)
	if not (yaw is float or yaw is int) or not (pitch is float or pitch is int):
		return {}
	if not is_finite(float(yaw)) or not is_finite(float(pitch)):
		return {}
	return {
		"position": p,
		"yaw": float(yaw),
		"pitch": clampf(float(pitch), -84.0, 84.0)
	}

func _valid_position(pos: Vector3) -> bool:
	return pos.is_finite() and pos.length() < 220.0 and pos.y > -10.0 and pos.y < 80.0

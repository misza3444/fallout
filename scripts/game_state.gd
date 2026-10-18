extends Node

const SETTINGS_PATH := "user://settings.cfg"
const SAVE_PATH := "user://save.cfg"

var sensitivity: float = 0.11
var fov: float = 76.0
var quality: int = 1
var has_save: bool = false

func _ready() -> void:
	load_settings()
	has_save = FileAccess.file_exists(SAVE_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		sensitivity = clampf(float(config.get_value("controls", "sensitivity", 0.11)), 0.03, 0.4)
		fov = clampf(float(config.get_value("camera", "fov", 76)), 65, 100)
		quality = clampi(int(config.get_value("graphics", "quality", 1)), 0, 2)

func store_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("controls", "sensitivity", sensitivity)
	config.set_value("camera", "fov", fov)
	config.set_value("graphics", "quality", quality)
	config.save(SETTINGS_PATH)

func save_position(pos: Vector3, yaw: float, pitch: float) -> void:
	var config := ConfigFile.new()
	config.set_value("player", "position", pos)
	config.set_value("player", "yaw", yaw)
	config.set_value("player", "pitch", pitch)
	config.save(SAVE_PATH)
	has_save = true

func read_position() -> Dictionary:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return {}
	var p: Variant = config.get_value("player", "position", Vector3.ZERO)
	if not p is Vector3:
		return {}
	return {
		"position": p,
		"yaw": float(config.get_value("player", "yaw", 0)),
		"pitch": float(config.get_value("player", "pitch", 0))
	}

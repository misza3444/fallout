extends Node3D
## Web-first scene shell: cinematic menu, player loop, saving, responsive HUD.

const WASTELAND = preload("res://scripts/wasteland.gd")
const PLAYER = preload("res://scripts/player.gd")
const TERMINAL = preload("res://scripts/terminal_menu.gd")

var world: Node3D
var player: CharacterBody3D
var menu_camera: Camera3D
var menu_ui: Control
var terminal: Control
var hud_ui: Control
var settings_ui: Control
var about_ui: Control
var resume_button: Button
var toast: Label
var position_text: Label
var touches: Dictionary = {}
var in_game := false
var paused := false
var menu_seconds := 0.0
var toast_seconds := 0.0

func _ready() -> void:
	_define_inputs()
	_build_stage()
	_build_menu()
	_build_hud()
	_update_menu()
	_update_pointer()

func _define_inputs() -> void:
	var bindings := {
		"move_forward": [KEY_W, KEY_UP],
		"move_back": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"sprint": [KEY_SHIFT],
		"crouch": [KEY_CTRL],
		"jump": [KEY_SPACE],
		"interact": [KEY_E]
	}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event := InputEventKey.new()
			event.keycode = key
			InputMap.action_add_event(action, event)

func _build_stage() -> void:
	world = WASTELAND.new()
	world.name = "Wasteland"
	add_child(world)
	player = PLAYER.new()
	player.position = Vector3(1, 1.35, 18)
	add_child(player)
	menu_camera = Camera3D.new()
	menu_camera.name = "MenuCinematicCamera"
	menu_camera.fov = 65
	menu_camera.near = 0.1
	menu_camera.far = 190
	add_child(menu_camera)
	menu_camera.current = true
	_animate_camera(0)

func _process(delta: float) -> void:
	if not in_game:
		menu_seconds += delta
		_animate_camera(menu_seconds)
	if toast_seconds > 0.0:
		toast_seconds -= delta
		if toast_seconds <= 0.0:
			toast.visible = false
	if in_game and not paused:
		var p := player.global_position
		position_text.text = "SEKTOR 07    •    %03d / %03d" % [absf(p.x), absf(p.z)]

func _animate_camera(t: float) -> void:
	menu_camera.position = Vector3(15 + sin(t * 0.18) * 1.7, 9.6 + sin(t * 0.27) * 0.3, 24 + cos(t * 0.14) * 2.0)
	menu_camera.look_at(Vector3(-8, 4.1, -22), Vector3.UP)

func _ui_root(layer: int) -> Control:
	var canvas := CanvasLayer.new()
	canvas.layer = layer
	add_child(canvas)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)
	return root

func _rect(parent: Control, color: Color, left: float, top: float, right: float, bottom: float) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = color
	rect.anchor_left = left
	rect.anchor_top = top
	rect.anchor_right = right
	rect.anchor_bottom = bottom
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect

func _text(parent: Node, value: String, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = align
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _button(parent: Node, label: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(255, 55)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color("#e5e6d0"))
	button.add_theme_color_override("font_hover_color", Color("#e5ffd2"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#132526e6")
	normal.border_width_left = 3
	normal.border_color = Color("#9bad6c")
	normal.content_margin_left = 18
	normal.content_margin_right = 12
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("#36513b")
	hover.border_color = Color("#ddda93")
	button.add_theme_stylebox_override("hover", hover)
	var pressed_style := hover.duplicate() as StyleBoxFlat
	pressed_style.bg_color = Color("#4b6140")
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _build_menu() -> void:
	menu_ui = _ui_root(10)
	terminal = TERMINAL.new()
	terminal.name = "SZ_Terminal"
	terminal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_ui.add_child(terminal)
	terminal.new_game_requested.connect(_new_game)
	terminal.continue_requested.connect(_continue_game)
	terminal.save_requested.connect(_manual_save)
	terminal.exit_requested.connect(_pause_game)


func _manual_save() -> void:
	if in_game:
		GameState.save_position(player.position, player.rotation_degrees.y, player.pitch)
		_notify("STAN WYPRAWY ZAPISANY  /  REJESTR ZABEZPIECZONY")
		terminal.refresh_save()


func _update_menu() -> void:
	terminal.session_in_progress = in_game
	terminal.refresh_save()

func _start_play() -> void:
	in_game = true
	paused = false
	menu_ui.hide()
	hud_ui.show()
	menu_camera.current = false
	player.set_active(true)
	_update_pointer()
	_notify("SEKTOR 07  //  SYGNAŁ ODNALEZIONY")

func _new_game() -> void:
	player.position = Vector3(1, 1.35, 18)
	player.rotation_degrees.y = 0
	player.pitch = 0
	player.head.rotation_degrees.x = 0
	_start_play()

func _continue_game() -> void:
	if in_game:
		_start_play()
		return
	var saved := GameState.read_position()
	if not saved.is_empty():
		player.restore(saved)
	_start_play()

func _pause_game() -> void:
	paused = true
	player.set_active(false)
	player.camera.current = true
	hud_ui.hide()
	menu_ui.show()
	terminal.show_home()
	_update_menu()
	_update_pointer()

func _update_pointer() -> void:
	if in_game and not paused and not DisplayServer.is_touchscreen_available():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if menu_ui.visible and terminal.current_screen != "home":
			terminal.show_home()
		elif in_game:
			if paused:
				_start_play()
			else:
				_pause_game()
		get_viewport().set_input_as_handled()
	elif in_game and not paused and event.is_action_pressed("interact"):
		_interact()
		get_viewport().set_input_as_handled()
	elif in_game and not paused and event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		_update_pointer()

func _interact() -> void:
	var p := player.position
	if p.distance_to(Vector3(-13.8, 0, -22.4)) < 6.5:
		_notify("POMPA #02   •   ZBIORNIK PUSTY   •   PROMIENIOWANIE: NISKIE")
	elif p.distance_to(Vector3(19, 0, -17)) < 21.0:
		_notify("PUNKT KONTROLNY 07   •   BRAK SYGNAŁU RADIOWEGO")
	else:
		_notify("SKAN ZAKOŃCZONY   •   BRAK OBIEKTU W ZASIĘGU")

func _notify(message: String) -> void:
	toast.text = message
	toast.visible = true
	toast_seconds = 4.1

func _build_hud() -> void:
	hud_ui = _ui_root(5)
	hud_ui.hide()
	_rect(hud_ui, Color("#10211bc8"), 0, 0, 1.0, 0.086)
	_rect(hud_ui, Color("#a0b96b"), 0, 0.085, 1, 0.087)
	var title := _text(hud_ui, "SZ // PUSTKOWIE", 17, Color("#d3db9c"))
	title.position = Vector2(22, 14)
	position_text = _text(hud_ui, "SEKTOR 07  •  000 / 000", 13, Color("#c0c6b0"))
	position_text.position = Vector2(24, 39)
	var cross := _text(hud_ui, "·", 34, Color("#e2e8bb"), HORIZONTAL_ALIGNMENT_CENTER)
	cross.anchor_left = 0.5
	cross.anchor_top = 0.5
	cross.anchor_right = 0.5
	cross.anchor_bottom = 0.5
	cross.offset_left = -14
	cross.offset_top = -28
	cross.offset_right = 14
	cross.offset_bottom = 14
	var hints := _text(hud_ui, "WASD  RUCH   •   MYSZ  ROZEJRZYJ SIĘ   •   SHIFT  BIEG   •   E  SKAN   •   ESC  MENU", 13, Color("#d1d3aa"))
	hints.anchor_top = 1
	hints.anchor_bottom = 1
	hints.offset_top = -46
	hints.offset_bottom = -22
	hints.offset_left = 20
	toast = _text(hud_ui, "", 14, Color("#e7e8b7"), HORIZONTAL_ALIGNMENT_CENTER)
	toast.anchor_left = 0.16
	toast.anchor_right = 0.84
	toast.anchor_top = 0.12
	toast.offset_top = 3
	toast.visible = false
	if DisplayServer.is_touchscreen_available():
		hints.hide()
		_build_touch_controls()

func _touch_button(label: String, pos: Vector2, size: Vector2, key: String) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.anchor_top = 1
	btn.anchor_bottom = 1
	btn.offset_left = pos.x
	btn.offset_right = pos.x + size.x
	btn.offset_top = pos.y
	btn.offset_bottom = pos.y + size.y
	btn.add_theme_font_size_override("font_size", 19)
	var st := StyleBoxFlat.new()
	st.bg_color = Color("#18332cc9")
	st.border_color = Color("#aec780")
	st.set_border_width_all(1)
	st.set_corner_radius_all(9)
	btn.add_theme_stylebox_override("normal", st)
	btn.add_theme_stylebox_override("pressed", st)
	hud_ui.add_child(btn)
	btn.button_down.connect(func() -> void: _touch_set(key, true))
	btn.button_up.connect(func() -> void: _touch_set(key, false))
	return btn

func _build_touch_controls() -> void:
	_touch_button("↑", Vector2(98, -161), Vector2(65, 63), "up")
	_touch_button("↓", Vector2(98, -94), Vector2(65, 63), "down")
	_touch_button("←", Vector2(30, -94), Vector2(65, 63), "left")
	_touch_button("→", Vector2(166, -94), Vector2(65, 63), "right")
	var jump := _touch_button("SKOK", Vector2(-117, -100), Vector2(100, 65), "jump")
	jump.anchor_left = 1
	jump.anchor_right = 1
	var run := _touch_button("BIEG", Vector2(-226, -100), Vector2(98, 65), "run")
	run.anchor_left = 1
	run.anchor_right = 1
	var scan := _touch_button("SKAN", Vector2(-120, -172), Vector2(103, 60), "scan")
	scan.anchor_left = 1
	scan.anchor_right = 1
	var pause_btn := _touch_button("MENU", Vector2(-120, -246), Vector2(103, 55), "menu")
	pause_btn.anchor_left = 1
	pause_btn.anchor_right = 1

func _touch_set(key: String, held: bool) -> void:
	touches[key] = held
	if key == "jump" and held:
		Input.action_press("jump")
	elif key == "jump" and not held:
		Input.action_release("jump")
	elif key == "scan" and held:
		_interact()
	elif key == "menu" and held:
		_pause_game()
	player.touch_running = touches.get("run", false)
	player.touch_axis = Vector2(
		float(int(touches.get("right", false)) - int(touches.get("left", false))),
		float(int(touches.get("down", false)) - int(touches.get("up", false)))
	).limit_length(1.0)

func _open_settings() -> void:
	terminal.show_page("settings")


func _show_about() -> void:
	terminal.show_page("about")

extends Control
## STREFA ZERO / independent retro-futuristic menu terminal.
## Game-side calls: show_home(), show_page(), refresh_save(), close_for_game().
signal new_game_requested
signal continue_requested
signal save_requested
signal exit_requested

const CRT = preload("res://shaders/terminal_crt.gdshader")
const RADAR = preload("res://scripts/ui_radar.gd")

const DARK := Color("#07120e")
const BASE := Color("#0c2118")
const PANEL := Color("#10251cc9")
const EDGE := Color("#5c7951")
const GREEN := Color("#b6e082")
const AMBER := Color("#e4ac5b")
const CREAM := Color("#d5d1a9")
const DIM := Color("#81967a")

var shell: Control
var home: Control
var page_host: Control
var home_scroll: ScrollContainer
var page_scroll: ScrollContainer
var pages: Dictionary = {}
var resume_btn: Button
var save_btn: Button
var save_feedback: Label
var settings_feedback: Label
var save_message: String = ""
var save_failed: bool = false
var session_in_progress: bool = false
var root_menu: VBoxContainer
var current_screen: String = "home"
var elapsed: float = 0.0
var screen_tick: float = 0.0
var boot_time: float = 0.0
var boot_layer: ColorRect
var boot_label: Label
var boot_finished: bool = false
var status: Label
var clock_label: Label
var ui_player: AudioStreamPlayer
var ui_sound: bool = true
var reduce_motion: bool = false
var accent: Color = GREEN
var accent_name: String = "ZIELONY FOSFOR"
var radar: Control
var crt_overlay: ColorRect
var info_text: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_sound()
	_rebuild()
	get_viewport().size_changed.connect(_on_viewport_changed)

func _on_viewport_changed() -> void:
	_rebuild()

func _rebuild() -> void:
	# Recompute the actual available vertical space instead of relying on width
	# alone. Both the main menu and subpages can scroll on short displays.
	for node in get_children():
		if node != ui_player:
			node.queue_free()
	pages.clear()
	var bounds: Vector2 = get_viewport_rect().size
	var short_height: bool = bounds.y < 520.0
	var tight_height: bool = bounds.y < 760.0
	var narrow: bool = bounds.x < 660.0
	var compact: bool = tight_height or bounds.x < 1080.0
	var show_radar: bool = bounds.x >= 1100.0 and bounds.y >= 620.0
	var panel_ratio: float = 0.66 if show_radar else minf(1.0, 820.0 / maxf(bounds.x, 1.0))
	if not show_radar and bounds.x > 970.0:
		panel_ratio = maxf(panel_ratio, 0.72)
	if not show_radar and bounds.x < 900.0:
		panel_ratio = 1.0
	var top_height: int = 34 if short_height else 44
	var footer_height: int = 30 if short_height else 36
	var spacing: int = 4 if short_height else (7 if tight_height else 10)

	shell = Control.new()
	shell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shell.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(shell)

	var backing := ColorRect.new()
	backing.color = Color("#06110cf2") if narrow else Color("#07110de8")
	backing.anchor_right = panel_ratio
	backing.anchor_bottom = 1.0
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(backing)
	var rim := ColorRect.new()
	rim.color = accent
	rim.anchor_left = panel_ratio
	rim.anchor_right = panel_ratio
	rim.anchor_bottom = 1.0
	rim.offset_left = -2
	rim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(rim)

	var top := ColorRect.new()
	top.color = Color("#192d20")
	top.anchor_right = 1.0
	top.offset_bottom = top_height
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(top)
	var top_inner := HBoxContainer.new()
	top_inner.anchor_right = 1.0
	top_inner.offset_left = 16 if narrow else 24
	top_inner.offset_right = -16
	top_inner.offset_top = 7
	top_inner.offset_bottom = top_height - 6
	top_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(top_inner)
	_label(top_inner, "SZ-OS / TERMINAL" if narrow else "◈  SZ-OS / TERMINAL DOSTĘPU", 12 if compact else 15, accent)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_inner.add_child(spacer)
	clock_label = _label(top_inner, "2189 // 07", 11 if compact else 12, DIM)
	clock_label.visible = bounds.x >= 600.0

	var floor_bar := ColorRect.new()
	floor_bar.color = Color("#14271cef")
	floor_bar.anchor_top = 1.0
	floor_bar.anchor_bottom = 1.0
	floor_bar.anchor_right = 1.0
	floor_bar.offset_top = -footer_height
	floor_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(floor_bar)
	var footer := HBoxContainer.new()
	footer.anchor_top = 1.0
	footer.anchor_bottom = 1.0
	footer.anchor_right = 1.0
	footer.offset_top = -footer_height + 5
	footer.offset_bottom = -5
	footer.offset_left = 16 if narrow else 24
	footer.offset_right = -16
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(footer)
	status = _label(footer, "SYS: GOTOWOŚĆ  |  KANAŁ 07", 10 if narrow else 11, accent)
	var fs := Control.new()
	fs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_child(fs)
	var version := _label(footer, "V 0.1 // PRE-ALPHA", 10 if compact else 11, DIM)
	version.visible = bounds.x >= 590.0

	# The fixed header and footer are outside the scrolling content.
	# ScrollContainer ensures every button remains reachable at 844x390,
	# 1024x600, 1366x768 and phone portrait resolutions.
	var main_margin := MarginContainer.new()
	main_margin.anchor_right = panel_ratio
	main_margin.anchor_bottom = 1.0
	main_margin.offset_top = top_height + 3
	main_margin.offset_bottom = -footer_height - 3
	main_margin.add_theme_constant_override("margin_left", 17 if narrow else (30 if compact else 50))
	main_margin.add_theme_constant_override("margin_right", 17 if narrow else (28 if compact else 40))
	main_margin.add_theme_constant_override("margin_top", 9 if tight_height else 18)
	main_margin.add_theme_constant_override("margin_bottom", 8)
	shell.add_child(main_margin)
	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 0)
	main_margin.add_child(stack)

	home_scroll = ScrollContainer.new()
	home_scroll.name = "HomeScroll"
	home_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	home_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	home_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	home_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	home_scroll.follow_focus = true
	stack.add_child(home_scroll)
	home = VBoxContainer.new()
	home.name = "HomeContent"
	home.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	home.add_theme_constant_override("separation", spacing)
	home_scroll.add_child(home)

	_label(home, "S Y S T E M   / /   2 1 8 9", 11 if compact else 12, AMBER)
	var title_size: int = 42 if narrow else (49 if tight_height else 70)
	var zero_size: int = 50 if narrow else (58 if tight_height else 88)
	_label(home, "STREFA", title_size, CREAM)
	_label(home, "ZERO", zero_size, accent)
	_label(home, "ARCHIWUM OCALAŁYCH  //  SEKTOR 07", 11 if compact else 13, DIM)
	_divider(home)
	var menu_space := Control.new()
	menu_space.custom_minimum_size.y = 2 if tight_height else 12
	home.add_child(menu_space)

	root_menu = VBoxContainer.new()
	root_menu.add_theme_constant_override("separation", 5 if tight_height else 8)
	home.add_child(root_menu)
	resume_btn = _button(root_menu, "01  /  KONTYNUUJ", continue_requested.emit, compact)
	_button(root_menu, "02  /  NOWA WYPRAWA", new_game_requested.emit, compact)
	_button(root_menu, "03  /  USTAWIENIA", func() -> void: show_page("settings"), compact)
	_button(root_menu, "04  /  ARCHIWUM ŚWIATA", func() -> void: show_page("archive"), compact)
	_button(root_menu, "05  /  O PROJEKCIE", func() -> void: show_page("about"), compact)
	_button(root_menu, "06  /  WYJŚCIE", func() -> void: show_page("exit"), compact)
	if not tight_height and bounds.x >= 650.0:
		_label(home, "◉ TRANSMISJA W TOKU  /  ODBIÓR: NISKI", 11, DIM)
	home_scroll.visible = current_screen == "home"

	page_scroll = ScrollContainer.new()
	page_scroll.name = "PagesScroll"
	page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	page_scroll.follow_focus = true
	stack.add_child(page_scroll)
	page_host = VBoxContainer.new()
	page_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_host.add_theme_constant_override("separation", 8 if compact else 11)
	page_scroll.add_child(page_host)
	_build_pages(compact)
	page_scroll.visible = current_screen != "home"

	# This is a smaller supplementary instrument, not a second fullscreen
	# panel; hide it entirely on narrow or low landscape viewports.
	if show_radar:
		var side := Control.new()
		side.anchor_left = panel_ratio
		side.anchor_right = 1.0
		side.anchor_bottom = 1.0
		side.offset_top = top_height
		side.offset_bottom = -footer_height
		side.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shell.add_child(side)
		var side_screen := PanelContainer.new()
		side_screen.anchor_left = 0.10
		side_screen.anchor_right = 0.90
		side_screen.anchor_top = 0.20
		side_screen.anchor_bottom = 0.75
		side_screen.add_theme_stylebox_override("panel", _style(Color("#06110cc7"), EDGE, 2))
		side.add_child(side_screen)
		radar = RADAR.new()
		radar.name = "SignalCartography"
		radar.accent = accent
		radar.reduced_motion = reduce_motion
		radar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		side_screen.add_child(radar)
		radar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var side_title := _label(side, "TAKTYCZNA / MAPA", 13, accent)
		side_title.anchor_left = 0.12
		side_title.anchor_right = 0.95
		side_title.anchor_top = 0.14
		var side_desc := _label(side, "SYGNAŁ: NIESTABILNY", 12, AMBER)
		side_desc.anchor_left = 0.12
		side_desc.anchor_right = 0.95
		side_desc.anchor_top = 0.79

	crt_overlay = ColorRect.new()
	crt_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	crt_overlay.color = Color.WHITE
	crt_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := ShaderMaterial.new()
	shader.shader = CRT
	shader.set_shader_parameter("strength", 0.0 if reduce_motion else 0.47)
	crt_overlay.material = shader
	shell.add_child(crt_overlay)

	if not boot_finished:
		boot_layer = ColorRect.new()
		boot_layer.color = DARK
		boot_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		boot_layer.mouse_filter = Control.MOUSE_FILTER_STOP
		shell.add_child(boot_layer)
		var center := CenterContainer.new()
		center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		center.mouse_filter = Control.MOUSE_FILTER_IGNORE
		boot_layer.add_child(center)
		boot_label = _label(center, "INICJALIZACJA SYSTEMU...", 20 if not compact else 15, accent)
	else:
		boot_layer = null
	refresh_save()

func _style(bg: Color, border: Color, border_width: int = 1) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_width)
	sb.set_corner_radius_all(2)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 9
	sb.content_margin_bottom = 9
	return sb

func _label(parent: Node, content: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = content
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _divider(parent: Node) -> void:
	var line := HSeparator.new()
	var line_style := StyleBoxLine.new()
	line_style.color = EDGE
	line_style.thickness = 1
	line.add_theme_stylebox_override("separator", line_style)
	line.custom_minimum_size.y = 1
	parent.add_child(line)

func _button(parent: Node, content: String, action: Callable, small: bool = false) -> Button:
	var btn := Button.new()
	btn.text = content
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(0, 42 if small else 48)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.focus_mode = Control.FOCUS_ALL
	btn.add_theme_font_size_override("font_size", 14 if small else 16)
	btn.add_theme_color_override("font_color", CREAM)
	btn.add_theme_color_override("font_hover_color", accent)
	btn.add_theme_color_override("font_pressed_color", DARK)
	btn.add_theme_color_override("font_focus_color", accent)
	btn.add_theme_stylebox_override("normal", _style(Color("#10251bbd"), EDGE))
	btn.add_theme_stylebox_override("hover", _style(Color("#243c29ed"), accent, 2))
	btn.add_theme_stylebox_override("pressed", _style(accent, accent, 2))
	btn.add_theme_stylebox_override("focus", _style(Color.TRANSPARENT, AMBER, 1))
	btn.mouse_entered.connect(func() -> void: _play_sound(660.0, 0.017, 0.1))
	btn.pressed.connect(func() -> void:
		_play_sound(400.0, 0.065, 0.22)
		action.call()
	)
	parent.add_child(btn)
	return btn

func _section(name: String, tag: String, compact: bool) -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.name = name
	panel.add_theme_constant_override("separation", 10 if not compact else 5)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_host.add_child(panel)
	pages[name] = panel
	_label(panel, "◈  " + tag, 12, AMBER)
	var translated := {"settings": "USTAWIENIA", "archive": "ARCHIWUM", "about": "O PROJEKCIE", "exit": "WYJŚCIE"}
	_label(panel, str(translated.get(name, name.to_upper())), 28 if compact else 40, accent)
	_divider(panel)
	return panel

func _build_pages(compact: bool) -> void:
	var settings := _section("settings", "CONFIG / SZ-OS", compact)
	_label(settings, "OBRAZ  /  POLE WIDZENIA", 12, DIM)
	var fov := HSlider.new()
	fov.min_value = 65
	fov.max_value = 100
	fov.step = 1
	fov.value = GameState.fov
	fov.custom_minimum_size.y = 26
	fov.value_changed.connect(func(value: float) -> void: GameState.fov = value)
	settings.add_child(fov)
	_label(settings, "STEROWANIE  /  CZUŁOŚĆ MYSZY", 12, DIM)
	var sens := HSlider.new()
	sens.min_value = 0.03
	sens.max_value = 0.35
	sens.step = 0.01
	sens.value = GameState.sensitivity
	sens.custom_minimum_size.y = 26
	sens.value_changed.connect(func(value: float) -> void: GameState.sensitivity = value)
	settings.add_child(sens)
	_label(settings, "EKRAN CRT  /  KOLORY FOSFORU", 12, DIM)
	var palette := OptionButton.new()
	palette.add_item("FOSFOR ZIELONY")
	palette.add_item("BURSZTYN")
	palette.select(1 if accent_name == "BURSZTYN" else 0)
	palette.item_selected.connect(func(index: int) -> void:
		accent_name = "BURSZTYN" if index == 1 else "ZIELONY FOSFOR"
		accent = AMBER if index == 1 else GREEN
		_play_sound(580, 0.065, 0.2)
		_rebuild()
	)
	settings.add_child(palette)
	var audio_toggle := CheckBox.new()
	audio_toggle.text = "DŹWIĘKI TERMINALA"
	audio_toggle.button_pressed = ui_sound
	audio_toggle.add_theme_font_size_override("font_size", 13)
	audio_toggle.toggled.connect(func(on: bool) -> void: ui_sound = on)
	settings.add_child(audio_toggle)
	var motion_toggle := CheckBox.new()
	motion_toggle.text = "OGRANICZ ANIMACJE / CRT"
	motion_toggle.button_pressed = reduce_motion
	motion_toggle.add_theme_font_size_override("font_size", 13)
	motion_toggle.toggled.connect(func(on: bool) -> void:
		reduce_motion = on
		_rebuild()
	)
	settings.add_child(motion_toggle)
	settings_feedback = _label(settings, "", 14, AMBER)
	settings_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_button(settings, "ZAPISZ USTAWIENIA", _save_and_home, compact)
	_button(settings, "◀  POWRÓT", show_home, compact)

	var archive := _section("archive", "ARCHIVE / ODZYSKANE DANE", compact)
	var records := VBoxContainer.new()
	records.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	records.add_theme_constant_override("separation", 10)
	archive.add_child(records)
	for entry in [
		["REJESTR 001  /  DZIEŃ ZEROWY", "Rok 2086. Systemy obronne przestały odpowiadać. Ziemia po raz pierwszy zamilkła. Kolejne pokolenia zapamiętały już tylko pustkowia."],
		["REJESTR 007  /  KORYTARZ POŁUDNIOWY", "Na starej trasie paliwowej działał punkt ASHEN MILE. Dziś stacja nadaje słaby sygnał, lecz nie ma śladów aktualnej obsługi."],
		["REJESTR 018  /  SEKTOR SIEDEM", "Wokół posterunku odnotowano awarię przekaźnika dalekiego zasięgu. Ostrzeżenia o skażeniu są niekompletne."],
		["DOSTĘP OGRANICZONY", "Dalsze wpisy zostaną odblokowane wraz z rozwojem świata. Obecne zapisy są wprowadzeniem fabularnym."]
	]:
		_label(records, str(entry[0]), 14, AMBER)
		var body := _label(records, str(entry[1]), 15, CREAM)
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_button(archive, "◀  POWRÓT", show_home, compact)

	var about := _section("about", "DOSSIER / INFORMACJE", compact)
	var lines: Array[String] = [
		"STREFA ZERO  /  PROTOKÓŁ 2189",
		"Autorskie RPG 3D o świecie, który przetrwał katastrofę, lecz stracił swoją pamięć.",
		"Wersja pre-alpha. Godot 4 / Windows Portable. Budujemy świat, zadania, postacie i wybory, których konsekwencje pozostaną na długo.",
		"ZAPISY: LOKALNE  |  SYGNAŁ: NIESTABILNY",
		"Projekt jest niezależny i nie jest powiązany z marką Fallout."
	]
	for i in range(lines.size()):
		var l := _label(about, lines[i], 13 if compact else 16, AMBER if i == 0 or i == 3 else CREAM)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_button(about, "◀  POWRÓT", show_home, compact)

	var exit_page := _section("exit", "POŁĄCZENIE / ZAKOŃCZ SESJĘ", compact)
	var exit_text := "WERSJA WINDOWS PORTABLE\nPrzed zamknięciem gry zapisz wyprawę przyciskiem poniżej.\nZapisy i ustawienia: folder userdata obok gry."
	if OS.has_feature("web"):
		exit_text = "WERSJA PRZEGLĄDARKOWA\nPrzed zamknięciem karty zapisz wyprawę przyciskiem poniżej.\nZapis jest lokalny dla tej przeglądarki."
	var notice := _label(exit_page, exit_text, 16, CREAM)
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_feedback = _label(exit_page, save_message, 14, AMBER if save_failed else GREEN)
	save_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_btn = _button(exit_page, "ZAPISZ POZYCJĘ GRACZA", save_requested.emit, compact)
	save_btn.disabled = not session_in_progress
	if not OS.has_feature("web"):
		_button(exit_page, "ZAMKNIJ GRĘ", exit_requested.emit, compact)
	_button(exit_page, "◀  POWRÓT", show_home, compact)

	for name in pages:
		(pages[name] as Control).visible = current_screen == name

func _process(delta: float) -> void:
	if not visible:
		return
	elapsed += delta
	screen_tick += delta
	if not boot_finished and boot_layer != null:
		boot_time += delta
		if reduce_motion or boot_time > 1.45:
			boot_finished = true
			boot_layer.queue_free()
			boot_layer = null
		else:
			if boot_time > 0.45:
				boot_label.text = "ODSZYFROWYWANIE REJESTRU / 2189"
			if boot_time > 0.95:
				boot_label.text = "POŁĄCZENIE NAWIĄZANE  ✓"
	if screen_tick > 0.45 and clock_label != null:
		screen_tick = 0
		var sec: int = int(elapsed) % 60
		clock_label.text = "ROK 2189 // 07:%02d  ■" % sec
		if status != null:
			status.text = "◉  KANAŁ AKTYWNY" if int(elapsed) % 9 < 6 else "◈  SKANOWANIE FREKWENCJI"

func show_home() -> void:
	show_page("home")

func show_page(name: String) -> void:
	if name != "home" and not pages.has(name):
		return
	current_screen = name
	home_scroll.visible = name == "home"
	page_scroll.visible = name != "home"
	if name == "home":
		home_scroll.scroll_vertical = 0
	else:
		page_scroll.scroll_vertical = 0
	for key in pages:
		(pages[key] as Control).visible = key == name
	_play_sound(550, 0.045, 0.15)

func refresh_save() -> void:
	if resume_btn != null:
		resume_btn.disabled = not GameState.has_save and not session_in_progress
	if save_btn != null:
		save_btn.disabled = not session_in_progress

func set_save_feedback(message: String, failed: bool = false) -> void:
	save_message = message
	save_failed = failed
	if save_feedback != null:
		save_feedback.text = message
		save_feedback.add_theme_color_override("font_color", AMBER if failed else GREEN)

func _save_and_home() -> void:
	var settings_result := GameState.store_settings()
	var prefs_result := _save_prefs()
	if settings_result != OK or prefs_result != OK:
		settings_feedback.text = "NIE UDAŁO SIĘ ZAPISAĆ WSZYSTKICH USTAWIEŃ. SPRÓBUJ PONOWNIE."
		return
	show_home()

func _load_prefs() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(GameState.terminal_prefs_path) == OK:
		accent_name = str(cfg.get_value("terminal", "palette", "ZIELONY FOSFOR"))
		accent = AMBER if accent_name == "BURSZTYN" else GREEN
		reduce_motion = bool(cfg.get_value("terminal", "reduced_motion", false))
		ui_sound = bool(cfg.get_value("terminal", "sounds", true))

func _save_prefs() -> Error:
	var cfg := ConfigFile.new()
	cfg.set_value("terminal", "palette", accent_name)
	cfg.set_value("terminal", "reduced_motion", reduce_motion)
	cfg.set_value("terminal", "sounds", ui_sound)
	return cfg.save(GameState.terminal_prefs_path)

func _build_sound() -> void:
	_load_prefs()
	ui_player = AudioStreamPlayer.new()
	ui_player.bus = "Master"
	add_child(ui_player)

func _play_sound(freq: float, length: float, volume: float) -> void:
	if not ui_sound or ui_player == null:
		return
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var count := int(length * 22050)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	for i in range(count):
		var t := float(i) / 22050.0
		var envelope := pow(1.0 - float(i) / float(count), 2)
		var s := sin(TAU * freq * t) * envelope * volume
		var sample := int(clampf(s, -1, 1) * 32767.0)
		bytes.encode_s16(i * 2, sample)
	stream.data = bytes
	ui_player.stream = stream
	ui_player.play()

extends Control
## Decorative CRT cartography drawn as vectors, no textures or heavy effects.

var sweep_time: float = 0.0
var redraw_timer: float = 0.0
var accent: Color = Color("#a9d477")
var reduced_motion: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)

func _process(delta: float) -> void:
	if not visible or reduced_motion:
		return
	sweep_time += delta
	redraw_timer += delta
	if redraw_timer >= 0.065:
		redraw_timer = 0.0
		queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w < 10.0 or h < 10.0:
		return
	var grid_color := Color(accent.r, accent.g, accent.b, 0.085)
	var edge_color := Color(accent.r, accent.g, accent.b, 0.27)
	for i in range(int(w / 42.0) + 1):
		var x: float = float(i) * 42.0
		draw_line(Vector2(x, 0), Vector2(x, h), grid_color, 1.0)
	for j in range(int(h / 42.0) + 1):
		var y: float = float(j) * 42.0
		draw_line(Vector2(0, y), Vector2(w, y), grid_color, 1.0)
	for i in range(20):
		var px := float((i * 117 + 37) % maxi(int(w), 1))
		var py := float((i * 73 + 127) % maxi(int(h), 1))
		draw_line(Vector2(px - 4, py), Vector2(px + 4, py), grid_color, 1.0)
		draw_line(Vector2(px, py - 4), Vector2(px, py + 4), grid_color, 1.0)

	var center := Vector2(w * 0.71, h * 0.40)
	var radius: float = minf(w * 0.28, h * 0.28)
	for ring in [0.37, 0.69, 1.0]:
		draw_arc(center, radius * ring, 0.0, TAU, 96, edge_color, 1.0, true)
	for step in range(24):
		var theta := float(step) / 24.0 * TAU
		var inner_radius: float = radius * (0.89 if step % 3 == 0 else 0.94)
		var a := center + Vector2(cos(theta), sin(theta)) * inner_radius
		var b := center + Vector2(cos(theta), sin(theta)) * radius
		draw_line(a, b, edge_color, 1.3, true)
	draw_line(center + Vector2(-radius, 0), center + Vector2(radius, 0), grid_color, 1.0)
	draw_line(center + Vector2(0, -radius), center + Vector2(0, radius), grid_color, 1.0)

	var theta: float = -sweep_time * 0.48
	var endpoint := center + Vector2(cos(theta), sin(theta)) * radius
	draw_line(center, endpoint, Color(accent.r, accent.g, accent.b, 0.33), 2.0, true)
	for p in [Vector2(-0.53, -0.28), Vector2(0.21, 0.62), Vector2(0.52, -0.14)]:
		var point := center + p * radius
		draw_circle(point, 3.0, Color(accent.r, accent.g, accent.b, 0.55))
		draw_arc(point, 7, 0, TAU, 18, edge_color, 1.0)

	var bottom := Vector2(28, h - 84)
	draw_line(bottom, bottom + Vector2(w * 0.7, 0), edge_color, 1.0)
	for i in range(56):
		var x: float = bottom.x + float(i) * (w * 0.69 / 55.0)
		var y: float = bottom.y + sin(float(i) * 0.4) * 7.0 + sin(float(i) * 1.25) * 3.0
		if i > 0:
			var px: float = bottom.x + float(i - 1) * (w * 0.69 / 55.0)
			var py: float = bottom.y + sin(float(i - 1) * 0.4) * 7.0 + sin(float(i - 1) * 1.25) * 3.0
			draw_line(Vector2(px, py), Vector2(x, y), edge_color, 1.6, true)
	draw_line(Vector2(0, 1), Vector2(w, 1), grid_color, 2.0)
	draw_line(Vector2(0, h - 1), Vector2(w, h - 1), grid_color, 2.0)

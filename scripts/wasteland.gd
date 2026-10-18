extends Node3D
## Hand-built procedural environment: geometry, props, composition and art direction.
## Browser-first: no external downloads, runtime image generation or heavy postprocessing.

const SEED := 2189
var rng := RandomNumberGenerator.new()
var materials: Dictionary = {}
var dust: StandardMaterial3D

func _ready() -> void:
	rng.seed = SEED
	_materials()
	_terrain()
	_road()
	_fuel_stop()
	_outpost()
	_radio_tower()
	_ruined_skyline()
	_vehicles()
	_details()
	_lighting()

func _mat(id: String, color: Color, rough: float = 0.95, metallic: float = 0.0, glow: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	m.metallic = metallic
	if glow:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 1.5
	materials[id] = m
	return m

func _materials() -> void:
	dust = _mat("dust", Color("#a58a68"))
	_mat("sand", Color("#968064"))
	_mat("asphalt", Color("#282c2b"))
	_mat("asphalt_edge", Color("#46443c"))
	_mat("yellow", Color("#bba15e"))
	_mat("roadcrack", Color("#151a19"))
	_mat("concrete", Color("#736f61"))
	_mat("concrete_light", Color("#969487"))
	_mat("concrete_dark", Color("#484c48"))
	_mat("rust", Color("#7b432f"), 0.85, 0.15)
	_mat("rust_light", Color("#ae6647"), 0.92, 0.1)
	_mat("metal", Color("#5e6561"), 0.55, 0.55)
	_mat("dark_metal", Color("#242e31"), 0.62, 0.5)
	_mat("ivory", Color("#c7b99b"))
	_mat("glass", Color("#162f33"), 0.18, 0.3)
	_mat("glass2", Color("#214d4d"), 0.24, 0.2)
	_mat("accent", Color("#b1ca67"), 0.7, 0.05, true)
	_mat("warm_glow", Color("#ed9c53"), 0.7, 0, true)
	_mat("paint", Color("#7a8b7e"), 0.83, 0.12)
	_mat("car_red", Color("#834638"), 0.74, 0.24)
	_mat("car_cream", Color("#ac9674"), 0.81, 0.22)
	_mat("plant", Color("#625a3e"))
	_mat("plant2", Color("#77734d"))
	_mat("rock", Color("#716b5a"))
	_mat("black", Color("#1b1e1e"))
	# Add world-space surface patina: mottled asphalt, oxidized steel and concrete.
	var patina: Shader = preload("res://shaders/grunge.gdshader")
	var finish: Dictionary = {
		"asphalt": [Color("#333737"), 24.0, 0.55, 0.0],
		"rust": [Color("#91513a"), 10.0, 0.85, 0.2],
		"rust_light": [Color("#b87350"), 16.0, 0.75, 0.14],
		"concrete": [Color("#8f8876"), 15.0, 0.95, 0.0],
		"concrete_dark": [Color("#585852"), 10.0, 0.85, 0.0],
		"paint": [Color("#80948b"), 22.0, 0.6, 0.16]
	}
	for key in finish:
		var config: Array = finish[key]
		var patterned := ShaderMaterial.new()
		patterned.shader = patina
		patterned.set_shader_parameter("base_color", config[0])
		patterned.set_shader_parameter("fleck_scale", config[1])
		patterned.set_shader_parameter("weathering", config[2])
		patterned.set_shader_parameter("metalness", config[3])
		materials[key] = patterned

func _box(parent: Node3D, pos: Vector3, size: Vector3, key: String, solid: bool = false, angle: float = 0.0) -> Node3D:
	var holder := Node3D.new()
	holder.position = pos
	holder.rotation.y = angle
	parent.add_child(holder)
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.material_override = materials[key]
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	holder.add_child(mesh)
	if solid:
		var body := StaticBody3D.new()
		holder.add_child(body)
		var collider := CollisionShape3D.new()
		var s := BoxShape3D.new()
		s.size = size
		collider.shape = s
		body.add_child(collider)
	return holder

func _cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, key: String, top_radius: float = -1.0) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = radius if top_radius < 0 else top_radius
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = 10
	mesh.mesh = shape
	mesh.material_override = materials[key]
	mesh.position = pos
	parent.add_child(mesh)
	return mesh

func _rod(parent: Node3D, a: Vector3, b: Vector3, radius: float, key: String) -> void:
	var diff := b - a
	if diff.length() < 0.01:
		return
	var mesh := _cylinder(parent, (a + b) * 0.5, radius, diff.length(), key)
	mesh.quaternion = Quaternion(Vector3.UP, diff.normalized())

func _label(parent: Node3D, text: String, pos: Vector3, color: Color, size: int = 72) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = size
	label.pixel_size = 0.006
	label.modulate = color
	label.outline_modulate = Color("#151d1d")
	label.outline_size = 12
	label.position = pos
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	parent.add_child(label)
	return label

func _terrain() -> void:
	var noise := FastNoiseLite.new()
	noise.seed = SEED
	noise.frequency = 0.075
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var colors := [Color("#8e8067"), Color("#9b8265"), Color("#7a785f"), Color("#a18a6b")]
	for iz in range(100):
		for ix in range(100):
			var x := float(ix - 50) * 2.5
			var z := float(iz - 50) * 2.5
			var points: Array[Vector3] = []
			for offset in [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]:
				var px: float = x + float(offset.x) * 2.5
				var pz: float = z + float(offset.y) * 2.5
				var amount := noise.get_noise_2d(px, pz)
				var h := amount * 0.45
				if absf(px) < 27.0 and pz < 36.0 and pz > -62.0:
					h *= 0.1
				points.append(Vector3(px, h - 0.25, pz))
			for p in points:
				st.set_color(colors[(ix * 7 + iz * 13) % colors.size()])
				st.add_vertex(p)
	st.generate_normals()
	var terrain_mesh := MeshInstance3D.new()
	terrain_mesh.mesh = st.commit()
	var terrain_mat := StandardMaterial3D.new()
	terrain_mat.vertex_color_use_as_albedo = true
	terrain_mat.roughness = 1.0
	terrain_mesh.material_override = terrain_mat
	add_child(terrain_mesh)
	# Broad stable collision for the early traversal scene.
	_box(self, Vector3(0, -1.6, 0), Vector3(255, 2.65, 255), "sand", true)
	# Distant low ridges provide silhouettes rather than a flat horizon.
	for i in range(28):
		var side := -1.0 if i % 2 == 0 else 1.0
		var p := Vector3(side * rng.randf_range(65, 115), -1.3, rng.randf_range(-115, 85))
		_rock(p, rng.randf_range(8, 24), "rock")

func _road() -> void:
	_box(self, Vector3(0, 0.02, -7), Vector3(11.2, 0.15, 146), "asphalt", true)
	for edge in [-5.6, 5.6]:
		_box(self, Vector3(edge, 0.05, -7), Vector3(0.32, 0.19, 146), "asphalt_edge")
		for j in range(18):
			var z := -72.0 + j * 8.0
			_box(self, Vector3(edge * 0.9, 0.14, z), Vector3(0.1, 0.016, rng.randf_range(2, 4)), "yellow")
	for j in range(20):
		var z := -67.0 + j * 7.2
		_box(self, Vector3(0.0, 0.15, z), Vector3(0.16, 0.015, 3.2), "yellow")
	for i in range(64):
		var x := rng.randf_range(-5.1, 5.1)
		var z := rng.randf_range(-70, 60)
		var a := Vector3(x, 0.151, z)
		var b := a + Vector3(rng.randf_range(-1.2, 1.2), 0.0, rng.randf_range(-1.5, 1.5))
		var c := b + Vector3(rng.randf_range(-0.7, 0.7), 0.0, rng.randf_range(-0.7, 0.7))
		_rod(self, a, b, 0.016, "roadcrack")
		_rod(self, b, c, 0.01, "roadcrack")
	# Crumbling hard shoulders.
	for i in range(100):
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := side * rng.randf_range(6, 10)
		var z := rng.randf_range(-73, 64)
		_rock(Vector3(x, 0.05, z), rng.randf_range(0.17, 0.9), "concrete_dark")

func _fuel_stop() -> void:
	var stop := Node3D.new()
	stop.name = "The Ashen Mile — abandoned roadside service"
	stop.position = Vector3(-17, 0.15, -22)
	add_child(stop)
	_box(stop, Vector3(0, 2.0, -11), Vector3(13, 4, 8), "concrete", true)
	_box(stop, Vector3(0, 4.15, -11), Vector3(14.5, 0.45, 9), "dark_metal")
	_box(stop, Vector3(0, 4.6, -7.0), Vector3(14.5, 0.7, 0.7), "rust")
	_box(stop, Vector3(0, 0.16, -7.0), Vector3(14, 0.28, 9.5), "concrete_light")
	# Store front: mullions, doors, uneven boarded glass.
	for x in [-5.0, -3.5, 0.0, 2.3, 4.3]:
		_box(stop, Vector3(x, 2.3, -6.9), Vector3(0.17, 3.3, 0.15), "dark_metal")
	for x in [-4.25, -2.1, 1.05, 3.2]:
		_box(stop, Vector3(x, 2.2, -6.97), Vector3(1.55, 2.95, 0.12), "glass")
	for x in [-3.0, 3.9]:
		_box(stop, Vector3(x, 1.1, -6.74), Vector3(2.2, 0.23, 0.2), "rust_light", false, rng.randf_range(-0.15, 0.15))
	_box(stop, Vector3(-0.4, 2.0, -6.64), Vector3(1.35, 3.7, 0.18), "rust", true)
	_box(stop, Vector3(0.12, 2.3, -6.52), Vector3(0.08, 0.35, 0.16), "ivory")
	# Shop sign framed with rust and neon.
	_box(stop, Vector3(0, 5.25, -6.8), Vector3(12.3, 1.5, 0.42), "rust")
	_box(stop, Vector3(0, 5.25, -6.54), Vector3(11.9, 1.12, 0.08), "dark_metal")
	_label(stop, "ASHEN MILE  /  SERVICE", Vector3(0, 5.22, -6.39), Color("#d3d7b4"), 58)
	_box(stop, Vector3(0, 4.55, -6.37), Vector3(11.1, 0.075, 0.08), "accent")
	# A roof canopy with skinny weathered columns and inset lights.
	_box(stop, Vector3(4, 5.1, 2.8), Vector3(17, 0.58, 11), "rust")
	_box(stop, Vector3(4, 4.77, 2.8), Vector3(16.6, 0.12, 10.6), "ivory")
	for x in [-3.0, 11.0]:
		for z in [-1.3, 7.0]:
			_cylinder(stop, Vector3(x, 2.48, z), 0.22, 4.85, "metal")
			_box(stop, Vector3(x, 0.23, z), Vector3(0.7, 0.3, 0.7), "concrete_dark")
	for x in [-0.7, 8.2]:
		_box(stop, Vector3(x, 4.68, 3), Vector3(3.2, 0.09, 0.3), "warm_glow")
	# Pumps: detailed body, hoses, dials and blockers.
	for z in [-0.4, 5.1]:
		_pump(stop, Vector3(3.2, 0.0, z))
		_pump(stop, Vector3(6.7, 0.0, z))
	# Neon sign tower visible from the road.
	_rod(stop, Vector3(11.5, 0, 9), Vector3(11.5, 11.5, 9), 0.19, "rust")
	_box(stop, Vector3(11.5, 10.0, 9), Vector3(7.6, 3.6, 0.5), "rust")
	_box(stop, Vector3(11.5, 10, 9.3), Vector3(7, 3, 0.08), "dark_metal")
	_label(stop, "STREFA", Vector3(11.5, 10.7, 9.38), Color("#c9d690"), 95)
	_label(stop, "ZERO", Vector3(11.5, 9.25, 9.38), Color("#e9a05e"), 100)
	for z in [-3, -1, 4, 9]:
		_barrel(stop, Vector3(rng.randf_range(-6, -4), 0.36, z))
	# Industrial junk and leaking pipework.
	for i in range(12):
		var px := rng.randf_range(-6, 10)
		var pz := rng.randf_range(-4, 9)
		if rng.randf() > 0.42:
			_rock(stop.to_global(Vector3(px, 0, pz)), rng.randf_range(0.25, 0.7), "concrete")
	_rod(stop, Vector3(-5, 4.4, -10), Vector3(-5, 3, -14), 0.08, "rust_light")

func _pump(parent: Node3D, p: Vector3) -> void:
	_box(parent, p + Vector3(0, 0.15, 0), Vector3(1.2, 0.25, 1.25), "concrete_dark")
	_box(parent, p + Vector3(0, 1.13, 0), Vector3(0.8, 1.75, 0.65), "rust_light")
	_box(parent, p + Vector3(0, 2.08, 0), Vector3(0.92, 0.24, 0.78), "ivory")
	_box(parent, p + Vector3(0, 1.63, 0.35), Vector3(0.54, 0.43, 0.09), "glass")
	_label(parent, "00.0", p + Vector3(0, 1.61, 0.42), Color("#a4ca9b"), 24)
	_rod(parent, p + Vector3(0.42, 1.7, 0), p + Vector3(0.8, 0.9, 0.16), 0.055, "black")
	_rod(parent, p + Vector3(0.8, 0.9, 0.16), p + Vector3(0.53, 0.38, 0.1), 0.05, "black")
	_box(parent, p + Vector3(0.56, 0.55, 0.1), Vector3(0.25, 0.3, 0.19), "dark_metal")

func _outpost() -> void:
	var outpost := Node3D.new()
	outpost.position = Vector3(19, 0, -17)
	outpost.name = "Scavenger checkpoint"
	add_child(outpost)
	# Broken perimeter walls, gaps and varied heights.
	for i in range(6):
		var x := -11.0 + i * 4.3
		var h := rng.randf_range(2.2, 3.8)
		if i == 2:
			continue
		_box(outpost, Vector3(x, h * 0.5, -7), Vector3(4.2, h, 0.5), "concrete", true, rng.randf_range(-0.07, 0.07))
		_box(outpost, Vector3(x, h * 0.4, -6.65), Vector3(3, 0.14, 0.08), "concrete_dark", false, rng.randf_range(-0.2, 0.2))
	for i in range(8):
		var z := -6.0 + i * 2.4
		_box(outpost, Vector3(12, rng.randf_range(0.6, 1.4), z), Vector3(0.45, rng.randf_range(1.2, 2.8), 2.35), "concrete", true)
	# Watch platform on stilts.
	for x in [1.0, 5.0]:
		for z in [-3.0, 1.0]:
			_rod(outpost, Vector3(x, 0, z), Vector3(x, 6.1, z), 0.15, "rust")
	_box(outpost, Vector3(3, 5.6, -1), Vector3(5.4, 0.32, 5.4), "metal")
	_box(outpost, Vector3(3, 8.4, -1), Vector3(6.4, 0.35, 6.4), "rust")
	for x in [0.4, 5.6]:
		_box(outpost, Vector3(x, 6.85, -1), Vector3(0.2, 2.45, 5.3), "rust")
	for z in [-3.6, 1.6]:
		_box(outpost, Vector3(3, 6.85, z), Vector3(5.3, 2.45, 0.22), "rust")
	_box(outpost, Vector3(3, 6.8, 1.77), Vector3(3.5, 1.5, 0.09), "glass")
	_label(outpost, "SECTOR 07", Vector3(3, 4.6, 1.7), Color("#ddc496"), 35)
	# Stairs suggested by separate metal treads.
	for i in range(13):
		_box(outpost, Vector3(-1.9 + i * 0.22, 0.25 + i * 0.42, -1), Vector3(1.5, 0.16, 0.62), "metal")
	# Scrap heaps, concrete blocks and fencing.
	for i in range(14):
		_box(outpost, Vector3(rng.randf_range(-11, 10), 0.25, rng.randf_range(3, 14)), Vector3(rng.randf_range(0.5, 2.2), 0.4, 0.3), "rust", false, rng.randf_range(-3, 3))

func _radio_tower() -> void:
	var tower := Node3D.new()
	tower.name = "Longwave transmitter"
	tower.position = Vector3(39, 0, -56)
	add_child(tower)
	for y in range(8):
		var bottom := float(y) * 2.7
		var shrink := 4.4 - float(y) * 0.35
		var ns := shrink - 0.35
		for sx in [-1.0, 1.0]:
			for sz in [-1.0, 1.0]:
				_rod(tower, Vector3(sx * shrink, bottom, sz * shrink), Vector3(sx * ns, bottom + 2.7, sz * ns), 0.09, "rust")
		_rod(tower, Vector3(-shrink, bottom, -shrink), Vector3(shrink, bottom + 2.7, -ns), 0.06, "metal")
		_rod(tower, Vector3(shrink, bottom, shrink), Vector3(-ns, bottom + 2.7, ns), 0.06, "metal")
	_rod(tower, Vector3(0, 21.4, 0), Vector3(0, 30, 0), 0.1, "dark_metal")
	_cylinder(tower, Vector3(0, 29.2, 0), 0.37, 0.6, "warm_glow")

func _ruined_skyline() -> void:
	for i in range(17):
		var x := rng.randf_range(-92, 87)
		if absf(x) < 20:
			x += 25 if x >= 0 else -25
		var z := rng.randf_range(-95, -65)
		var h := rng.randf_range(13, 42)
		var w := rng.randf_range(5, 12)
		var d := rng.randf_range(5, 12)
		_box(self, Vector3(x, h * 0.5 - 0.4, z), Vector3(w, h, d), "concrete_dark")
		for floor in range(int(h / 3.6)):
			for dx in [-0.30, 0.30]:
				if rng.randf() < 0.27:
					continue
				_box(self, Vector3(x + w * dx, 2.6 + floor * 3.6, z + d * 0.51), Vector3(1.25, 1.9, 0.1), "black")
		for j in range(3):
			_box(self, Vector3(x + rng.randf_range(-w / 2, w / 2), h + rng.randf_range(-1, 1), z), Vector3(rng.randf_range(1, 2), rng.randf_range(0.3, 1.4), d * 0.8), "concrete")

func _vehicles() -> void:
	_car(Vector3(3.3, 0.45, -38), 0.27, "car_red")
	_car(Vector3(-1.8, 0.45, 32), -0.38, "car_cream")
	_car(Vector3(-7.5, 0.45, 8), 1.7, "paint")
	_car(Vector3(11.5, 0.45, -7), -1.1, "rust")
	# Wrecked bus / caravan silhouette.
	var bus := Node3D.new()
	bus.position = Vector3(10.5, 1.4, -51)
	bus.rotation.y = 0.12
	add_child(bus)
	_box(bus, Vector3.ZERO, Vector3(3.4, 2.8, 11), "rust")
	_box(bus, Vector3(0, 1.52, 0), Vector3(3.3, 0.2, 10.9), "ivory")
	for z in range(-4, 5, 2):
		for x in [-1.73, 1.73]:
			_box(bus, Vector3(x, 0.45, z), Vector3(0.08, 0.96, 1.2), "glass")
	for z in [-3.9, 3.9]:
		for x in [-1.65, 1.65]:
			var tire := _cylinder(bus, Vector3(x, -1.1, z), 0.82, 0.3, "black")
			tire.rotation.z = PI / 2.0
	_label(bus, "EVAC 04", Vector3(0, 0.7, 5.61), Color("#ded0a8"), 38)

func _car(pos: Vector3, yaw: float, paint: String) -> void:
	var car := Node3D.new()
	car.position = pos
	car.rotation.y = yaw
	car.name = "Abandoned vehicle"
	add_child(car)
	_box(car, Vector3(0, 0.45, 0), Vector3(2.5, 0.55, 5.6), paint)
	_box(car, Vector3(0, 0.82, 0.65), Vector3(2.35, 0.2, 2.2), "metal")
	_box(car, Vector3(0, 1.38, 0.65), Vector3(2.12, 0.84, 2.9), paint)
	_box(car, Vector3(0, 1.81, 0.7), Vector3(2, 0.11, 2.6), "rust")
	for z in [-0.72, 1.78]:
		_box(car, Vector3(0, 1.35, z), Vector3(1.9, 0.74, 0.07), "glass")
	for x in [-1.08, 1.08]:
		_box(car, Vector3(x, 1.35, 0.7), Vector3(0.08, 0.72, 2.15), "glass2")
		for z in [-1.75, 1.85]:
			var tire := _cylinder(car, Vector3(x * 1.15, 0.05, z), 0.57, 0.3, "black")
			tire.rotation.z = PI / 2
			var hub := _cylinder(car, Vector3(x * 1.33, 0.05, z), 0.24, 0.32, "metal")
			hub.rotation.z = PI / 2
	_box(car, Vector3(0, 0.48, 2.87), Vector3(2.35, 0.18, 0.25), "metal")
	for x in [-0.84, 0.84]:
		_box(car, Vector3(x, 0.62, -2.87), Vector3(0.4, 0.21, 0.08), "warm_glow")
		_box(car, Vector3(x, 0.62, 2.87), Vector3(0.38, 0.2, 0.08), "rust_light")

func _barrel(parent: Node3D, p: Vector3) -> void:
	_cylinder(parent, p, 0.42, 0.75, "rust")
	_cylinder(parent, p + Vector3(0, 0.35, 0), 0.44, 0.08, "metal")
	_cylinder(parent, p - Vector3(0, 0.35, 0), 0.44, 0.08, "dark_metal")

func _rock(p: Vector3, scale_size: float, key: String) -> void:
	var rock := MeshInstance3D.new()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var angles := 7
	var center := Vector3(0, scale_size * 0.32, 0)
	var ring: Array[Vector3] = []
	for j in range(angles):
		var a := TAU * float(j) / float(angles)
		ring.append(Vector3(cos(a) * scale_size * rng.randf_range(0.6, 1.0), 0, sin(a) * scale_size * rng.randf_range(0.5, 1.0)))
	for j in range(angles):
		var top := center + Vector3(rng.randf_range(-0.2, 0.2), scale_size * rng.randf_range(0.45, 0.85), rng.randf_range(-0.2, 0.2))
		for v in [ring[j], ring[(j + 1) % angles], top]:
			st.add_vertex(v)
	st.generate_normals()
	rock.mesh = st.commit()
	rock.material_override = materials[key]
	rock.position = p
	add_child(rock)

func _details() -> void:
	# Wispy, wind-shaped dead scrub in clumps.
	for i in range(180):
		var x := rng.randf_range(-65, 65)
		var z := rng.randf_range(-70, 55)
		if absf(x) < 5.8:
			continue
		var center := Vector3(x, 0.08, z)
		_shrub(center, rng.randf_range(0.35, 1.1))
	# Air-con units and rooftop clutter give an industrial silhouette.
	for i in range(26):
		var x := rng.randf_range(-48, 48)
		var z := rng.randf_range(-70, 55)
		if rng.randf() > 0.6:
			_rock(Vector3(x, 0.1, z), rng.randf_range(0.4, 1.6), "rock")
	for i in range(9):
		var x := -10.0 if i % 2 == 0 else 10.0
		var z := 28.0 - i * 11.0
		_rod(self, Vector3(x, 0.0, z), Vector3(x, 7.0, z), 0.12, "rust")
		_rod(self, Vector3(x - 0.9, 6.7, z), Vector3(x + 0.9, 6.7, z), 0.07, "metal")
		if i < 8:
			var nx := 10.0 if i % 2 == 0 else -10.0
			var nz := z - 11.0
			_rod(self, Vector3(x, 6.5, z), Vector3(nx, 5.2, nz), 0.023, "black")

func _shrub(p: Vector3, s: float) -> void:
	var n := rng.randi_range(3, 6)
	for i in range(n):
		var v := Vector3(rng.randf_range(-0.8, 0.8), rng.randf_range(0.4, 1.4), rng.randf_range(-0.8, 0.8)) * s
		_rod(self, p, p + v, 0.015 * s, "plant" if i % 2 == 0 else "plant2")

func _lighting() -> void:
	var env := WorldEnvironment.new()
	env.name = "Sirocco / dusk atmosphere"
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#394e55")
	sky_material.sky_horizon_color = Color("#d09b6c")
	sky_material.ground_bottom_color = Color("#4a3e37")
	sky_material.ground_horizon_color = Color("#ad9276")
	sky_material.sun_angle_max = 20.0
	sky.sky_material = sky_material
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("#c8a98c")
	e.ambient_light_energy = 0.82
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_light_color = Color("#ae9379")
	e.fog_density = 0.009
	e.fog_aerial_perspective = 0.4
	env.environment = e
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.name = "Low amber sun"
	sun.rotation_degrees = Vector3(-28, -48, 0)
	sun.light_color = Color("#ffcb91")
	sun.light_energy = 1.35
	sun.shadow_enabled = not DisplayServer.is_touchscreen_available() # Desktop depth, mobile fallback.
	add_child(sun)
	var neon := OmniLight3D.new()
	neon.position = Vector3(-6, 4.5, -18)
	neon.light_color = Color("#b5ce82")
	neon.light_energy = 0.75
	neon.omni_range = 8
	neon.shadow_enabled = false
	add_child(neon)

extends CharacterBody3D

signal position_changed(position: Vector3)

const WALK_SPEED := 5.1
const SPRINT_SPEED := 8.4
const CROUCH_SPEED := 2.8
const GRAVITY := 18.0

var active: bool = false
var pitch: float = 0.0
var camera: Camera3D
var head: Node3D
var bob: float = 0.0
var touch_axis := Vector2.ZERO
var touch_running := false
var body_height := 1.6
var initial_head_y := 1.6

func _ready() -> void:
	name = "Wanderer"
	var shape := CapsuleShape3D.new()
	shape.radius = 0.31
	shape.height = 1.8
	var hitbox := CollisionShape3D.new()
	hitbox.shape = shape
	hitbox.position.y = 0.94
	add_child(hitbox)
	head = Node3D.new()
	head.name = "Head"
	head.position.y = initial_head_y
	add_child(head)
	camera = Camera3D.new()
	camera.name = "PlayerCamera"
	camera.fov = GameState.fov
	camera.current = false
	camera.near = 0.06
	camera.far = 190.0
	head.add_child(camera)

func set_active(value: bool) -> void:
	active = value
	set_physics_process(value)
	camera.current = value
	if value and not DisplayServer.is_touchscreen_available():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look(event.relative * GameState.sensitivity)
	if event is InputEventScreenDrag:
		var half := get_viewport().get_visible_rect().size.x * 0.48
		if event.position.x > half:
			_look(event.relative * GameState.sensitivity * 1.3)

func _look(delta: Vector2) -> void:
	rotation_degrees.y -= delta.x
	pitch = clampf(pitch - delta.y, -84.0, 84.0)
	head.rotation_degrees.x = pitch

func _physics_process(delta: float) -> void:
	if not active:
		return
	var axis := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if touch_axis.length() > axis.length():
		axis = touch_axis
	var speed := WALK_SPEED
	var running := Input.is_action_pressed("sprint") or touch_running
	if running:
		speed = SPRINT_SPEED
	var crouching := Input.is_action_pressed("crouch")
	if crouching:
		speed = CROUCH_SPEED
	var direction := (transform.basis * Vector3(axis.x, 0, axis.y)).normalized()
	velocity.x = move_toward(velocity.x, direction.x * speed, 16.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, 16.0 * delta)
	if is_on_floor():
		if Input.is_action_just_pressed("jump") and not crouching:
			velocity.y = 6.6
	else:
		velocity.y -= GRAVITY * delta
	move_and_slide()
	var target_y := 1.14 if crouching else initial_head_y
	bob += delta * (12.0 if running else 8.2) * axis.length()
	var bob_offset := sin(bob) * 0.035 * axis.length() if is_on_floor() else 0.0
	head.position.y = lerpf(head.position.y, target_y + bob_offset, minf(1.0, delta * 9))
	camera.fov = lerpf(camera.fov, GameState.fov + (4 if running else 0), minf(1.0, delta * 5))
	position_changed.emit(global_position)

func restore(data: Dictionary) -> void:
	if data.has("position"):
		var p: Vector3 = data["position"]
		# Reject corrupt or ancient coordinates outside the playable test sector.
		if p.length() < 220.0 and p.y > -10 and p.y < 80:
			position = p
	rotation_degrees.y = float(data.get("yaw", 0))
	pitch = clampf(float(data.get("pitch", 0)), -84, 84)
	if head != null:
		head.rotation_degrees.x = pitch

class_name Movement

extends CharacterBody3D

signal landed

@export var speed : float = 5.0
@export var gravity : float = -9.0
@export var jump_force : float = 4.0
@export var can_move : bool = true
@export var mouse_sensitivity : float = 1.0
@export var camera_node : Node3D
@export var lerp_speed : float = 0.235
@export var sprint_speed : float = 8.0
@export var max_sprint_duration : float = 1.25
@export var walk_speed : float = 2.85
@export var noise_emitter : NoiseEmitter

var move : Vector3
var is_grounded : bool
var direction = Vector3.ZERO
var wasd_input : Vector2 = Vector2.ZERO
var rotate_y_degrees : float = 0.0
var _sprint_progression : float = 0.0

static var yoinkable_camera : Node3D
static var singleton : Movement

var _last_frame_on_floor := false
var _dodge_charge : float = 1.0

const SPRINT_RECHARGE_MULTIPLIER : float = 1.10
const SPICY_FALL_EXTRA_MULTIPLIER : float = 2

func _ready():
	singleton = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.use_accumulated_input = false
	yoinkable_camera = camera_node
	
func _input(event):
	if not can_move: return
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("jump") and is_on_floor():
			_jump()
	if event is InputEventMouseMotion and abs(event.screen_relative.x) > 0.1:
		rotate_y(-event.screen_relative.x * mouse_sensitivity / 240)
		rotate_y_degrees = rad_to_deg((-event.screen_relative.x * mouse_sensitivity / 240))
	if event is InputEventMouseMotion and abs(event.screen_relative.y) > 0.1:
		camera_node.rotate_x(-event.screen_relative.y * mouse_sensitivity / 240)
	camera_node.rotation.x = clampf(camera_node.rotation.x, -PI/2, PI/2)

func _physics_process(delta : float) -> void:
	#DEBUG
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	if _dodge_charge <= 1.0:
		_dodge_charge += delta
	
	if not _last_frame_on_floor and is_on_floor() and Time2.time > 3.0:
		noise_emitter.emit_noise(8.0)
		landed.emit()
		
	_last_frame_on_floor = is_on_floor()
	
	var wasd_raw_input :Vector2 = Vector2()
	wasd_raw_input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	wasd_raw_input.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	wasd_input.x = lerp(wasd_input.x, wasd_raw_input.x, lerp_speed)
	wasd_input.y = lerp(wasd_input.y, wasd_raw_input.y, lerp_speed)

	if not can_move: return
	
	
	direction.x = wasd_input.x
	direction.z = wasd_input.y
	
	direction = direction.normalized() * direction.length()
	
	# Convert from local space to world space
	direction = transform.basis * direction
	
	var applied_speed : float = speed
	if Input.is_action_pressed("sprint") and _sprint_progression < max_sprint_duration:
		applied_speed = sprint_speed
		_sprint_progression += delta
		noise_emitter.emit_noise(6.0)
		Vignette.singleton.set_intensity(0.0)
	if not Input.is_action_pressed("sprint") and _sprint_progression > 0:
		_sprint_progression -= delta * SPRINT_RECHARGE_MULTIPLIER
		_sprint_progression = maxf(0.0, _sprint_progression)
		
	if Input.is_action_pressed("walk"):
		applied_speed = walk_speed
		noise_emitter.emit_noise(2.0)
		Vignette.singleton.set_intensity(1.0)
		
	if applied_speed == speed:
		if wasd_input.length() > .15:
			noise_emitter.emit_noise(3.5)
		Vignette.singleton.set_intensity(0.52)
		
	if is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * applied_speed, 0.2)
		velocity.z = lerp(velocity.z, direction.z * applied_speed, 0.2)
	else:
		velocity.x = lerp(velocity.x, direction.x * applied_speed, 0.03)
		velocity.z = lerp(velocity.z, direction.z * applied_speed, 0.03)
	if not is_on_floor():
		velocity.y += gravity * delta * (1.0 if velocity.y > 0.0 else SPICY_FALL_EXTRA_MULTIPLIER)
	
	move_and_slide()

	var n  : int = get_slide_collision_count()
	for i in range(n):
		var collision : KinematicCollision3D = get_slide_collision(i)
		var avg_vel : Vector3 = Vector3.ZERO
		for k in range(collision.get_collision_count()):
			avg_vel+=abs(collision.get_collider_velocity(k))
		avg_vel += abs(velocity) + direction * applied_speed
		avg_vel /= collision.get_collision_count()
		for k in range(collision.get_collision_count()):
			var physobj : Node3D = collision.get_collider(k) as Node3D
			var force = (physobj.global_position - collision.get_position(k)).normalized() * avg_vel
			force += Vector3(0,1,0)
			force *= 3
			if physobj.has_method("apply_force"):
				physobj.apply_force(force)
				apply_force(-force)
			if physobj.get_parent().has_method("apply_force"):
				physobj.get_parent().apply_force(force)
				apply_force(-force)

const FORCE_COOLDOWN : float = 0.4
var last_force : float = 0.0
func apply_force(force : Vector3):
	if last_force + FORCE_COOLDOWN <= Time2.time:
		last_force = Time2.time
		print(force)
		force.y = abs(force.y)
		velocity += force

func _jump():
	velocity.y = jump_force
	
func take_damage(_e = null):
	pass

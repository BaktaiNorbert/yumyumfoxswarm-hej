extends CharacterBody3D

enum BehaviourState {
	Calm,
	Alert,
	Engaging,
	Attacking
}

@export var speed : float = 128.0

var _state : BehaviourState = BehaviourState.Calm

var _chase : bool = false
@export var agent : NavigationAgent3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_state = BehaviourState.Calm

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match _state:
		BehaviourState.Calm:
			_chase = false
		BehaviourState.Alert:
			_chase = true
	if _chase:
		if not agent.is_target_reached() and agent.is_target_reachable():
			_move_to(agent.get_next_path_position(), delta)
	
	_update_look_direction()
	
	if not is_on_floor():
		velocity.y += Movement.singleton.gravity * delta * (1.0 if velocity.y > 0.0 else Movement.SPICY_FALL_EXTRA_MULTIPLIER)
func alarm(e):
	print("alarmed")
	agent.target_position = e.global_position
	_state = BehaviourState.Alert
	
func _move_to(pos : Vector3, delta : float):
	var dir : Vector3 = (pos - global_position).normalized()
	#global_position += dir * speed * delta
	velocity = lerp(velocity,dir * speed * delta,0.15)
	#velocity.y = - 10
	move_and_slide()
	
func _update_look_direction():
	look_at(Movement.singleton.global_position)
	rotation_degrees = rotation_degrees * Vector3(0,1,0) + Vector3(0,180,0)

const FORCE_COOLDOWN : float = 0.4
var last_force : float = 0.0
func apply_force(force : Vector3):
	if last_force + FORCE_COOLDOWN <= Time2.time:
		last_force = Time2.time
		force.y = abs(force.y)
		velocity += force

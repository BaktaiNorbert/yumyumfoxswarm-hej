class_name Shaker

extends Node3D

@export var decay_speed: float = 5.0          # How fast shake fades
@export var max_rotation_deg: float = 5.0     # Maximum rotation shake
@export var max_position_offset: float = 10.0 # Maximum position shake (pixels or units)
@export var noise_speed: float = 20.0         # How fast the noise moves

var _intensity: float = 0.0
var _noise := FastNoiseLite.new()
var _time: float = 0.0

var _original_position: Vector3
var _original_rotation: Vector3

static var singleton : Shaker

func _ready():
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = 1.0
	if self is Node3D:
		_original_position = self.position
		_original_rotation = self.rotation
	singleton = self

func shake(intensity: float) -> void:
	_intensity = max(_intensity, intensity)

func _process(delta: float) -> void:
	if _intensity <= 0.001:
		_reset()
		return
	
	_time += delta * noise_speed
	
	var noise_x = _noise.get_noise_1d(_time)
	var noise_y = _noise.get_noise_1d(_time + 100.0)
	var noise_rot = _noise.get_noise_1d(_time + 200.0)
	
	var rot_amount = deg_to_rad(max_rotation_deg) * _intensity
	var pos_amount = max_position_offset * _intensity
	
	if self is Node3D:
		var extra_rot_noise : Vector3 = Vector3(
			noise_x * rot_amount,
			noise_y * rot_amount,
			noise_rot * rot_amount
		)
		self.rotation = _original_rotation + extra_rot_noise
		self.position = _original_position + Vector3(
			noise_x * pos_amount * 0.2,
			noise_y * pos_amount * 0.2,
			0
		)
	
	_intensity = lerp(_intensity, 0.0, decay_speed * delta)

func _reset():
	if self is Node3D:
		self.position = _original_position
		self.rotation = _original_rotation

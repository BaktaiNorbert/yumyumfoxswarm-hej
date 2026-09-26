class_name NoiseEmitter extends ShapeCast3D

const UPDATE_LIMIT : float = 0.15

var _last_radius : float = 0.0
var _last_time : float = 0.0

func emit_noise(radius : float = -1.0):
	if not is_colliding():
		return
	if Time2.time < _last_time + UPDATE_LIMIT and _last_radius >= radius:
		return
	_last_time = Time2.time
	_last_radius = radius
	if radius >= 0:
		shape = SphereShape3D.new()
		shape.radius = radius
	for i in range(get_collision_count()):
		var c = get_collider(i)
		if (c.get_parent() as Node3D).has_method("alarm"):
			c.get_parent().alarm()

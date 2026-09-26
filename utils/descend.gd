extends RayCast3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_self_check")

func _self_check():
	if is_colliding():
		get_parent().global_position.y = get_collision_point().y
	#	(get_parent() as Node3D).transform.looking_at(get_parent().global_position+get_collision_normal()*5)
	else:
		print("krilling myself")
		get_parent().queue_free()

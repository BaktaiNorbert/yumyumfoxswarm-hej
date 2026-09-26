extends Node3D

@export var tree : PackedScene

@export var grid_size : Vector2i = Vector2i(50,50)
@export var tile_size : float = 4.0
@export var random_deviance_off_grid : float = 5.0

@export var spawn_chance = 0.06

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(grid_size.x):
		for k in range(grid_size.y):
			if randf() <= spawn_chance:
				_spawn(i,k)
				
func _spawn(i : int, k : int):
	var i_tree : Node3D = tree.instantiate() as Node3D
	i_tree.position = Vector3(i,0,k)*tile_size + Vector3((randf()*2-1)*random_deviance_off_grid, -0.5, (randf()*2-1)*random_deviance_off_grid)
	i_tree.rotate_y(PI*2*randf())
	i_tree.scale = Vector3.ONE * randf_range(3.5,4.7)
	add_child(i_tree)

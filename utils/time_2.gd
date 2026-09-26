class_name Time2

extends Node

static var time : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta

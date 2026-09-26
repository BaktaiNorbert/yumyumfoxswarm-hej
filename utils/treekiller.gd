extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(func(b): if b.get_parent() is Tree2: b.get_parent().queue_free())

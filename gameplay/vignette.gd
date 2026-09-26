class_name Vignette extends ColorRect

static var singleton : Vignette

func _ready() -> void:
	singleton = self

func set_intensity(v : float):
	var _v_v = (material as ShaderMaterial).get_shader_parameter("softness")
	(material as ShaderMaterial).set_shader_parameter("softness",lerp(_v_v,v, .2))

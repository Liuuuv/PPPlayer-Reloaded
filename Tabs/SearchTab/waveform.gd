extends ColorRect

var tween_duration: float = 1.1

func appear():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "material:shader_parameter/progress", 1.0, tween_duration / 2)
	

func disappear():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_property(self, "material:shader_parameter/progress", 0.0, tween_duration)

extends ColorRect
class_name ScreenFlash

var time = 1.0

func _ready():
	flash(time)

func flash(duration: float):
	show()
	var tween = get_tree().create_tween()
	tween.tween_property(material, 'shader_parameter/alpha_percentage', 1.0, duration).set_ease(Tween.EASE_IN)
	await tween.finished
	tween = get_tree().create_tween()
	tween.tween_property(material, 'shader_parameter/alpha_percentage', 0.0, 0.1)
	await tween.finished
	queue_free()

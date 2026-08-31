@tool
extends TransitionAnimation

func reset():
	%ColorRect.modulate = Color(0.906, 0.776, 0.604, 0.0)

func play_animation_close():
	var tween = get_tree().create_tween()
	tween.tween_property(%ColorRect, 'modulate', Color(0.906, 0.776, 0.604), shutter_time/3)
	await tween.finished

func play_animation_open():
	var tween = get_tree().create_tween()
	tween.tween_property(%ColorRect, 'modulate', Color(0.906, 0.776, 0.604, 0.0), shutter_time)
	await tween.finished

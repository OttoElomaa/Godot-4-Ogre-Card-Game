@tool
@icon('uid://dn375kq0xtb1')
extends CanvasLayer
class_name TransitionAnimation

## How long does the animation take.
@export var shutter_time:float
@export var wait_time: float
@export_tool_button('Play close animation') var test_button_1 = play_animation_close
@export_tool_button('Play open animation') var test_button_2 = play_animation_open
var playing = false

func _ready():
	reset()

func reset():
	$TransitionLeft.size.x = 0
	$TransitionRight.size.x = 0
	$TransitionRight.position.x = get_viewport().get_visible_rect().size.x

func play_animation_close():
	var tween = get_tree().create_tween()
	var screen_width = get_viewport().get_visible_rect().size
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($TransitionLeft, 'size', Vector2(screen_width.x / 2, $TransitionLeft.size.y), shutter_time)
	tween.parallel().tween_property($TransitionRight, 'size', Vector2(screen_width.x / 2, $TransitionRight.size.y), shutter_time)
	tween.parallel().tween_property($TransitionRight, 'position', $TransitionRight.position - Vector2(screen_width.x / 2, 0), shutter_time)
	await tween.finished
	await get_tree().create_timer(wait_time).timeout

func play_animation_open():
	var tween = get_tree().create_tween()
	var screen_width = get_viewport().get_visible_rect().size
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($TransitionLeft, 'size', Vector2(0, $TransitionLeft.size.y), shutter_time).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($TransitionRight, 'size', Vector2(0, $TransitionRight.size.y), shutter_time)
	tween.parallel().tween_property($TransitionRight, 'position', Vector2(screen_width.x, 0), shutter_time)
	await tween.finished

extends CardContainer

var dragged = false
var offset: Vector2

func _on_gui_input(event:InputEvent):
	if event.is_action_pressed("LMB"):
		var tween = get_tree().create_tween()
		offset = get_global_mouse_position() - global_position
		tween.tween_property(self, 'scale', Vector2(2.05, 2.05), 0.1)
		z_index = 2
		dragged = true
		%CardShadow.show()
		$PickedUp.play()
	if event.is_action_released("LMB"):
		var tween = get_tree().create_tween()
		dragged = false
		tween.tween_property(self, 'scale', Vector2(2, 2), 0.1)
		z_index = 0
		get_parent().put_on_top()
		$PutDown.play()
		%CardShadow.hide()

func _physics_process(delta):
	if dragged:
		global_position = get_global_mouse_position() - offset

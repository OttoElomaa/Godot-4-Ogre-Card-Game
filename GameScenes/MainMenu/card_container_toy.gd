extends CardContainer

var dragged = false
var offset: Vector2

func _on_gui_input(event:InputEvent):
	if event.is_action_pressed("LMB"):
		offset = get_global_mouse_position() - global_position
		scale = Vector2(2.05, 2.05)
		z_index = 2
		dragged = true
		$PickedUp.play()
	if event.is_action_released("LMB"):
		dragged = false
		scale = Vector2(2, 2)
		z_index = 0
		get_parent().put_on_top()
		$PutDown.play()

func _physics_process(delta):
	if dragged:
		global_position = get_global_mouse_position() - offset

extends BestiaryContainer

func _get_drag_data(at_position):
	var data = [card, false]
	var drag_prev = self.duplicate()
	drag_prev.z_index = 5
	set_drag_preview(drag_prev)
	%PickUp.play()
	return data

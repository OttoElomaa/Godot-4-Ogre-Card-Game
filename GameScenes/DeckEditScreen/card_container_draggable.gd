extends CardContainer

var infoPanel = null

func _get_drag_data(at_position):
	var data = [card, false]
	var drag_prev = self.duplicate()
	drag_prev.z_index = 5
	set_drag_preview(drag_prev)
	
	return data

func _on_mouse_entered():
	infoPanel.toggleCardInfo(true, card)

func _on_mouse_exited():
	infoPanel.toggleCardInfo(false, null)

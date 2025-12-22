extends CardContainer

var infoPanel = null

func _get_drag_data(at_position):
	var data = [card, false]
	set_drag_preview(self.duplicate())
	
	return data

func _on_mouse_entered():
	infoPanel.toggleCardInfo(true, card)

func _on_mouse_exited():
	infoPanel.toggleCardInfo(false, null)

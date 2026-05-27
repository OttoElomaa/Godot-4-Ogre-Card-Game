extends CardContainer

var infoPanel = null

func _get_drag_data(at_position):
	var data = [card, false]
	var drag_prev = self.duplicate()
	drag_prev.z_index = 5
	set_drag_preview(drag_prev)
	%PickUp.play()
	return data

func _on_mouse_entered():
	if infoPanel.has_method('show_at'):
		$InfoPanelTimer.start(0.5)
	else:
		infoPanel.toggleCardInfo(true, card)


func _on_mouse_exited():
	infoPanel.toggleCardInfo(false, null)
	$InfoPanelTimer.stop()

func _on_info_panel_timer_timeout():
	
	infoPanel.toggleCardInfo(true, card)
	infoPanel.show_at(global_position)

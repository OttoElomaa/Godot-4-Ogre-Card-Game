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
	if not infoPanel:
		return
	if infoPanel.has_method('show_at'):
		$InfoPanelTimer.start(0.5)
	else:
		infoPanel.toggleCardInfo(true, card)


func _on_mouse_exited():
	if not infoPanel:
		return
	
	#### IF THE MOUSE IS STILL ON TOP OF THIS ELEMENT - even if there's OTHER ELEMENTS ON TOP, DON'T HIDE	
	##if get_global_rect().has_point(get_global_mouse_position()):
		#return
		
	infoPanel.toggleCardInfo(false, null)
	$InfoPanelTimer.stop()

func _on_info_panel_timer_timeout():
	
	infoPanel.toggleCardInfo(true, card)
	infoPanel.show_at(global_position)

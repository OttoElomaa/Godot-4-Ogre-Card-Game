extends CardContainer
class_name BestiaryContainer

var infoPanel = null

func _on_mouse_entered():
	if infoPanel.has_method('show_at'):
		$InfoPanelTimer.start(3.0)
	else:
		infoPanel.toggleCardInfo(true, card)

func _on_mouse_exited():
	if infoPanel.has_method('show_at'):
		$InfoPanelTimer.stop()
	infoPanel.toggleCardInfo(false, null)
	


func _on_info_panel_timer_timeout():
	infoPanel.toggleCardInfo(true, card)
	infoPanel.show_at(global_position)

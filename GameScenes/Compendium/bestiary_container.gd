extends CardContainer

var infoPanel = null

func _on_mouse_entered():
	infoPanel.toggleCardInfo(true, card)

func _on_mouse_exited():
	infoPanel.toggleCardInfo(false, card)

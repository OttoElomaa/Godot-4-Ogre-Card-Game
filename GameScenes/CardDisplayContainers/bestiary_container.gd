extends CardContainer
class_name  BestiaryContainer

var infoPanel = null

func _on_mouse_entered():
	if infoPanel:
		infoPanel.toggleCardInfo(true, card)

func _on_mouse_exited():
	if infoPanel:
		infoPanel.toggleCardInfo(false, card)

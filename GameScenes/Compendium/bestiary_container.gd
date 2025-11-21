extends CardContainer

func _on_mouse_entered():
	get_parent().card_mouse_entered.emit(card)


func _on_mouse_exited():
	get_parent().card_mouse_exited.emit()

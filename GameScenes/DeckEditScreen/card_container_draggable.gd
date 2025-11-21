extends CardContainer

func _get_drag_data(at_position):
	var data = [card, false]
	set_drag_preview(self.duplicate())
	
	return data

func _on_mouse_entered():
	get_parent().card_mouse_entered.emit(card)


func _on_mouse_exited():
	get_parent().card_mouse_exited.emit()

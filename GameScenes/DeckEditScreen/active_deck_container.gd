extends VBoxContainer

signal updated
signal card_mouse_entered(card:Card)
signal card_mouse_exited


func _can_drop_data(at_position, data):
	return !data[1]
	
func _drop_data(at_position, data):
	var card = data[0]
	var active = data[1]
	if not active:
		print('dropping ', card.cardName)
		GameInfo.playerOwnedCards.erase(card)
		GameInfo.playerDeckCards.append(card)
		updated.emit()

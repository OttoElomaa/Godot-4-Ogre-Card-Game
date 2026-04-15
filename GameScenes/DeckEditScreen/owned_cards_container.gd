extends GridContainer

signal updated
signal card_mouse_entered(card)
signal card_mouse_exited

func _can_drop_data(at_position, data):
	return data[1]

func _drop_data(at_position, data):
	var card = data[0]
	var active = data[1]
	if active:
		print('dropping ', card.cardName)
		GameInfo.playerDeckCards.erase(card)
		GameInfo.playerOwnedCards.append(card)
	updated.emit()
	%PutDown.play()

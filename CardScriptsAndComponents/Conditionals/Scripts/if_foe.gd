extends ConditionalComponent

func check(card:Card, myCard:Card):
	if card.isEnemyCard != myCard.isEnemyCard:
		return true
	else:
		return false

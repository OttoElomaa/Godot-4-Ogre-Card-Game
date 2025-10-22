extends ConditionalComponent

func check(card:Card, myCard:Card):
	return card.isEnemyCard != myCard.isEnemyCard

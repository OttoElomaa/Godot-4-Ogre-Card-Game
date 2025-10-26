extends Skill

func activate(targets) -> bool:
	for card:Card in targets:
		MyTools.addCardToGraveyard(card, card.isEnemyCard)
	return true

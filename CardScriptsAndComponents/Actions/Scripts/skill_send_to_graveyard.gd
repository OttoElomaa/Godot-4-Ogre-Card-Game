extends Skill

func activate(targets) -> bool:
	for card:Card in targets:
		card.destroyAndAnimate(true)
		#MyTools.addCardToGraveyard(card, card.isEnemyCard)
	return true

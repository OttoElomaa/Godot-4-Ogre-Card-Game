extends Skill

## 1 argument. 0: the card to shuffle
func activate(targets):
	for card:Card in targets:
		MyTools.shuffleToDeck(card, card.isEnemyCard)
	return true

func createText():
	return "Card shuffled to deck"

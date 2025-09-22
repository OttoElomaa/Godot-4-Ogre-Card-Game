extends Skill

## 1 argument. 0: the card to shuffle
func activate(targets):
	for card:Card in targets:
		MyTools.handleShuffleToDeck(card)
	return true

func createText():
	return "Card shuffled to deck"

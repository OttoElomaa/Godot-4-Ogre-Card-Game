extends ConditionalComponent

func check(card:Card, myCard:Card):
	return not card.checkCanBlock()

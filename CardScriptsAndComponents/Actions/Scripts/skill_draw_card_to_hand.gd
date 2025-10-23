extends Skill

@export var repeat_times: int = 1

func activate(targets:Array):
	for i in range(repeat_times):
		var card: Card = null
		if targets.size() > 0:
			card = targets[0]
		else:
			return false
		MyTools.addCardToHand(card, myCard.isEnemyCard)
		MyTools.createCombatLogPrintout(str('Drew ', card.cardName), Color('DARK_SALMON'))
		targets.pop_front()
	return true

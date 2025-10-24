extends Skill

@export var repeat_times: int = 1

func activate(targets:Array):
	#### DRAW CARDS X TIMES
	for i in range(repeat_times):
		
		#### NO CARDS FOUND, CAN'T DRAW
		if targets.is_empty():
			return false
			
		#### ADD CARD TO HAND, THEN REMOVE IT FROM ARRAY, So it's not selected multiple times 
		var card:Card = targets[0]
		MyTools.addCardToHand(card, myCard.isEnemyCard)
		MyTools.createCombatLogPrintout(str('Drew ', card.cardName), Color('DARK_SALMON'))
		targets.pop_front()
			
	return true

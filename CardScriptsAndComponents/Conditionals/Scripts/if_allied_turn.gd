extends ConditionalComponent

func check(card, condition):
	condition = GameInfo.enemy_turn
	print(name, ' is checking')
	if card is Card:
		if card.isEnemyCard == condition:
			passed = true
			print(name, ' is true')
		else:
			passed = false
			print(name, ' is false')
		return passed

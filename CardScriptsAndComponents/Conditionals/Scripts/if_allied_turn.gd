extends ConditionalComponent

func check(card:Card, _condition):
	print(name, ' is checking')
	return card.isEnemyCard == GameInfo.enemy_turn

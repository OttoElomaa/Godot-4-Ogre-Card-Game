extends ConditionalComponent

#### CHECK: IS IT THIS CARD'S ALLIED TURN?
func check(card:Card, myCard:Card):
	var success := myCard.isEnemyCard == GameInfo.enemy_turn
	print("%s is checking. Success: %s" % [name, success])
	return success

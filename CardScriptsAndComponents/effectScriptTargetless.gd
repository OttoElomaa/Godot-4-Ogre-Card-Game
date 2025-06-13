extends EffectScript





func activateTargetless():
	var success := false
	
	########################################## TARGETLESS EFFECTS
	#### CARD DRAW
	if drawCards > 0:
		for i in range(drawCards):
			MyTools.handleDrawCard(isEnemy)
		success = true
	
	#### SUMMON
	if summonScene:
		var creature:Card = summonScene.instantiate()
		add_child(creature)   #### TEMP PARENT TO TRIGGER _READY
		var slot:CardSlot = myEffectNode.findEmptySlot()
		if slot:
			MyTools.handlePlaceCardInSlot(creature, slot)
			MyTools.changeMana(creature.manaCost, isEnemy)
			success = true
	
	var targets:Array = MyTools.getBoardCards(isEnemy)
	if targetGroup == TargetOptions.ALLIES:
		if bolsterDamage > 0 or bolsterHealth > 0:
			for card in targets:
				if effectTypeLine == "":
					card.tempDamage += bolsterDamage
					card.tempHealth += bolsterHealth
					success = true
				elif effectTypeLine in card.subTypes:
					card.tempDamage += bolsterDamage
					card.tempHealth += bolsterHealth
					success = true
					
	return success

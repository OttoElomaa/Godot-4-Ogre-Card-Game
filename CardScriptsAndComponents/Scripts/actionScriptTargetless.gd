extends ActionScript



@export var modifyHealth := 0
@export var modifyMana := 0

@export var drawCards := 0

@export var summonScene: PackedScene = null
@export_multiline var summonString := "Summon a thing"





func createTextTwo() -> String:
	var text := ""
	
	
	#### HEALTH / MANA ALTERING
	if modifyHealth < 0:
		text += "Owner pays %s Health" % modifyHealth
	elif modifyHealth > 0:
		text += "Owner gains %s Health" % modifyHealth
		
	if modifyMana < 0:
		text += "Owner pays %s Mana" % modifyMana
	elif modifyMana > 0:
		text += "Owner gains %s Mana" % modifyMana
	
	
	#### CARD DRAW
	if drawCards > 0:
		text += "Draw %d" % drawCards
	
	#### ADD SUMMON
	if summonScene:
		text += summonString
	
	if phaseOut:
		text += "Phase out"
	
	return text



func activateTargetless(actor:Card):
	var success := false
		
	########################################## TARGETLESS EFFECTS
	
	#### MODIFY HEALTH/MANA
	if modifyHealth != 0:
		MyTools.changeHealth(modifyHealth, actor.isEnemyCard)
		success = true
	if modifyMana != 0:
		MyTools.changeMana(modifyMana, actor.isEnemyCard)
		success = true
	
	
	#### CARD DRAW
	if drawCards > 0:
		for i in range(drawCards):
			MyTools.handleDrawCard(isEnemy)
		success = true
	
	#### SUMMON
	if summonScene:
		var creature:Card = summonScene.instantiate()
		add_child(creature)   #### TEMP PARENT TO TRIGGER _READY
		
		
		
		var slots:Array = MyTools.findEmptyCardSlots(isEnemy)
		if not slots.is_empty():
			
			var slot = slots[0]
			MyTools.handlePlaceCardInSlot(creature, slot)
			MyTools.changeMana(creature.manaCost, isEnemy)
			success = true
	
	var targets:Array = MyTools.getBoardCards(isEnemy)
	if targetGroup == TargetOptions.ALLIES:
		
		#### BOLSTER ALLIES
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
	
	#### PHASE OUT SELF
	if phaseOut:
		myCard.effects.togglePhased(true)
		myCard.statesPassive()
					
	return success

extends Node

enum TargetOptions {NONE, ALLIES, ENEMIES}

enum SpecialConditions {NONE, ON_RITUAL, ON_CREATURE_ARRIVAL, ON_CREATURE_DEATH, ON_ALLY_DEATH, ON_ENEMY_DEATH}

var myCard: Card = null
var isEnemy := false

@export var nodeKeyword := "Action type"

@export var isActive := false
#@export var targetGroup := TargetOptions.NONE

#### ONLY FOR SPECIAL CONDITIONS NODE. STUFF LIKE,
#### ON RITUAL, ON CREATURE DEATH, ETC.
@export var specialCondition := SpecialConditions.NONE

#### TRIGGER TYPE: For example, ON ANOTHER 'RATFOLK' ENTERING...
@export var triggerTypeLine := "Card Type"
#### EFFECT TYPE: For example, BOLSTER ALL OTHER 'SPIRITS'...
@export var effectTypeLine := "Card Type"

@export var hasTap := false
@export var inflict := 0
@export var inflictPlayer := 0
@export var inflictCreature := 0

@export var bolstersAllAllies := false
@export var bolsterDamage := 0
@export var bolsterHealth := 0

@export var drawCards := 0

@export var summonScene: PackedScene = null
@export_multiline var summonString := "Summon a thing"




func createText() -> String:
	
	var text = ""
	if not isActive:
		return text
	
	#### ADD INFLICT
	if inflict > 0:
		text += "Inflict %d" % inflict
	elif inflictPlayer > 0:
		text += "Inflict Player %d" % inflictPlayer
	elif inflictCreature > 0:
		text += "Inflict Creature %d" % inflictCreature
	#text += ", "
	
	
	#### ADD BOLSTER
	if bolsterDamage > 0 or bolsterHealth > 0:
		#### ALL ALLIES
		if bolstersAllAllies:
			if effectTypeLine != "":
				text += "Bolster %s" % effectTypeLine
			else:
				text += "Bolster Allies"
				
		#### ONE ALLY - CAST ONLY? -> Needs Targeting
		else:
			if effectTypeLine != "":
				text += "Bolster Target %s" % effectTypeLine
			else:
				text += "Bolster"
			
		text += " %d/%d" % [bolsterDamage, bolsterHealth]
	
	#### ADD TAP
	if hasTap:
		text += "Tap target"
	
	#### CARD DRAW
	if drawCards > 0:
		text += "Draw %d" % drawCards
	
	#### ADD SUMMON
	if summonScene:
		text += summonString
	
	
	
	#### AT THE END, COMPILE TEXT
	if text != "":
		text = "%s: %s" % [nodeKeyword, text]
	
	text.rstrip(", ")
	return text



func checkActive():
	return isActive



func activate(target:Card) -> bool:
	if target:
		if target.checkAlive():
			return cast(target)
	else:
		return cast(null)
		
	return false



func cast(target:Card) -> bool:
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
		var slot:CardSlot = findEmptySlot()
		if slot:
			MyTools.handlePlaceCardInSlot(creature, slot)
			MyTools.changeMana(creature.manaCost, isEnemy)
			success = true
	
	var targets:Array = MyTools.getBoardCards(isEnemy)
	if bolstersAllAllies:
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
					
	
	#### END OF TARGETLESS STUFF
	if not target:
		return success
	
	######################################### TARGETED EFFECTS
	#### INFLICT
	if inflict > 0:
		target.tempHealth -= inflict
		target.health -= inflict
		success = true
	elif inflictCreature > 0:
		target.tempHealth -= inflictCreature
		target.health -= inflictCreature
		success = true
	
	#### BOLSTER
	if not bolstersAllAllies:
		if bolsterDamage > 0 or bolsterHealth > 0:
			target.tempDamage += bolsterDamage
			target.tempHealth += bolsterHealth
			success = true
	
	if hasTap:
		target.restAndAnimate(false)
		success = true
	
	target.updateCardLabels()
	if target.tempHealth <= 0:
		target.destroyAndAnimate(true)
	
	return success



func triggerConditionRitual():
	pass


func triggerConditionCreatureDeath():
	pass


func triggerConditionAllyDeath():
	pass	


func findEmptySlot() -> CardSlot:
	
	var slots:Array = MyTools.findEmptyCardSlots(isEnemy)
	
	if slots.is_empty():
		return null
	else:
		return slots[0]

extends Node

enum TargetOptions {NONE, ALLIES, ENEMIES}


var isEnemy := false

@export var nodeKeyword := "Action type"

@export var isActive := false
@export var targetGroup := TargetOptions.NONE


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
		if bolstersAllAllies:
			text += "Bolster Allies"
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
	if bolsterDamage > 0 or bolsterHealth > 0:
		target.tempDamage += bolsterDamage
		target.tempHealth += bolsterHealth
		success = true
	
	if hasTap:
		target.rest()
		success = true
	
	target.updateCardLabels()
	if target.tempHealth <= 0:
		target.destroyAndAnimate(true)
	
	return success



func findEmptySlot() -> CardSlot:
	
	var slots:Array = MyTools.findEmptyCardSlots(isEnemy)
	
	if slots.is_empty():
		return null
	else:
		return slots[0]

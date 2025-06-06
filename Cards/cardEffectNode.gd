extends Node

enum TargetOptions {NONE, ALLIES, ENEMIES}


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

var isEnemy := false



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
	
	if hasTap:
		text += "Tap target"
	
	#### AT THE END, COMPILE TEXT
	if text != "":
		text = "%s: %s" % [nodeKeyword, text]
	
	text.rstrip(", ")
	return text



func checkActive():
	return isActive



func activate(target:Card) -> bool:
	
	if target.checkAlive():
		return cast(target)
	return false



func cast(target:Card) -> bool:
	var success := false
	
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





func processPlayerBattleArt(target:Card):
	pass

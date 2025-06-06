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


func cast(target:Card) -> bool:
	
	if bolsterDamage > 0 or bolsterHealth > 0:
		target.tempDamage += bolsterDamage
		target.tempHealth += bolsterHealth
		target.updateCardLabels()
		return true
	
	if hasTap:
		target.rest()
	
	return false


func activate(target:Card) -> bool:
	
	if target.checkAlive():
		return cast(target)
	return false


func processPlayerBattleArt(target:Card):
	pass

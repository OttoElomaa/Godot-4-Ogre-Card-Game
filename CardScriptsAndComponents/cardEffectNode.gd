extends Node

enum TargetOptions {NONE, ALLIES, ENEMIES}

enum SpecialConditions {NONE, ON_RITUAL, ON_CREATURE_ARRIVAL, ON_CREATURE_DEATH, ON_ALLY_DEATH, ON_ENEMY_DEATH}

var myCard: Card = null
var isEnemy := false

@export var nodeKeyword := "Action type"





func createText() -> String:
	
	var text = ""
	for script in get_children():
		text += script.createText()
		text += ", "
	
	#### AT THE END, COMPILE TEXT
	text.rstrip(", ")
	if text != "":
		text = "%s: %s" % [nodeKeyword, text]	
	
	return text

func checkActive():
	
	if not get_children().is_empty():
		return true
	return false
	#return isActive



func activate(target:Card) -> bool:
	var success := false
	
	for script in get_children():
		if script.has_method("activateTargetless"):
			success = script.activateTargetless()
		elif target:
			if script.has_method("activateTargeted"):
				success = script.activateTargeted(target)
	
	return success






func findEmptySlot() -> CardSlot:
	
	var slots:Array = MyTools.findEmptyCardSlots(isEnemy)
	
	if slots.is_empty():
		return null
	else:
		return slots[0]

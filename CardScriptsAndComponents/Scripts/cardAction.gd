extends Node2D

enum TargetOptions {NONE, ALLIES, ENEMIES}

enum LocalSituations {
	NONE, ARRIVAL, CAST, BATTLE_ART, ON_TURN, RITUAL
}
enum GlobalSituations {
	NONE, ON_RITUAL, ON_CREATURE_ARRIVAL, ON_CREATURE_DEATH, ON_ALLY_DEATH, ON_ENEMY_DEATH
	}

var myCard: Card = null
var isEnemy := false

@export var localSituation := LocalSituations.NONE
@export var globalSituation := GlobalSituations.NONE

@export var nodeKeyword := "Action type"




func setup(card:Card):	
	myCard = card
	isEnemy = card.isEnemyCard
	
	for script in get_children():
		if script.has_method("setup"):
			script.setup(card)
	


func createActionText() -> String:
	var text := ""
	
	var situationStr:String = getSituationStr()
	
	for script in get_children():
		text += script.createText()
		text += ", "
	
	#### AT THE END, COMPILE TEXT
	text = text.rstrip(", ")
	if text != "":
		text = "%s: %s" % [situationStr, text]	
	
	return text



func activate(target:Card) -> bool:
	var success := false
	var successfulScript:Node = null
	
	for script in get_children():
		if script.has_method("activateTargetless"):
			success = script.activateTargetless(myCard)
			successfulScript = script
		elif target:
			if script.has_method("activateTargeted"):
				success = script.activateTargeted(target, myCard)
				successfulScript = script
	
	if success:
		successfulScript.createPrintout(self)  #### CREATE COMBAT LOG ENTRY
		#if not self == myCard.payoffNode:
			#myCard.payoffNode.activate(null)
	
		MyTools.updateBoardCardsVisuals()
		
	return success



func findEmptySlot() -> CardSlot:
	
	var slots:Array = MyTools.findEmptyCardSlots(isEnemy)
	
	if slots.is_empty():
		return null
	else:
		return slots[0]



func getSituationStr() -> String:
	var loc := LocalSituations
	
	match localSituation:
		
		loc.ARRIVAL:
			return "Arrival"
		loc.CAST:
			return "Cast"
		loc.BATTLE_ART:
			return "Battle Art"
		loc.ON_TURN:
			return "On Turn"
		loc.RITUAL:
			return "Ritual"
	
	return "Unknown Situation"
		


func checkIsActionTargeted() -> bool:
	for actionScript in get_children():
		if actionScript.has_method("activateTargeted"):
			return true
	return false



#### BAD CODE, REPLACE WITH SIGNALS
##########################################################

func handleArrival(target:Card) -> bool:
	if localSituation == LocalSituations.ARRIVAL:
		return activate(target)
	return false


func handleRitual(target:Card) -> bool:
	if localSituation == LocalSituations.RITUAL:
		return activate(target)
	return false


func handleCast(target:Card) -> bool:
	var success:bool = activate(target)
	if success:
		myCard.restAndAnimate(true)
	
	return success



func checkHasCast() -> bool:
	if localSituation == LocalSituations.CAST:
		return true
	return false



func handleBattleArt(target:Card) -> bool:
	if localSituation == LocalSituations.BATTLE_ART:
		return activate(target)
	return false


func handleOnTurn(target:Card) -> bool:
	if localSituation == LocalSituations.ON_TURN:
		return activate(target)
	return false

extends Node2D



var myCard: Card = null
var isEnemy := false

var effectToGrant:Node = null

#### (ATTACK TARGET, TARGET OF PLAYED RITUAL CARD, ETC)
#### ASSIGNED IN CODE WHEREVER THE ACTION TYPE IS ACTIVATED AND CAN HAVE AN INITIAL TARGET
var initialTarget: Card = null



func setup(card:Card):
	myCard = card
	isEnemy = card.isEnemyCard
	
	for action in get_children():
		action.setup(myCard)
		
func awakenTriggers():
	for trigger in get_children():
		if trigger is Trigger:
			trigger.wake()

func createActionText() -> Array:
	var effectTexts := []
	
		
	return effectTexts



func activateNode(node:Node, target:Card):
	var success := false
	var successfulScript:Node = null
	
	for script in node.get_children():
		if script.has_method("activateTargetless"):
			success = script.activateTargetless(myCard)
			successfulScript = script
			
		elif target:
			if script.has_method("activateTargeted"):
				success = script.activateTargeted(target, myCard)
				successfulScript = script
	
	if success:
		var holder = successfulScript.get_parent()
		successfulScript.createPrintout(holder)  #### CREATE COMBAT LOG ENTRY
		#if not node == payoffNode:
			#handlePayoff(target)
	
	#### UPDATE VISUALS AFTER ACTION
	MyTools.updateBoardCardsVisuals()
	return success



func isTargetless(node:Node) -> bool:
	for script in node.get_children():
		if script.has_method("activateTargetless"):
			return true
	return false


func isTargeted(node:Node) -> bool:
	for script in node.get_children():
		if script.has_method("activateTargeted"):
			return true
	return false



func setInitialTarget(target:Card):
	initialTarget = target


##############################################################

#func handleArrival() -> bool:
#	for trigger in get_children():
#		if cardAction.handleArrival():
#			return true
#	return false


func handleRitual() -> bool:
	var success := false
	
	for cardAction:CardAction in get_children():
		if await cardAction.activate([]):
			success = true
		
	return success


func handleCast() -> bool:
	var success := false
	
	for cardAction in get_children():
		var actionSuccess = cardAction.handleCast()
		if actionSuccess:
			success = true
			
	return success


#func handleBattleArt() -> bool:
#	for cardAction in get_children():
#		if cardAction.handleBattleArt():
#			return true
#	return false


#func handleOnTurn() -> bool:
#	for cardAction in get_children():
#		if cardAction.handleOnTurn():
#			return true
#	return false



######################################################
#func handlePayoff(target:Card) -> bool:
	#return activateNode(payoffNode, target)



##################################################

func getCastAction() -> Node:
	for trigger:Trigger in get_children():
		if trigger is OnCastTrigger:
			return trigger
	return null


func checkIsActionTargeted(cardAction:Node):
	if cardAction.checkIsActionTargeted():
		return true
	return false



func findEmptySlotWhat() -> CardSlot:
	
	var slots:Array = MyTools.findEmptyCardSlots(isEnemy)
	
	if slots.is_empty():
		return null
	else:
		return slots[0]



func getEffectToGrant() -> Node:
	
	if effectToGrant:
		return effectToGrant
	
	else:
	
		var effects:Array = $EffectToGrant.get_children()
		
		if effects.is_empty():
			return null
		return effects[0]

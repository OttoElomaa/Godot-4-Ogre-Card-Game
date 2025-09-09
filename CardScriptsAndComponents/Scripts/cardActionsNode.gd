extends Node2D



var myCard: Card = null
var isEnemy := false

var effectToGrant:Node = null



func setup(card:Card):
	myCard = card
	isEnemy = card.isEnemyCard
	
	for action in get_children():
		action.setup(myCard)
		
	

func createActionText() -> Array:
	var effectTexts := []
	
	for cardAction in get_children():
		if cardAction.has_method("createActionText"):
			effectTexts.append(cardAction.createActionText())
		
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

##############################################################

func handleArrival(target:Card) -> bool:
	for cardAction in get_children():
		if cardAction.handleArrival(target):
			return true
	return false


func handleRitual(target:Card) -> bool:
	for cardAction in get_children():
		if cardAction.handleRitual(target):
			return true
	return false


func handleCast(target:Card) -> bool:
	var success := false
	
	for cardAction in get_children():
		success = cardAction.handleCast(target)
			
	if success:
		myCard.restAndAnimate(true)
	
	return success


func handleBattleArt(target:Card) -> bool:
	for cardAction in get_children():
		if cardAction.handleBattleArt(target):
			return true
	return false


func handleOnTurn(target:Card) -> bool:
	for cardAction in get_children():
		if cardAction.handleOnTurn(target):
			return true
	return false



######################################################
#func handlePayoff(target:Card) -> bool:
	#return activateNode(payoffNode, target)



##################################################

func getCastAction() -> Node:
	for cardAction:Node in get_children():
		if cardAction.checkHasCast():
			return cardAction
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

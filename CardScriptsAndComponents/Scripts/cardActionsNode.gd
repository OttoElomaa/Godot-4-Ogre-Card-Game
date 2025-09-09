extends Node2D



@onready var castNode := $Cast
@onready var battleArtNode := $BattleArt
@onready var ritualNode := $Ritual
@onready var arrivalNode := $Arrival
@onready var onTurnNode := $OnTurn

@onready var specialTriggers := $SpecialCondition
@onready var payoffNode := $Payoff
@onready var costNode := $Cost



var myCard: Card = null
var isEnemy := false

var effectToGrant:Node = null



func setup(card:Card):
	myCard = card
	isEnemy = card.isEnemyCard
	
	for holder in get_children():
		for script in holder.get_children():
			
			if script.has_method("setup"):
				script.setup(card)
	
	#effectToGrant = getEffectToGrant()



func createActionText() -> Array:
	var effectTexts := []
	
	for cardAction in get_children():
		if cardAction.has_method("createActionText"):
			effectTexts.append(cardAction.createActionText())
		
	return effectTexts



#### BEFORE REWRITE. DELETE?
func createActionTextOldVersion():
	var effectTexts := []
		
	#### IS IT RITUAL?
	if myCard.isRitual:
		var ritualText = createNodeText(ritualNode)	
		effectTexts.append(ritualText) 
	
	#### IF NOT RITUAL, CREATE THE REST
	else:
		var arrivalText = createNodeText(arrivalNode)		#### ARRIVAL
		effectTexts.append(arrivalText)
		
		var onTurnText = createNodeText(onTurnNode)		#### ON TURN START
		effectTexts.append(onTurnText) 
		
			
		var castText = createNodeText(castNode)	  #### CAST	
		effectTexts.append(castText) 
		
		
		var battleArtText = createNodeText(battleArtNode)		#### BATTLE ART (Card Combat)
		effectTexts.append(battleArtText) 
	
	var payoffText = createNodeText(payoffNode)		#### BATTLE ART (Card Combat)
	effectTexts.append(payoffText) 
	
	return effectTexts


func createNodeText(node:Node) -> String:
	
	var text = ""
	
	for script in node.get_children():
		text += script.createText()
		text += ", "
	
	#### AT THE END, COMPILE TEXT
	text = text.rstrip(", ")
	if text != "":
		text = "%s: %s" % [getNodeKeyword(node), text]	
	
	return text
	


func getNodeKeyword(node:Node) -> String:
	
	match node:
		arrivalNode:
			return "Arrival"
		ritualNode:
			return "Ritual"
		castNode:
			return "Cast"
		
		battleArtNode:
			return "Battle Art"
		onTurnNode:
			return "On Turn"
			
		payoffNode:
			return "Payoff"
		specialTriggers:
			return "Idk man"
	
	assert(1==2,"Something went wrong in Actions node")
	return ""



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
	var success:bool = activateNode(castNode, target)
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
func handlePayoff(target:Card) -> bool:
	return activateNode(payoffNode, target)



##################################################

func checkHasCast() -> bool:
	if castNode.get_children().is_empty():
		return false
	return true



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

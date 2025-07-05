extends Node



@onready var castNode := $Cast
@onready var battleArtNode := $BattleArt
@onready var ritualNode := $Ritual
@onready var arrivalNode := $Arrival
@onready var onTurnNode := $OnTurn

@onready var specialTriggers := $SpecialCondition
@onready var payoffNode := $Payoff

var myCard: Card = null
var isEnemy := false




func setup(card:Card):
	myCard = card
	isEnemy = card.isEnemyCard
	
	for holder in get_children():
		for script in holder.get_children():
			
			if script.has_method("setup"):
				script.setup(card)


func createActionText() -> Array:
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
	
	for script in node.get_children():
		if script.has_method("activateTargetless"):
			success = script.activateTargetless()
		elif target:
			if script.has_method("activateTargeted"):
				success = script.activateTargeted(target)
	
	if success:
		if not node == payoffNode:
			handlePayoff(target)
	
		MyTools.updateBoardCardsVisuals()
		
	return success


##############################################################

func handleArrival(target:Card):
	return activateNode(arrivalNode, target)


func handleRitual(target:Card):
	return activateNode(ritualNode, target)


func handleCast(target:Card):
	return activateNode(castNode, target)


func handleBattleArt(target:Card):
	return activateNode(battleArtNode, target)


func handleOnTurn(target:Card):
	return activateNode(onTurnNode, target)



######################################################
func handlePayoff(target:Card):
	return activateNode(payoffNode, target)



##################################################

func checkHasCast():
	if castNode.get_children().is_empty():
		return false
	return true



func findEmptySlotWhat() -> CardSlot:
	
	var slots:Array = MyTools.findEmptyCardSlots(isEnemy)
	
	if slots.is_empty():
		return null
	else:
		return slots[0]

@icon("res://Art/icons/16x16/swords.png")
extends Node2D
class_name ActionsNode


var myCard: Card = null
var isEnemy := false

@onready var triggers:
	get:
		return get_children()

var effectToGrant:Node = null

#### (ATTACK TARGET, TARGET OF PLAYED RITUAL CARD, ETC)
#### ASSIGNED IN CODE WHEREVER THE ACTION TYPE IS ACTIVATED AND CAN HAVE AN INITIAL TARGET
var initialTarget: Card = null


## Sets up all children and activates their own setup routines.
func setup(card:Card):
	myCard = card
	isEnemy = card.isEnemyCard
	
	for action in get_children():
		action.setup(myCard)


		
func awakenTriggers():
	for trigger in get_children():
		if trigger is Trigger:
			trigger.wake()

func putTriggersToSleep():
	for trigger in get_children():
		if trigger is Trigger:
			trigger.sleep()



func createActionText() -> Array:
	var actionTexts := []
	
	for trigger in triggers:
		if trigger is Trigger:
			actionTexts.append_array(trigger.createActionText())
		else:
			assert(1==2, "Does this non-Trigger node belong here?")
		
	return actionTexts






func setInitialTarget(target:Card):
	initialTarget = target


##############################################################


func handleRitual() -> bool:
	var success := false
	
	for child in get_children():
		if child is OnCastTrigger:
			if await child.execute(null):
				success = true

	if success:
		SignalBus.ritual.emit()
		CardAnimationQueue.queueFunction(CardAnimationQueue.startResponseQueue) 
	return success


func handleCast() -> bool:
	var success := false

	for child in get_children():
		if child is OnCastTrigger:
			if await child.execute(null):
				success = true

	if success:
		SignalBus.cast.emit()
		CardAnimationQueue.queueAnimation(myCard, myCard.restAndAnimate)
		#myCard.restAndAnimate()
	return success


##################################################

func getCastAction() -> Node:
	if myCard.cardType == myCard.CardTypes.CREATURE:
		for child in get_children():
			if child is OnCastTrigger:
				return child
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

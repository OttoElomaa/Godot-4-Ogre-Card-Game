@icon("res://Art/icons/16x16/camera_first_person.png")
extends Node
class_name Trigger

@export var triggered_when := ''
@export var situation_text := ''

var conditions = []
var disabled = false
var myCard: Card = null

func _ready():
	if not SignalBus.is_connected(triggered_when, execute):
		SignalBus.connect(triggered_when, execute)
	

func setup(card: Card):
	myCard = card
	for child in get_children():
		if child is ConditionalComponent:
			conditions.append(child)
		if child.has_method('setup'):
			child.setup(myCard)

func sleep():
	disabled = true
	
func wake():
	disabled = false

func createActionText():
	var actionTexts := []
	var actions:Array = get_children()
	for action in actions:
		if action is CardAction:
			actionTexts.append(action.createActionText())
	return actionTexts
			

func execute(params:SignalParams) -> bool:
	if not is_inside_tree():
		return false
	
	var success = false

	if disabled:
		return success
	
	if myCard.cardState != myCard.CardStates.BOARD and myCard.cardType == myCard.CardTypes.CREATURE:
		return success 
	
	if not params:
		params = SignalParams.new()

	print(name, ' from ', myCard.name, ' is executing')

	for cond:ConditionalComponent in conditions:
		if not cond.check(params.sourceCard, myCard):
			return false
	print(name, ' all conditions green')

	for child in get_children():
		if child is CardAction:
			success = await child.activate(params)
			if not success:
				return success

	return success

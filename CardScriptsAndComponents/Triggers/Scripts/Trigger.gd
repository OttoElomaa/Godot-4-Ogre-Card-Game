extends Node
class_name Trigger

@export var triggered_when := ''
@export var situation_text := ''

var conditions = []

var myCard: Card = null
var disabled = true

signal completed

func _ready():
	SignalBus.connect(triggered_when, execute)
	

func setup(card):
	myCard = card
	for child in get_children():
		if child is ConditionalComponent:
			conditions.append(child)
		if child.has_method('setup'):
			child.setup(myCard)


func wake():
	disabled = false

func sleep():
	disabled = true

func execute(args):
	var success = false
	if not disabled or myCard.cardType == myCard.CardTypes.RITUAL:
		if not args:
			args = []
		print(name, ' from ', myCard.cardName, ' is executing')
		for cond in conditions:
			if cond is ConditionalComponent:
				if not cond.check(myCard, args):
					return false
				cond.reset()
		print(name, ' all conditions green')
		for child in get_children():
			if child is CardAction:
				success = await child.activate(args)
	return success

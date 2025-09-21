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
	for child in get_children():
		if child is ConditionalComponent:
			conditions.append(child)
		if child.has_method('setup'):
			child.setup(myCard)

func setup(card):
	myCard = card

func wake():
	disabled = false

func execute():
	if not disabled:
		print(name, ' from ', myCard.cardName, ' is executing')
		for cond in conditions:
			if cond is ConditionalComponent:
				if not cond.check(myCard, null):
					return
				cond.reset()
		print(name, ' all conditions green')
		for child in get_children():
			if child is CardAction:
				child.activate()

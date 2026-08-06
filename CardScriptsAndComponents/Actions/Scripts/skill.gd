@icon("res://Art/icons/16x16/script_start.png")
extends Node2D
class_name Skill

@export var skillName := ""


var action:CardAction = null
var myCard:Card = null

func setup(myAction:Node, card:Card):
	self.action = myAction
	self.myCard = card


#### THIS FUNCTION WILL BE FILLED IN INHERITED SCRIPTS
func activate(targets:Array) -> bool:
	return false

#### THIS FUNCTION IS OUTDATED AND SHOULD NOT BE USED
func createText() -> String:
	return ""

func get_scaling(new_args: Dictionary) -> int:
	var bonus_value = 0
	var arguments = {} 
	arguments['saved_targets'] = get_saved_targets()
	arguments['user'] = myCard
	arguments['action'] = action
	arguments.merge(new_args)
	if not get_children().is_empty():
		for child in get_children():
			if child is ScalingComponent:
				bonus_value += child.get_scaling(arguments) * child.multiplier
	print('Scaled with ', bonus_value)
	return bonus_value

func get_return_value(new_args: Dictionary) -> Variant:
	var arguments = {} 
	arguments['saved_targets'] = get_saved_targets()
	arguments['user'] = myCard
	arguments['action'] = action
	arguments.merge(new_args)
	if not get_children().is_empty():
		for child in get_children():
			if child is ReturningComponent:
				print('Skill', name, 'queries a return', child.get_return_value(arguments))
				return child.get_return_value(arguments)
	return null
			
			
func isScaled() -> bool:
	return get_children().size() > 0

func get_saved_targets():
	return action.get_saved_targets()

func createPrintout():
	
	var holderText:String = action.getSituationStr()
	var lineOne := "%s triggers on %s %s:" % [holderText, MyTools.getFactionString(myCard), action.myCard.cardName]
	MyTools.createCombatLogPrintout(lineOne, Color.WHITE)
	
	var effectText = self.createText()
	MyTools.createCombatLogPrintout(action.customActionText, Color.STEEL_BLUE)

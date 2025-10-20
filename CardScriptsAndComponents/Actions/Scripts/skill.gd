@icon("res://Art/icons/16x16/script_start.png")
extends Node2D
class_name Skill

@export var skillName := ""


var action:CardAction = null
var myCard:Card = null


func setup(action:Node, card:Card):
	self.action = action
	self.myCard = card


#### THIS FUNCTION WILL BE FILLED IN INHERITED SCRIPTS
func activate(targets:Array) -> bool:
	return false

#### THIS FUNCTION IS OUTDATED AND SHOULD NOT BE USED
func createText() -> String:
	return ""

func get_scaling(args: Dictionary) -> int:
	var bonus_value = 0
	if get_children().size() > 0:
		for child:ScalingComponent in get_children():
			bonus_value += child.get_scaling(args)
	return bonus_value

func isScaled() -> bool:
	return get_children().size() > 0

func createPrintout(action:CardAction):
	
	var holderText:String = action.getSituationStr()
	var lineOne := "%s triggers on %s %s:" % [holderText, MyTools.getFactionString(myCard), action.myCard.cardName]
	MyTools.createCombatLogPrintout(lineOne, Color.WHITE)
	
	var effectText = self.createText()
	MyTools.createCombatLogPrintout(action.customActionText, Color.STEEL_BLUE)

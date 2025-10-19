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



func createPrintout(action:CardAction):
	
	var holderText:String = action.getSituationStr()
	var lineOne := "%s triggers on %s %s:" % [holderText, MyTools.getFactionString(myCard), action.myCard.cardName]
	MyTools.createCombatLogPrintout(lineOne, Color.WHITE)
	
	var effectText = self.createText()
	MyTools.createCombatLogPrintout(action.customActionText, Color.STEEL_BLUE)

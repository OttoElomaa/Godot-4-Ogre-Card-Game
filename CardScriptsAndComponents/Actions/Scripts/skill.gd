extends Node2D
class_name Skill

@export var skillName := ""


var action:Node = null
var myCard:Card = null


func setup(action:Node, card:Card):
	self.action = action
	self.myCard = card


#### THIS FUNCTION WILL BE FILLED IN INHERITED SCRIPTS
func activate(targets:Array) -> bool:
	return false

#### THIS FUNCTION WILL BE FILLED IN INHERITED SCRIPTS
func createText() -> String:
	return ""



func createPrintout(action:Node):
	
	var holderText:String = action.getSituationStr()
	var lineOne := "%s triggers on %s %s:" % [holderText, MyTools.getFactionString(myCard), action.myCard.cardName]
	MyTools.createCombatLogPrintout(lineOne, Color.WHITE)
	
	var effectText = self.createText()
	MyTools.createCombatLogPrintout(effectText, Color.STEEL_BLUE)

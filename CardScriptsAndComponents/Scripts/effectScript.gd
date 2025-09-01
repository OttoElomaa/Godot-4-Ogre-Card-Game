extends Node


class_name  EffectScript




enum TargetOptions {NONE, ALLY, ALLIES, ENEMY, ENEMIES, ALL}
enum DetailedTargetingOptions {NONE, STRONGEST, WEAKEST,}



var actionsNode: Node = null
	#get:
		#return get_parent().get_parent()
		
		
var myCard: Card = null
var isEnemy := false


################################################ TYPE AND ALLY/ENEMY TARGETING - WHO DOES IT TARGET?

#### TRIGGER TYPE: For example, ON ANOTHER 'RATFOLK' ENTERING...
@export var triggerTypeLine := ""
#### EFFECT TYPE: For example, BOLSTER ALL OTHER 'SPIRITS'...
@export var effectTypeLine := ""

@export var targetGroup := TargetOptions.NONE
@export var detailedTargeting := DetailedTargetingOptions.NONE


####################################### EFFECT - WHAT DOES IT DO
@export var grantEffect := false

@export var inflict := 0
@export var inflictPlayer := 0
@export var inflictCreature := 0
@export var corrode := 0

@export var hasTap := false

@export var bolsterDamage := 0
@export var bolsterHealth := 0


@export var phaseOut := false




func setup(card:Card):
	myCard = card
	isEnemy = card.isEnemyCard
	
	actionsNode = card.actions




func createText() -> String:
	
	var text = ""
	
	#### ADD INFLICT
	if inflict > 0:
		text += "Inflict %d" % inflict
	elif inflictPlayer > 0:
		text += "Inflict Player %d" % inflictPlayer
	elif inflictCreature > 0:
		text += "Inflict Creature %d" % inflictCreature
	
	if corrode > 0:
		text += "Corrode %d" % corrode
	
	
	#### ADD TAP
	if hasTap:
		text += "Tap target"
	
	
	#### ADD BOLSTER
	if bolsterDamage > 0 or bolsterHealth > 0:
		
		match targetGroup:
			#### ALL ALLIES
			TargetOptions.ALLIES:
				if effectTypeLine != "":
					text += "Bolster %s" % effectTypeLine
				else:
					text += "Bolster Allies"
			
			#### ONE ALLY - CAST ONLY? -> Needs Targeting
			TargetOptions.ALLY:	
				if effectTypeLine != "":
					text += "Bolster Target %s" % effectTypeLine
				else:
					text += "Bolster"
			
		text += " %d/%d" % [bolsterDamage, bolsterHealth]
	
	
	
	
	#### ADD SCRIPT-SPECIFIC EFFECT TEXT
	text += createTextTwo()
	return text


#### NEEDS TO BE EMPTY HERE -> FILLED IN Targeted AND Targetless SCRIPTS
func createTextTwo() -> String:
	return ""



func createPrintout(actionHolder:Node):
	
	var holderText:String = actionHolder.actionTypeStr
	var lineOne := "%s trigger on %s:" % [holderText, myCard.cardName]
	MyTools.createCombatLogPrintout(lineOne, Color.WHITE)
	
	var effectText = createText()
	MyTools.createCombatLogPrintout(effectText, Color.STEEL_BLUE)
	

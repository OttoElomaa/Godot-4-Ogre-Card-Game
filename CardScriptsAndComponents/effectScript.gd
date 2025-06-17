extends Node


class_name  EffectScript




enum TargetOptions {NONE, ALLY, ALLIES, ENEMY, ENEMIES, ALL}
enum DetailedTargetingOptions {NONE, STRONGEST, WEAKEST,}



var myEffectNode:
	get:
		return get_parent()
		
		
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
@export var hasTap := false
@export var inflict := 0
@export var inflictPlayer := 0
@export var inflictCreature := 0

@export var bolsterDamage := 0
@export var bolsterHealth := 0

@export var drawCards := 0

@export var summonScene: PackedScene = null
@export_multiline var summonString := "Summon a thing"




func setup():
	pass




func createText() -> String:
	
	var text = ""
	
	#### ADD INFLICT
	if inflict > 0:
		text += "Inflict %d" % inflict
	elif inflictPlayer > 0:
		text += "Inflict Player %d" % inflictPlayer
	elif inflictCreature > 0:
		text += "Inflict Creature %d" % inflictCreature
	
	
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
	
	#### ADD TAP
	if hasTap:
		text += "Tap target"
	
	#### CARD DRAW
	if drawCards > 0:
		text += "Draw %d" % drawCards
	
	#### ADD SUMMON
	if summonScene:
		text += summonString
	
	return text






func bolster(targets:Array):
	pass

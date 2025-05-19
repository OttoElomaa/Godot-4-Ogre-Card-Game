extends Node

enum TargetOptions {NONE, ALLIES, ENEMIES}

@export var targetGroup := TargetOptions.NONE

@export var hasTap := false
@export var inflict := 0
@export var inflictPlayer := 0
@export var inflictCreature := 0

@export var bolstersAllAllies := false
@export var bolsterDamage := 0
@export var bolsterHealth := 0




func createText() -> String:
	
	var text = ""
	
	#### ADD OTHERS AS WELL
	if bolsterDamage > 0 or bolsterHealth > 0:
		if bolstersAllAllies:
			text += "Bolster Allies"
		else:
			text += "Bolster"
		text += " %d/%d" % [bolsterDamage, bolsterHealth]
	
	if text != "":
		text = "Cast: %s" % text
	
	return text



func processPlayerCast(target:Card):
	pass




func processPlayerBattleArt(target:Card):
	pass

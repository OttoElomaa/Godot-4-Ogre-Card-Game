extends ActionScript


enum ManualTargetOptions {NONE, ALLY, ALLIES, ENEMY, ENEMIES, ALL}
#enum DetailedTargetingOptions {NONE, STRONGEST, WEAKEST,}

@export var manualTargetGroup := ManualTargetOptions.NONE

@export var hasSacrifice := false





func createTextTwo() -> String:
	var text := ""
	
	assert(manualTargetGroup != ManualTargetOptions.NONE, "You forgot to assign target group to card action")
	
	#### ADD AN EFFECT COUNTER TO TARGET
	if grantEffect:
		var effect:Node = actionsNode.getEffectToGrant()
		if not effect:
			assert(1==2,"WTF effect to grant error")
			
		var effectName:String = effect.getEffectName()
		text += "Add %s to target" % effectName
	
	#### SACRIFICE
	if hasSacrifice:
		text += "Sacrifice target"
	

					
	#### BOLSTER
	if bolsterDamage > 0 or bolsterHealth > 0:
		match manualTargetGroup:
			
			#### ONE ALLY - CAST ONLY? -> Needs Targeting
			ManualTargetOptions.ALLY:	
				if effectTypeLine != "":
					text += "Bolster Target %s" % effectTypeLine
				else:
					text += "Bolster"
			
		text += " %d/%d" % [bolsterDamage, bolsterHealth]
	
	return text



func activateTargeted(target:Card, actor:Card):
	var success := false
	
	#### TARGETED-ONLY ACTIONS  #######################################
	
	#### SACRIFICE
	if hasSacrifice:
		if myCard.isOnSameSide(target):
			target.destroyAndAnimate(true)
			success = true
	
	
	#### GENERIC ACTIONS, TARGETED VERSIONS  ##############################
	
	#### GRANT AN EFFECT
	if grantEffect:
		var effect = actionsNode.getEffectToGrant()
		if effect:
			target.addEffect(effect)
			success = true
	
	#### INFLICT
	if inflict > 0:
		CardActions.inflict(target, inflict)
		success = true
	elif inflictCreature > 0:
		CardActions.inflict(target, inflictCreature)
		success = true
	
	#### CORRODE
	if corrode > 0:
		CardActions.corrode(target, corrode)
		success = true
	

	#### TAP
	if hasTap:
		target.restAndAnimate(false)
		success = true
	
	#### BOLSTER
	#if targetGroup in [TargetOptions.ALLY, TargetOptions.ENEMY]:
	if bolsterDamage > 0 or bolsterHealth > 0:
		target.tempDamage += bolsterDamage
		target.tempHealth += bolsterHealth
		success = true
	
	
	
	target.updateCardLabels()
	#if target.tempHealth <= 0:
		#target.destroyAndAnimate(true)
	
	return success

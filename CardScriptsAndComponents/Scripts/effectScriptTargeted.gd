extends EffectScript



@export var hasSacrifice := false





func createTextTwo() -> String:
	var text := ""
	
	if grantEffect:
		var effect:CardEffect = actionsNode.getEffectToGrant()
		if not effect:
			assert(1==2,"WTF effect to grant error")
			
		var effectName:String = effect.getEffectName()
		text += "Add %s to target" % effectName
	
	if hasSacrifice:
		text += "Sacrifice target"
	
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

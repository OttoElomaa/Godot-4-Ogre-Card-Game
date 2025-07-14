extends EffectScript



@export var hasSacrifice := false





func createTextTwo() -> String:
	var text := ""
	
	if hasSacrifice:
		text += "Sacrifice target"
	
	return text



func activateTargeted(target:Card):
	var success := false
	
	
	#### SACRIFICE
	if hasSacrifice:
		if myCard.isOnSameSide(target):
			target.destroyAndAnimate(true)
			success = true
	
	#### INFLICT
	if inflict > 0:
		target.tempHealth -= inflict
		success = true
	elif inflictCreature > 0:
		target.tempHealth -= inflictCreature
		success = true
	
	#### CORRODE
	if corrode > 0:
		target.tempHealth -= corrode
		target.health -= corrode
	
	
	
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
	if target.tempHealth <= 0:
		target.destroyAndAnimate(true)
	
	return success

extends EffectScript






func activateTargeted(target:Card):
	var success := false
	
	#### INFLICT
	if inflict > 0:
		target.tempHealth -= inflict
		target.health -= inflict
		success = true
	elif inflictCreature > 0:
		target.tempHealth -= inflictCreature
		target.health -= inflictCreature
		success = true
	
	#### BOLSTER
	#if targetGroup in [TargetOptions.ALLY, TargetOptions.ENEMY]:
	if bolsterDamage > 0 or bolsterHealth > 0:
		target.tempDamage += bolsterDamage
		target.tempHealth += bolsterHealth
		success = true
	
	if hasTap:
		target.restAndAnimate(false)
		success = true
	
	target.updateCardLabels()
	if target.tempHealth <= 0:
		target.destroyAndAnimate(true)
	
	return success

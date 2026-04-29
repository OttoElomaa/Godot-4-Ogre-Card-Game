extends Skill

func activate(targets:Array):
	var success = false
	for target:Card in targets:
		target.tempHealth = target.health
		target.updateCardVisuals()
	
	success = true
	return success

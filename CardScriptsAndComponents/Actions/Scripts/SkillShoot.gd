extends Skill

func activate(targets:Array) -> bool:
	var success = true
	for c:Card in targets:
		c.takeCombatDamage(myCard, false)
		var died = c.checkAndHandleDeathFromTempHealth()
		if died:
			CardAnimationQueue.startResponseQueue()
	return success

extends Skill

func activate(targets):
	action.savedTargets.clear()
	action.savedTargets.append_array(targets)
	return true
	

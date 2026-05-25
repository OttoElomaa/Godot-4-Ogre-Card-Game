extends Skill


var myAction:CardAction = get_parent()

func activate(targets):
	myAction.savedTargets.clear()
	myAction.savedTargets.append_array(targets)
		
	

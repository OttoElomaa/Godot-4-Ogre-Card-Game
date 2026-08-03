extends Skill

var myAction:CardAction

func setup(action:Node, card:Card):
	myAction = action

func activate(targets):
	myAction.savedTargets.clear()
	myAction.savedTargets.append_array(targets)
	

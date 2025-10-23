extends Skill

func activate(targets):
	for card:Card in targets:
		get_parent().savedTargets.clear()
		get_parent().savedTargets.append_array(targets)
	return true

extends TargetingComponent
class_name AutoTargetingComponent

func ready():
	pass

func getTargets(condition):
	var targets = []
	var conditions = []
	var success = true
	
	for child in get_children(true):
		if child is ConditionalComponent:
			conditions.append(child)
	print(name, 'has conditions ', conditions)
	
	
	for card:Card in MyTools.getAllBoardCards():
		print(name, ' is checking ', card, ' with conditions ', conditions)
		success = true
		for cond in conditions:
			if cond is ConditionalComponent:
				if not cond.check(card, myCard):
					success = false
				cond.reset()
		if success:
			targets.append(card)
	print(name, ' acquired targets ', targets)
	return targets

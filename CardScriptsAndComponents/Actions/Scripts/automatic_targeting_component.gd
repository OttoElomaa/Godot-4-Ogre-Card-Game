extends TargetingComponent
class_name AutoTargetingComponent

var conditions = []

func ready():
	for child in get_children():
		if child is ConditionalComponent:
			conditions.append(child)

func getTargets(condition):
	var targets = []
	
	for card:Card in MyTools.getAllBoardCards():
		for cond:ConditionalComponent in conditions:
			if not cond.check(card, condition):
				break
			cond.reset()
		targets.append(card)
	print(name, ' acquired targets ', targets)
	return targets

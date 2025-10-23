extends Skill

## String ID of the effect in question.
@export var effectID = ''
## How many stacks will be added/removed.
@export var amount: int = 0

func activate(targets: Array):
	var success = false
	for target:Card in targets:
		target.changeEffectStacks(effectID, amount)
		success = true
	return success

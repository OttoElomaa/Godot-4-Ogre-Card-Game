extends Skill

## String ID of the effect in question.
@export var effectID = ''
## How many stacks will be added/removed.
@export var amount: int = 0

func activate(targets: Array):
	var success = false
	for target:Card in targets:
		target.changeEffectStacks(effectID, amount)
		var verb = ' gains '
		if amount < 0:
			verb = ' loses '
		var text = "%s %s %s %s %s" % [MyTools.getFactionString(target), target.cardName, verb, abs(amount), effectID]
		MyTools.createCombatLogPrintout(text, Color.SKY_BLUE)
	
		success = true
	return success

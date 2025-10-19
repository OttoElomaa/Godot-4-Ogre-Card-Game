extends ConditionalComponent

func check(card:Card, args):
	if card == args[0]:
		return true
	else:
		return false

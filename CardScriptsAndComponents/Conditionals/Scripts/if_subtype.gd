extends ConditionalComponent

func check(card:Card, subtype:String):
	if card.subTypeStr.contains(subtype):
		return true
	else:
		return false

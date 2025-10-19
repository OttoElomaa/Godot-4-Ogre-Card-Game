extends ConditionalComponent
@export var subtype := ""

func check(card:Card, _cond = null):
	print(name, ' is checking for' , subtype)
	if card.subTypeStr.contains(subtype):
		print(MyTools.getFactionString(card), ' ', card.cardName, ' is ', subtype)
		return true
	else:
		return false

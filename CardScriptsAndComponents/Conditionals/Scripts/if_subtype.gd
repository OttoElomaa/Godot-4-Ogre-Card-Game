extends ConditionalComponent
@export var subtype := ""

func check(card:Card, _cond = null):
	return card.subTypeStr.contains(subtype)

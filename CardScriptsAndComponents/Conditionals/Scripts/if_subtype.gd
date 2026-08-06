extends ConditionalComponent
@export var subtype := ""

func check(card_to_check:Card, myCard:Card) -> bool:
	if isChanged():
		var return_value = get_return_value({})
		if return_value is String:
			subtype = return_value
		
	return card_to_check.subTypeStr.contains(subtype)

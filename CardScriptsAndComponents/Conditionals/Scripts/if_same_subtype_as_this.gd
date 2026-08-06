extends ConditionalComponent

## If true, the condition will only be met if target's subtype matches this card's s
@export var strict = false

func check(card_to_check:Card, myCard:Card) -> bool:
	if isChanged():
		var return_value = get_return_value({'user': myCard}) 
		if return_value is Card:
			myCard = return_value
	
	if strict:
		return card_to_check.subTypes == myCard.subTypes
	else:
		for i in card_to_check.subTypes:
			if myCard.subTypes.has(i):
				return true
		return false
				
				

extends ConditionalComponent
@export var subtypes: Array
@export var strict := false
func check(card_to_check:Card, myCard:Card) -> bool:
	if isChanged():
		var return_value = get_return_value({'user': myCard, 'target': card_to_check}) 
		if return_value is Card:
			subtypes = return_value.subTypes
		elif return_value is Array:
			subtypes.append_array(return_value)
		elif return_value is String:
			subtypes.append(return_value)
		
	if strict:
		return card_to_check.subTypes == subtypes
	else:
		for i in card_to_check.subTypes:
			if subtypes.has(i):
				return true
		return false

@tool
extends ReturningComponent

##Name of the card's custom value that needs to be returned.
@export var value_name := ''

func get_return_value(_args:Dictionary) -> Variant:
	var card:Card = _args['user']
	if card.custom_values.has('value_name'):
		return card.custom_values[value_name]
	else:
		return null

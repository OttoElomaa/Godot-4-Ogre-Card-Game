extends Node
class_name ConditionalComponent

func check(card_to_check:Card, myCard:Card) -> bool:
	return card_to_check is Card

func get_return_value(new_args: Dictionary) -> Variant:
	var arguments = {}
	arguments.merge(new_args)
	if get_children().size() > 0:
		for child:ReturningComponent in get_children():
			return child.get_return_value(arguments)
	return null

func isChanged():
	print('Conditional component ', name, ' is changed.')
	return not get_children().is_empty()

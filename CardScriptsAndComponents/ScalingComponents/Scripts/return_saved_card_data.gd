@tool
extends ReturningComponent
@export var card_action_node:CardAction:
	set(value):
		card_action_node = value
		update_configuration_warnings()

## The index of the saved card in the list. The index starts from 0, from left to right.
@export var index = 0

func _ready():
	child_order_changed.connect(_get_configuration_warnings)

func _get_configuration_warnings():
	var warnings = PackedStringArray()
	
	if get_parent() is ConditionalComponent and not card_action_node:
		warnings.append('Assign a Card Action Node, or this will not work.')
		
	return warnings

func get_return_value(_args:Dictionary) -> Variant:
	var referred_card:Card 
	if not _args.has('saved_targets'):
		
		if card_action_node:
			if card_action_node.savedTargets.is_empty():
				return {}
			referred_card = card_action_node.savedTargets[index]
		else:
			return {}
	
	referred_card = _args['saved_targets'][index]
	
	return {
		'cardName': referred_card.cardName,
		'subTypes': referred_card.subTypes,
		'health': referred_card.health,
		'damage': referred_card.damage,
		'mana_cost': referred_card.manaCost
	}

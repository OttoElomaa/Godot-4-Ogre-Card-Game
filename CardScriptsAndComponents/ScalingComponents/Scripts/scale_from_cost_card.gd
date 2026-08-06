extends ScalingComponent

enum SavedCardStats {HEALTH, DAMAGE, MANA_COST}

@export var stat_to_use = SavedCardStats.HEALTH

## The index of the saved card in the list. The index starts from 0, from left to right.
@export var index:int = 0

func get_scaling(args:Dictionary):
	var referred_card:Card = args['saved_targets'][index]
	var value:Variant = 0
	if not referred_card:
		assert(1==2, 'Nothing saved!')
	match stat_to_use:
		SavedCardStats.HEALTH:
			value = referred_card.health
		SavedCardStats.DAMAGE:
			value = referred_card.damage
		SavedCardStats.MANA_COST:
			value = referred_card.manaCost
	return value

extends ScalingComponent

enum SavedCardStats {HEALTH, DAMAGE, MANA_COST}

@export var stat_to_use = SavedCardStats.HEALTH

func get_scaling(args:Dictionary):
	var referred_card:Card = args['saved_targets'][0]
	var value:int = 0
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

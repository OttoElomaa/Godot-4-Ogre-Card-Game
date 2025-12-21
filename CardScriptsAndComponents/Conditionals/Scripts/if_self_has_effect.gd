extends ConditionalComponent
@export var effect_id = ''
@export var minimum_stacks = 1

func check(card:Card, myCard:Card) -> bool:
	if myCard.hasEffect(effect_id):
		if myCard.getEffect(effect_id).counter > minimum_stacks:
			return true
	return false

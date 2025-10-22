extends ConditionalComponent
@export var card_type: String = ''

func check(card:Card, _condition) -> bool:
	return card.cardTypeStr == card_type

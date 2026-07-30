extends ConditionalComponent
@export var keyword:String = ''

func check(card:Card, condition) -> bool:
	return card.hasKeyword('')

extends ConditionalComponent

func check(card:Card, params:SignalParams):
	return card == params.sourceCard

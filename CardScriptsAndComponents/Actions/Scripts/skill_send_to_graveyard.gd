extends Skill

func activate(targets) -> bool:
	for card:Card in targets:
		card.destroyAndAnimate()
	return true

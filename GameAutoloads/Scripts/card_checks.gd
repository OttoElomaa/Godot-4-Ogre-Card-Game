extends Node




##############################################################
#### SORTING AND COMPARING CARD POWER LEVELS


#### Calculates a card's relative power to the caller. Most enemies are less
#### eager to attack cards with higher power.
func get_card_power(card:Card) -> int:
	var power: int = 0
	power = card.tempDamage + card.tempHealth
	return power


func get_weaker(card_1:Card, card_2:Card) -> bool:
	return get_card_power(card_1) < get_card_power(card_2)

func get_stronger(card_1:Card, card_2:Card) -> bool:
	return get_card_power(card_1) > get_card_power(card_2)


#### Sorts an array of Cards with weakest ones going to the front.
func sort_by_weakest(array:Array) -> Array:
	array.sort_custom(get_weaker)
	return array

func sort_by_strongest(array:Array) -> Array:
	array.sort_custom(get_stronger)
	return array


##################################################
#### PRIORITY


##Sorts cards in an Array based on their priotity.
func get_higher_priority(a:Card, b:Card):
	return a.priority > b.priority

func sort_by_priority(array:Array):
	array.sort_custom(get_higher_priority)
	return array



##############################################
#### FILTERING BY TYPE

func getCastersInList(list:Array):
	var casters = []
	for c:Card in list:
		if c.action_mode == c.actionMode.CASTER:
			casters.append(c)
	sort_by_priority(casters)
	return casters

func getAttackersInList(list:Array):
	var attackers = []
	for c:Card in list:
		if c.action_mode == c.actionMode.ATTACKER and c.checkCanAct():
			attackers.append(c)
	sort_by_strongest(attackers)
	sort_by_priority(attackers)
	print(attackers)
	return attackers

func getNonBlockersInList(list:Array) -> Array:
	var non_blockers = []
	for c:Card in list:
		if not c.checkCanBlock():
			non_blockers.append(c)
	CardChecks.sort_by_strongest(non_blockers)
	return non_blockers

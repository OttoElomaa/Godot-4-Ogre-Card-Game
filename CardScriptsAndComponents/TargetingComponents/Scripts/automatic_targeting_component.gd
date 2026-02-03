extends TargetingComponent
class_name AutoTargetingComponent

## Where the component should check for targetable cards.
## Warning: by default, it checks board, hands, decks etc of both players. 
## Use a ConditionalComponent if you only want to check the allied deck, for example.
@export_category('Target Groups')


## Targets all cards played on board.
@export var use_board_cards = true
## Targets all cards in player and enemy hands. 
@export var use_hand_cards = false
## Targets all cards in player and enemy decks.
@export var use_deck_cards = false
## Targets all cards in the player and enemy graveyards.
@export var use_graveyard_cards = false



func getTargets() -> Array:
	var targets = []
	
	#### GET TARGETING GROUP AND CONDITIONS
	var cards_in_group = get_cards_in_group()
	var conditions: Array = getMyConditions()
	print("%s targeting group before conditions: %s" % [name, cards_in_group])
	
	#### FIND VALID TARGETS IN TARGETING GROUP BASED ON CONDITIONS
	for card:Card in cards_in_group:
		if checkAllConditionsOnTarget(card, conditions):
			targets.append(card)
	print(name, ' acquired targets ', targets)
	return targets



func getMyConditions() -> Array:
	var conditions := []
	for child in get_children(true):
		if child is ConditionalComponent:
			conditions.append(child)
			
	print("%s has conditions: %s" % [name, conditions])
	return conditions


func checkAllConditionsOnTarget(target:Card, conditions:Array):
	print("%s is checking %s with conditions: %s" % [name, target.cardName, conditions] )
	var success = true
	for cond in conditions:
		if not cond.check(target, myCard):
			success = false
	return success


func get_cards_in_group() -> Array:
	var cards = []
	if use_board_cards:
		cards.append_array(MyTools.getAllBoardCards()) 
	if use_deck_cards:
		cards.append_array(MyTools.getAllDeckCards())
	if use_hand_cards:
		cards.append_array(MyTools.getAllHandCards())
	if use_graveyard_cards:
		cards.append_array(MyTools.getAllGraveyards())
	return cards

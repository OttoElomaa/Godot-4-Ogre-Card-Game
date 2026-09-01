extends ScalingComponent
## Returns the number of cards in a chosen group that meet child conditional components.

@export var count_allies = true
@export var count_enemies = false
@export var count_graveyards = false
@export var subtype:String = ''

func get_scaling(_args: Dictionary) -> int:
	var cards = []
	var myCard: Card = _args['user']
	var conditions = get_children()
	if count_allies:
		cards.append_array(MyTools.getBoardCards(myCard.isEnemy))
	if count_enemies:
		cards.append_array(MyTools.getBoardCards(!myCard.isEnemy))
	if count_graveyards:
		cards.append_array(MyTools.getAllGraveyards())
	
	var counter = 0
	
	for c:Card in cards:
		var conditions_green = true
		for child:ConditionalComponent in conditions:
			if not child.check(c, myCard):
				conditions_green = false
		if not conditions_green:
			continue
		counter += 1
	
	return counter
		
	

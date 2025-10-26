extends Skill



@export var alterOwnerHealth := 0
@export var alterOwnerMana := 0
@export var alterOpponentHealth := 0
@export var alterOpponentMana := 0




func activate(targets:Array) -> bool:
	var success := false
	
	#### ALTER OWNER RESOURCES
	if alterOwnerHealth != 0:
		var value = alterOwnerHealth
		if isScaled():
			value = get_scaling({})
		MyTools.changeHealth(value, myCard.isEnemyCard)
		success = true
	if alterOwnerMana != 0:
		var value = alterOwnerMana
		if isScaled():
			value = get_scaling({})
		MyTools.changeMana(value, myCard.isEnemyCard)
		success = true

	#### ALTER OWNER RESOURCES
	if alterOpponentHealth != 0:
		var value = alterOpponentHealth
		if isScaled():
			value = get_scaling({})
		MyTools.changeHealth(value, !myCard.isEnemyCard)
		success = true
	if alterOpponentMana != 0:
		var value = alterOpponentMana
		if isScaled():
			value = get_scaling({})
		MyTools.changeMana(value, !myCard.isEnemyCard)
		success = true

		
	#### TARGETED ACTIONS
	for target:Card in targets:
		pass

		
	return success
	


func createText() -> String:
	var text := ""
	
	#### CARD DRAW
	if alterOwnerMana != 0:
		text = "Add %d mana" % alterOwnerMana
	
	
	
	return text

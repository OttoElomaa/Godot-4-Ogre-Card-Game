extends ActionsNode
class_name ActionsNodeChamp

enum cost_types {None, Mana, Health}

@export var action_name = ''
@export var level = 1
@export var texture:Texture
@export var cost_display:Dictionary[cost_types, int] = {}

func handleCast() -> bool:
	var success := false
	
	if not check_resources_available():
		return success

	for child in get_children():
		if child is OnCastTrigger:
			if await child.execute(null):
				success = true

	pay_resource_cost()
	
	return success
	
func check_resources_available() -> bool:
	var success = false
	var mana_source = GameInfo.enemyMana
	var health_source = GameInfo.enemyMana
	
	if not isEnemy:
		mana_source = GameInfo.playerMana
		health_source = GameInfo.playerMana
	
	if cost_display.has(ActionsNodeChamp.cost_types.Mana) and mana_source < cost_display[cost_types.Mana]:
		return success
	
	if cost_display.has(ActionsNodeChamp.cost_types.Health) and health_source < cost_display[cost_types.Health]:
		return success
		
	success = true
	return success
	
func pay_resource_cost():
	if not isEnemy:
		if cost_display.has(ActionsNodeChamp.cost_types.Mana):
			GameInfo.playerMana -= cost_display[ActionsNodeChamp.cost_types.Mana]
		if cost_display.has(ActionsNodeChamp.cost_types.Health):
			GameInfo.playerHealth -= cost_display[ActionsNodeChamp.cost_types.Mana]
	else:
		if cost_display.has(ActionsNodeChamp.cost_types.Mana):
			GameInfo.enemyMana -= cost_display[ActionsNodeChamp.cost_types.Mana]
		if cost_display.has(ActionsNodeChamp.cost_types.Health):
			GameInfo.enemyHealth -= cost_display[ActionsNodeChamp.cost_types.Mana]

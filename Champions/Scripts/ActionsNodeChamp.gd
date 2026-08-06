extends ActionsNode
class_name ActionsNodeChamp

enum cost_types {None, Mana, Health}

@export var action_name = ''
@export_multiline() var action_description = ''
@export var level = 1
@export var texture:Texture
@export var cost_display:Dictionary[cost_types, int] = {}

## If this is true, this action can only be used once per turn.
@export var one_use = true
var used = false

func turn_start_update():
	used = false

func handleCast() -> bool:
	var success := false
	
	if not check_resources_available():
		return success

	for child in get_children():
		if child is OnCastTrigger:
			if await child.execute(null):
				success = true

	pay_resource_cost()
	
	used = true
	
	return success
	
func check_resources_available() -> bool:
	var success = false
	var mana_source = GameInfo.enemyMana
	var health_source = GameInfo.enemyMana
	
	if not isEnemy:
		mana_source = GameInfo.playerMana
		health_source = GameInfo.playerMana
	
	if cost_display.is_empty():
		return true
	
	if cost_display.has(ActionsNodeChamp.cost_types.Mana) and mana_source < cost_display[cost_types.Mana]:
		return success
	
	if cost_display.has(ActionsNodeChamp.cost_types.Health) and health_source < cost_display[cost_types.Health]:
		return success
	
	success = true
	return success

func createActionText() -> Array:
	var string = action_description
	var expr = Expression.new()
	var error = expr.parse(string)
	if expr.has_execute_failed():
		print(error)
		return action_description
	else:
		var result = expr.execute([], self)
		if not result:
			return [action_description]
		
		return [result]
		

func pay_resource_cost():
	if cost_display.is_empty():
		return
	if not isEnemy:
		if cost_display.has(ActionsNodeChamp.cost_types.Mana):
			GameInfo.playerMana -= cost_display[ActionsNodeChamp.cost_types.Mana]
		if cost_display.has(ActionsNodeChamp.cost_types.Health):
			GameInfo.playerHealth -= cost_display[ActionsNodeChamp.cost_types.Health]
	else:
		if cost_display.has(ActionsNodeChamp.cost_types.Mana):
			GameInfo.enemyMana -= cost_display[ActionsNodeChamp.cost_types.Mana]
		if cost_display.has(ActionsNodeChamp.cost_types.Health):
			GameInfo.enemyHealth -= cost_display[ActionsNodeChamp.cost_types.Health]

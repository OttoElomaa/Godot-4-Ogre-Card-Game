extends Control
class_name ChampActionButton

var parent: Champion = null
var bound_action: ActionsNodeChamp = null
var isEnemy:bool = false

func setup(parent_champ:Champion, action:Node):
	parent = parent_champ
	bound_action = action
	isEnemy = parent_champ.isEnemyCard
	
	## If the action belongs to an enemy, it cannot be used
	$Button.disabled = isEnemy
	
	$Button.texture_normal = bound_action.texture
	
	if not bound_action.cost_display.is_empty():
		if bound_action.cost_display.has(bound_action.cost_types.Mana):
			%ManaCostTexture.show()
			%Cost.show()
			%ActionName.text = bound_action.action_name
			%Cost.text = str(bound_action.cost_display[bound_action.cost_types.Mana])
	$Button.tooltip_text += str(bound_action.action_name, '\n') 
	for i in bound_action.createActionText():
		$Button.tooltip_text += i
	if isEnemy:
		%ActionName.position.y = 63.0
	else:
		%ActionName.position.y = -26.0
	
	
func _on_button_pressed():
	if not isEnemy:
		bound_action.handleCast()

func get_cast_success() -> bool:
	var success = false
	
	if isEnemy:
		return success
	
	if bound_action.cost_display.has(ActionsNodeChamp.cost_types.Mana) and GameInfo.playerMana < bound_action.cost_display[bound_action.cost_types.Mana]:
		return success
	
	if bound_action.cost_display.has(ActionsNodeChamp.cost_types.Health) and GameInfo.playerHealth < bound_action.cost_display[bound_action.cost_types.Health]:
		return success
		
	success = true
	return success

func _on_button_mouse_entered():
	%ActionName.show()

func _on_button_mouse_exited():
	%ActionName.hide()

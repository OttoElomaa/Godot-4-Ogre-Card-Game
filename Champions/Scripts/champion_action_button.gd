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
	
	
func _on_button_pressed():
	bound_action.handleCast()

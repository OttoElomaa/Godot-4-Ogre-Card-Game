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
	
	if bound_action.cost_display.has(bound_action.cost_types.Mana):
		%ManaCostTexture.show()
		%Cost.show()
		%Cost.text = str(bound_action.cost_display[bound_action.cost_types.Mana])
	%ActionName.text = bound_action.action_name
	$Button.tooltip_text += str(bound_action.action_name, '\n') 
	for i in bound_action.createActionText():
		$Button.tooltip_text += i
	
	
func _on_button_pressed():
	if not isEnemy:
		bound_action.handleCast()

func _on_button_mouse_entered():
	%NameBox.show()

func _on_button_mouse_exited():
	%NameBox.hide()

extends HBoxContainer
class_name ChampSkillContainer

func setup(action:ActionsNodeChamp):
	
	%SkillTexture.texture = action.texture
	
	if not action.cost_display.is_empty():
		if action.cost_display.has(action.cost_types.Mana):
			%ManaCostTexture.show()
			%Cost.show()
			%Cost.text = str(action.cost_display[action.cost_types.Mana])
			
	%ActionName.text = action.action_name
	%SkillTexture.tooltip_text += str(action.action_name, '\n') 
	
	for i in action.createActionText():
		%SkillTexture.tooltip_text += i

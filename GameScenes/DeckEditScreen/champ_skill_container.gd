@tool
extends HBoxContainer
class_name ChampSkillContainer

@export var show_description = false:
	set(value):
		show_description = value
		$VSeparator.visible = show_description
		%SkillDescription.visible = show_description

func setup(action:ActionsNodeChamp):
	
	%SkillTexture.texture = action.texture
	
	if not action.cost_display.is_empty():
		if action.cost_display.has(action.cost_types.Mana):
			%ManaCostTexture.show()
			%Cost.text = str(action.cost_display[action.cost_types.Mana])
			
	%ActionName.text = action.action_name
	%SkillTexture.tooltip_text += str(action.action_name, '\n') 
	
	for i in action.createActionText():
		%SkillTexture.tooltip_text += i
		%SkillDescription.append_text(i)

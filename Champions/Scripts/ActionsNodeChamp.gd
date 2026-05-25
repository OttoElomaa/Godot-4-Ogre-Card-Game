extends ActionsNode
class_name ActionsNodeChamp

enum cost_types {None, Mana, Health}

@export var action_name = ''
@export var level = 1
@export var texture:Texture
@export var cost_display:Dictionary[cost_types, int] = {}

func handleCast() -> bool:
	var success := false

	for child in get_children():
		if child is OnCastTrigger:
			if await child.execute(null):
				success = true

	return success
	

extends ScalingComponent

func get_scaling(_args: Dictionary) -> int:
	var action = _args['action']
	var actions_node:ActionsNodeChamp = action.get_parent().get_parent()
	
	return actions_node.level

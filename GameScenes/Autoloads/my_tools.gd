extends Node2D



func checkNodeValidity(node) -> bool:
	
	if not node:
		return false
	if not is_instance_valid(node):
		return false
	if node.is_queued_for_deletion():
		return false
	#### SPECIFIC TO CARDS
	if node is Card:
		if not node.checkAlive():
			return false
	
	return true

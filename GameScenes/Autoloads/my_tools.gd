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


func handlePlaceCardInSlot(card:Card, slot:CardSlot):
	
	var cardManager = get_tree().get_first_node_in_group("cardManager")
	cardManager.handlePlaceCardInSlot(card, slot)



func findEmptyCardSlots(isEnemy) -> Array:
	
	#### GET SLOTS
	var board = get_tree().get_first_node_in_group("gameboard")
	var slots := []
	var emptySlots := []
	
	if isEnemy:
		slots = board.getEnemySlots()
	else:
		slots = board.getPlayerSlots()
	
	#### GET EMPTY SLOTS
	for slot:CardSlot in slots:
		if slot.isAvailable:
			emptySlots.append(slot)
	
	return emptySlots
	
	
	
	
	
	

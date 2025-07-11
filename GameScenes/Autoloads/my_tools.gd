extends Node2D


var gameBoard:GameBoard = null
var cardsManager:Node = null
var battleSystem:Node = null


func gameBoardSetup(gameBoard:GameBoard):
	self.gameBoard = gameBoard
	self.cardsManager =gameBoard.cardsManager
	self.battleSystem = gameBoard.battleSystem



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
	
	#var cardManager = get_tree().get_first_node_in_group("cardManager")
	cardsManager.handlePlaceCardInSlot(card, slot)



func findEmptyCardSlots(isEnemy) -> Array:
	
	#### GET SLOTS
	#var board = get_tree().get_first_node_in_group("gameboard")
	var slots := []
	var emptySlots := []
	
	if isEnemy:
		slots = gameBoard.getEnemySlots()
	else:
		slots = gameBoard.getPlayerSlots()
	
	#### GET EMPTY SLOTS
	for slot:CardSlot in slots:
		if slot.isAvailable:
			emptySlots.append(slot)
	
	return emptySlots
	


func handleCardHover(isHovering:bool, card:Card):
	if States.gameState == States.GameStates.BESTIARY:
		pass
	else:
		cardsManager.toggleCardHover(isHovering, card)
	


func handleDrawCard(isEnemy:bool):	
	cardsManager.checkIsEnemyAnddrawCard(isEnemy)


func changeMana(amount:int, isEnemy:bool):
	gameBoard.changeMana(amount, isEnemy)
	


func getBoardCards(isEnemy:bool):
	
	if isEnemy:
		return cardsManager.getEnemyBoardCards()
	else:
		return cardsManager.getPlayerBoardCards()



func updateBoardCardsVisuals():
	for c:Card in getBoardCards(true):
		c.updateCardVisuals()
	for c:Card in getBoardCards(false):
		c.updateCardVisuals()


	

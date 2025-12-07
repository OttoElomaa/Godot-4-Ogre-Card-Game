extends Node2D


var COLLISION_MASK_CARD := 1

var gameBoard:GameBoard = null
var cardsManager:CardsManager = null
var battleSystem:BattleSystem = null
var genericCard:Card = preload("res://Cards/GreenDefiance/Cr-Maolmona.tscn").instantiate()

@onready var GameBoardScene: PackedScene = preload("res://GameScenes/GameBoard/GameBoard.tscn")

var zoomVector:Vector2:
	get:
		if gameBoard:
			return gameBoard.cameraMainBoard.zoom
		return Vector2.ZERO
		


func gameBoardSetup(gameBoard:GameBoard):
	self.gameBoard = gameBoard
	self.cardsManager = gameBoard.cardsManager
	self.battleSystem = gameBoard.battleSystem

func get_all_game_cards():
	var path = 'res://Cards/City/'
	for file in DirAccess.get_files_at(path):
		var new_card = load(str(path, file))
		GameInfo.all_cards.append(new_card.instantiate())
	path = 'res://Cards/Desert/'
	for file in DirAccess.get_files_at(path):
		var new_card = load(str(path, file))
		GameInfo.all_cards.append(new_card.instantiate())
	path = 'res://Cards/Outcasts/'
	for file in DirAccess.get_files_at('res://Cards/Outcasts/'):
		var new_card = load(str(path, file))
		GameInfo.all_cards.append(new_card.instantiate())
	path = 'res://Cards/GreenDefiance/'
	for file in DirAccess.get_files_at('res://Cards/GreenDefiance/'):
		var new_card = load(str(path, file))
		GameInfo.all_cards.append(new_card.instantiate())


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



func moveCardTweening(c:Card, originalPos:Vector2, newPos:Vector2):
	c.position = originalPos
	var tween = get_tree().create_tween()
	tween.tween_property(c, "position", newPos, 0.2)
	await tween.finished



#### CAN BE USED BY SUMMON ABILITIES, DEBUG MENU, ETC
func summonCard(card:Card, isEnemy:bool) -> bool:
	var slots:Array = findEmptyCardSlots(isEnemy)
	
	if not slots.is_empty():
		var slot = slots[0]
		
		await handlePlaceCardInSlot(card, slot)
#		card.setup(gameBoard)
#		changeMana(card.manaCost, isEnemy)
		return true
		
	return false

#### CAN BE USED FOR FUNCTIONS THAT ACCESS A CARD'S CHILDREN W/O SUMMONING THE CARD
#### LIKE TRANSFORMING ONE CARD INTO A NEW ONE
func createTempCard(card:Card):
	add_child(card)

func removeTempCard(card:Card):
	remove_child(card)
	card.queue_free()

func shuffleToDeck(card:Card, isEnemy:bool):
	cardsManager.moveToDeck(card, isEnemy)


func addCardToHand(card:Card, isEnemy:bool):
	cardsManager.moveToHand(card, isEnemy)


func addCardToGraveyard(card:Card, isEnemy:bool):
	cardsManager.moveToDiscard(card, isEnemy)	
	

func handlePlaceCardInSlot(card:Card, slot:CardSlot):
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


#### MOUSE CLICK HANDLING
############################################################	

func fetchMouseOverObjects(collisionMask: int):
		
	#### WORLD STATE
	var spaceState = get_world_2d().direct_space_state
	#### MOUSE POSITION
	var params = PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collision_mask = collisionMask
	
	#### INTERSECT THEM
	var result = spaceState.intersect_point(params)
	return result

func getCollidedObject(result):
	return result.collider.get_parent()


#### MOUSE HOVER
##########################################################

func handleCardHover(isHovering:bool, card:Card):
	if States.gameState == States.GameStates.BESTIARY:
		card.mainMenu.toggleCardInfo(isHovering, card)
	else:
		cardsManager.toggleCardHover(isHovering, card)
	

######################################################

func handleDrawCard(isEnemy:bool):	
	cardsManager.checkIsEnemyAnddrawCard(isEnemy)



func changeMana(amount:int, isEnemy:bool):
	print('Generated ', amount, ' mana')
	gameBoard.changeMana(amount, isEnemy)


func changeHealth(amount:int, isEnemy:bool):
	gameBoard.changeHealth(amount, isEnemy)
	

#### CARD GETTERS
####################################################

func getBoardCards(isEnemy:bool):
	
	if isEnemy:
		return cardsManager.getEnemyBoardCards()
	else:
		return cardsManager.getPlayerBoardCards()

func getAllBoardCards() -> Array:
	var fullBoard = []
	fullBoard.append_array(cardsManager.getEnemyBoardCards())
	fullBoard.append_array(cardsManager.getPlayerBoardCards())
	return fullBoard

func getDeckCards(isEnemy:bool):
	if isEnemy:
		return cardsManager.getEnemyDeckCards()
	else:
		return cardsManager.getPlayerDeckCards()

func getAllDeckCards():
	var allDecks = []
	allDecks.append_array(cardsManager.getEnemyDeckCards())
	allDecks.append_array(cardsManager.getPlayerDeckCards())
	return allDecks

func getAllHandCards():
	var allHands = []
	allHands.append_array(cardsManager.getEnemyHandCards())
	allHands.append_array(cardsManager.getPlayerHandCards())
	return allHands

func getAllGraveyards():
	var allGraveyards = []
	allGraveyards.append_array(cardsManager.getEnemyGraveyardCards())
	allGraveyards.append_array(cardsManager.getPlayerGraveyardCards())
	return allGraveyards
	
## Accepts Card. Returns 'Foe' if card is an enemy card, 'Allied' if card is an ally card. 
func getFactionString(card:Card) -> String:
	if card.isEnemyCard:
		return 'Foe'
	else: 
		return 'Allied'

#####################################################	


func updateBoardCardsVisuals():
	gameBoard.updateResourceLabelsHelp()
	
	for c:Card in getBoardCards(true):
		c.updateCardVisuals()
	for c:Card in getBoardCards(false):
		c.updateCardVisuals()



func placeCardsInSlotArray(cards:Array, slots:Array) -> Array:
	
	var counter := 0
	var card:Card = null
	var placedCards := []
	
	for slot:CardSlot in slots:
		if counter < cards.size():
			card = cards[counter]
			card.position = slot.position
			placedCards.append(card)
			counter += 1
	
	return placedCards



func createGenericPlayerDeck():
	return $CardLoader.createDesertDeck()

	

func createCombatLogPrintout(text:String, color:Color):
	if not gameBoard:
		return
	gameBoard.addLogMessage(text, color)
	


func toggleCardActionMenu(enable:bool, card:Card):
	gameBoard.toggleCardActionMenu(enable, card)

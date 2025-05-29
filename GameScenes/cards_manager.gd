extends Node2D


var COLLISION_MASK_CARD := 1
var COLLISION_MASK_CARD_SLOT := 2

var STARTING_HAND_SIZE := 4

var CARD_NORMAL_SCALE := Vector2(1,1)
var CARD_HIGHLIGHTED_SCALE := Vector2(1.2, 1.2)

@onready var CardOgre: PackedScene = preload("res://Cards/Creatures/Cr-Ogre.tscn")
@onready var CardPikeman: PackedScene = preload("res://Cards/Creatures/Cr-Pikeman.tscn")
@onready var CardRukRaider: PackedScene = preload("res://Cards/Creatures/Cr-RukRaider.tscn")


var main:GameBoard = null
var battleSystem:Node = null

var screenSize:Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

var currentDraggedCard:Card = null
var currentHoveredCards = []

var dumbHandDrawCounter := 0


func _ready() -> void:
	screenSize = get_viewport_rect()



func setup():	
	dealPlayerHand()
	dealEnemyHand()
	


func dealPlayerHand():
	dumbHandDrawCounter = 0
	for i in range(STARTING_HAND_SIZE):
		drawCard($PlayerDeck, $PlayerHand)
		dumbHandDrawCounter += 1
	updateHandCardsVisuals()


func dealEnemyHand():
	dumbHandDrawCounter = 0
	for i in range(STARTING_HAND_SIZE):
		var card:Card = drawCard($EnemyDeck, $EnemyHand)
		dumbHandDrawCounter += 1
		
		card.toggleEnemyStatus(true)
		card.removeMouseInteraction()
		card.toggleFrontSide(false)
	updateHandCardsVisuals()

		

func drawCard(sourceDeck:Node,targetHand:Node):
	
	if sourceDeck.get_child_count() < 1:
		assert(1==2,"testing launch crash 2")
		return
		
	var cardScene = sourceDeck.get_child(0)	
	cardScene.cardsManager = self	
	
	cardScene.reparent(targetHand)
	#assert(1==2,"testing launch crash")
	return cardScene


	
#### OFFSETS, SHOW MANA COSTS, ETC.
func updateHandCardsVisuals():
	var x_offset := 0
	for c in $PlayerHand.get_children():
		c.position = $PlayerHandPosition.position + Vector2(x_offset, 0)
		x_offset += 180
		c.toggleManaCostIndicator(true)
		c.toggleActionStateIndicator(false)
	
	x_offset = 0
	for c in $EnemyHand.get_children():
		c.position = $EnemyHandPosition.position + Vector2(x_offset, 0)
		#c.scale = Vector2(0.6, 0.6)
		x_offset += 80
	


func _physics_process(delta: float) -> void:
	
	#### MOVE CARD THAT WAS SELECTED FOR DRAGGING
	var c = currentDraggedCard
	if c:
		c.position = get_global_mouse_position()
		#c.position.x = clamp(c.position.x, screenSize.position.x, screenSize.end.x)
		#c.position.y = clamp(c.position.y, screenSize.position.y, screenSize.end.y)
	
	#### HIGHLIGHT A CARD ON HOVER -> Not when mouse over a stack of cards
	if currentHoveredCards.size() == 1:
		var card = currentHoveredCards[0]
		toggleCardHighlight(card, true)
		


func _input(e: InputEvent) -> void:
	#### ONLY PROCESS 'PLAY' STATE HERE
	if States.gameState != States.GameStates.PLAY:
		return
	
	if e is InputEventMouseButton: 
		if e.is_pressed():
			if e.button_index == MOUSE_BUTTON_LEFT:
				if currentDraggedCard:
					currentDraggedCard = finishDraggingCard()
				else:
					startDraggingCardOrAttack()
					
				print("left clikc")	
				prints("dragged card: ", currentDraggedCard)
				
			elif e.button_index == MOUSE_BUTTON_RIGHT:
				var card = fetchCardOnClick()
				if MyTools.checkNodeValidity(card):
					main.toggleCardActionMenu(true, card)
			
		#elif e.is_released():
			#print("left relese")




func startDraggingCardOrAttack():
	var card:Card = fetchCardOnClick()
	#### CHECK IF DRAGGING IS ALLOWED
	if not card:
		return
	if not card.checkInteractAllowed():
		return
	
	#### ONLY IF IT'S NOT SLOTTED	
	if not card.mySlot:
		currentDraggedCard = card
		
	#### SLOTTED CARDS WILL ATTACK INSTEAD
	else:
		currentDraggedCard = null
		battleSystem.togglePlayerAttackMode(true, card)
		
		

func finishDraggingCard() -> Node:
	var success := false
	
	#### FIND CARD SLOT
	var results = main.fetchMouseOverObjects(COLLISION_MASK_CARD_SLOT)
	if results.size() > 0:
		var selectedSlot:CardSlot = getCollidedObject(results[0])
		
		#### AVAILABLE SLOT WAS FOUND, SET CARD TO IT
		var c = currentDraggedCard
		if selectedSlot.isAvailable:
			if main.checkSlotPlayer(selectedSlot):
				if c.manaCost <= battleSystem.playerMana:
					placeCardInSlot(c, selectedSlot)
					c.reparent($PlayerBoard)
					battleSystem.playerMana -= c.manaCost
					battleSystem.updateResourceLabels()
					success = true
				
	#### CLEAR SLOT FROM CARD'S END
	if not success:
		if currentDraggedCard:
			if currentDraggedCard.mySlot:
				currentDraggedCard.mySlot.toggleAvailable(true)
				currentDraggedCard.mySlot = null
	updateHandCardsVisuals()
	return null


func placeCardInSlot(card:Card, slot:CardSlot):
	#### CARD VISUAL STUFF
	if main.checkSlotPlayer(slot):
		card.position = slot.position
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", slot.position, 0.2)
	
	card.scale = Vector2.ONE
	card.toggleFrontSide(true)
	card.toggleManaCostIndicator(false)
	
		
	#### SLOT STUFF
	card.mySlot = slot
	slot.toggleAvailable(false)
	
	#### ONLY IF CREATURE...
	if card.checkInert():
		return
	#### ...SET ACTION STATE AND TRAVEL STATE	
	card.toggleActionStateIndicator(true)
	card.toggleTraveling(true)
	if main.checkSlotEnemy(slot): #### ENEMY CARDS ATTACK BY DEFAULT, PLAYER'S CARDS PASSIVE BY DFT
		card.statesActive()
	else:
		card.statesPassive()

	

func onHoverCard(card:Card):
	prints("hover on card: ", card)
	toggleCardHighlight(card, true)
	
	main.showCardInfo(card)
	
	

func onHoverCardOff(card:Card):
	prints("hover on card off: ", card)
	toggleCardHighlight(card, false)


func toggleCardHighlight(card:Card, toHighlight:bool):
	if not MyTools.checkNodeValidity(card):
		return
			
	if toHighlight:
		if not card in currentHoveredCards:
			currentHoveredCards.append(card)	
	else:
		currentHoveredCards.erase(card)
		card.scale = CARD_NORMAL_SCALE
		card.z_index = 1
		
	if toHighlight:
		card.scale = CARD_HIGHLIGHTED_SCALE
		card.z_index = 2
		


func fetchCardOnClick() -> Card:
	#### GET CARDS AT MOUSE POSITION
	var result = main.fetchMouseOverObjects(COLLISION_MASK_CARD)
	if result.size() > 0:
		var topCard = getCollidedObject(result[0])
		
		#### GET TOPMOST CARD IF CARDS ARE ON TOP OF EACH OTHER
		for c in result:
			var try = getCollidedObject(c)
			if try is Card:
				if try.z_index > topCard.z_index:
					topCard = try
		
		#### MAKE SURE NOTHING NON-CARD WAS SELECTED
		if topCard is Card:
			return(topCard)
		
	return null




func getCollidedObject(result):
	return result.collider.get_parent()
	


func connectCardSignal(card:Card):
	card.connect("hoverOn", onHoverCard)
	card.connect("hoverOff", onHoverCardOff)

####################################################

func startPlayerTurn():
	main.showPlayerTurnPopup()
	wakeBoardCards($PlayerBoard)
	drawCard($PlayerDeck, $PlayerHand)
	updateHandCardsVisuals()


func startEnemyTurn():
	wakeBoardCards($EnemyBoard)
	var newCard = drawCard($EnemyDeck, $EnemyHand)
	newCard.toggleEnemyStatus(true)
	newCard.toggleFrontSide(false)
	updateHandCardsVisuals()


func wakeBoardCards(board:Node):
	for c:Card in board.get_children():
		c.turnStartReset()
		c.toggleTraveling(false)
		c.wake()


		
####################################################

func getEnemyHandCards() -> Array:
	var cards = $EnemyHand.get_children()
	return findValidNodesInArray(cards)


func getEnemyBoardCards() -> Array:
	var cards = $EnemyBoard.get_children()
	return findValidNodesInArray(cards)


func getPlayerBoardCards() -> Array:
	var cards = $PlayerBoard.get_children()
	return findValidNodesInArray(cards)
	



func getPlayerBlockers():
	var blockers := []
	for c:Card in getPlayerBoardCards():
		if c.checkCanBlock():
			blockers.append(c)
	return blockers
				
	

func getEnemyBlockers():
	var blockers := []
	for c:Card in getEnemyBoardCards():
		if c.checkCanBlock():
			blockers.append(c)
	return blockers	
	

func findValidNodesInArray(cards:Array):
	var validCards := []
	for c in cards:
		if MyTools.checkNodeValidity(c):
			validCards.append(c)
	return validCards


func moveToDiscard(card:Card):
	card.reparent($Discard)
	card.position = Vector2.ZERO

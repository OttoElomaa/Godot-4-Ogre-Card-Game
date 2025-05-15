extends Node2D


var COLLISION_MASK_CARD := 1
var COLLISION_MASK_CARD_SLOT := 2

var MAX_HAND_SIZE := 7

@onready var CardOgre: PackedScene = preload("res://Cards/Creatures/Cr-Ogre.tscn")
@onready var CardPikeman: PackedScene = preload("res://Cards/Creatures/Cr-Pikeman.tscn")


var main:Node = null
var battleSystem:Node = null

var screenSize:Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

var currentDraggedCard:Card = null
var currentHoveredCards = []

var dumbHandDrawCounter := 0


func _ready() -> void:
	screenSize = get_viewport_rect()
	
	dealPlayerHand()
	dealEnemyHand()
	


func dealPlayerHand():
	dumbHandDrawCounter = 5
	for i in range(MAX_HAND_SIZE):
		drawCard($PlayerHand)	
	updatePlayerHandVisuals()


func dealEnemyHand():
	dumbHandDrawCounter = 0
	for i in range(MAX_HAND_SIZE):
		var card:Card = drawCard($EnemyHand)
		dumbHandDrawCounter += 1
		
		card.toggleEnemyStatus(true)
		card.removeMouseInteraction()
		card.toggleFrontSide(false)
	updatePlayerHandVisuals()

		

func drawCard(targetHand:Node2D):
	
	var cardScene = CardOgre.instantiate()
	#if randi_range(0,5) > 2:
	if dumbHandDrawCounter < 1:
		cardScene = CardPikeman.instantiate()
	elif randi_range(0,5) > 3:
		cardScene = CardPikeman.instantiate()
	targetHand.add_child(cardScene)
	return cardScene

	
#### OFFSETS, SHOW MANA COSTS, ETC.
func updatePlayerHandVisuals():
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
		if not MyTools.checkNodeValidity(card):
			return
		#if card == checkMouseOverCard():
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2


func _input(e: InputEvent) -> void:
	
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
				main.toggleCardActionMenu(true, fetchCardOnClick() )
			
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
	updatePlayerHandVisuals()
	return null


func placeCardInSlot(card:Card, slot:CardSlot):
	#### CARD VISUAL STUFF
	card.position = slot.position
	card.scale = Vector2.ONE
	card.toggleFrontSide(true)
	card.toggleManaCostIndicator(false)
	card.toggleActionStateIndicator(true)
	
	#### SLOT STUFF, AND TAP CARD
	card.mySlot = slot
	slot.toggleAvailable(false)
	card.toggleTraveling(true)
	card.statesActive()

	

func onHoverCard(card:Card):
	prints("hover on card: ", card)
	toggleCardHighlight(card, true)
	

func onHoverCardOff(card:Card):
	prints("hover on card off: ", card)
	toggleCardHighlight(card, false)


func toggleCardHighlight(card:Card, toHighlight:bool):
	if toHighlight:
		currentHoveredCards.append(card)	
	else:
		currentHoveredCards.erase(card)
		card.scale = Vector2(1, 1)
		card.z_index = 1
		
	if toHighlight:
		if currentHoveredCards.size() == 1:
			card.scale = Vector2(1.05, 1.05)
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
	drawCard($PlayerHand)
	updatePlayerHandVisuals()


func wakePlayerCards():
	for c:Card in $PlayerBoard.get_children():
		if c.statesTurnOffTravel():
			pass
		else:
			c.wake()
	
func wakeEnemyCards():
	for c:Card in $EnemyBoard.get_children():
		if c.statesTurnOffTravel():
			pass
		else:
			c.wake()
		

####################################################

func getEnemyHandCards() -> Array:
	return $EnemyHand.get_children()


func getEnemyBoardCards() -> Array:
	return $EnemyBoard.get_children()
	
	
	

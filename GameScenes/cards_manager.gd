extends Node2D
class_name  CardsManager


var COLLISION_MASK_CARD := 1
var COLLISION_MASK_CARD_SLOT := 2

var STARTING_HAND_SIZE := 4

var CARD_NORMAL_SCALE := Vector2(1,1)
var CARD_HIGHLIGHTED_SCALE := Vector2(1.25, 1.25)



var main:GameBoard = null
var battleSystem:BattleSystem = null

var screenSize:Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

var currentDraggedCard:Card = null
var currentHoveredCards = []

var dumbHandDrawCounter := 0
var mainCardInfoShown := false
var hoverCheckNeeded := false

var graveyardVisible := false



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

		

func checkIsEnemyAnddrawCard(isEnemy:bool):
	if isEnemy:
		drawCard($EnemyDeck, $EnemyHand)
	else:
		drawCard($PlayerDeck, $PlayerHand)


func drawCard(sourceDeck:Node,targetHand:Node):
	
	if sourceDeck.get_child_count() < 1:
		assert(1==2,"testing launch crash 2")
		return
		
	var cardScene = sourceDeck.get_child(0)	
	cardScene.cardsManager = self	
	cardScene.reparent(targetHand)
	
	if sourceDeck == $EnemyDeck:
		cardScene.toggleEnemyStatus(true)
		cardScene.toggleFrontSide(false)
	updateHandCardsVisuals()
	
	return cardScene


	
#### OFFSETS, SHOW MANA COSTS, ETC.
func updateHandCardsVisuals():
	
	#### PLAYER HAND STUFF #################################
	#### BASELINE: 4 CARDS ON RIGHT SIDE OF PORTRAIT
	var x_offset := 0
	var offsetChange := 200
	var x_gap_amount := 400   ## GAP, Then 3 CARDS ON LEFT SIDE
	var increment := 1
	var incrementTreshold := 4
	
	var cards:Array = $PlayerHand.get_children()
	
	#### IF MORE THAN 7 HAND CARDS: 6 CARDS ON RIGHT SIDE, 4 ON LEFT
	if cards.size() > 7:
		offsetChange = 140    ## CARDS CLOSER TOGETHER
		incrementTreshold = 6
		x_offset -= 100
	
	#### PLACE EACH CARD IN PLAYER HAND
	for c:Card in cards:
		if c.checkAlive():
			c.position = $PlayerHandPosition.position + Vector2(x_offset, 0)
			x_offset += offsetChange
			if increment == incrementTreshold:
				x_offset += x_gap_amount
			
			c.statesHand()
			c.updateCardVisuals()
			increment += 1
	
	x_offset = 0
	for c in $EnemyHand.get_children():
		c.position = $EnemyHandPosition.position + Vector2(x_offset, 0)
		#c.scale = Vector2(0.6, 0.6)
		x_offset += 80
	
	
	
#c.position.x = clamp(c.position.x, screenSize.position.x, screenSize.end.x)
#c.position.y = clamp(c.position.y, screenSize.position.y, screenSize.end.y)


func _physics_process(delta: float) -> void:
	
	if States.gameState == States.GameStates.NONE:
		return
	
	#### MOVE CARD THAT WAS SELECTED FOR DRAGGING
	var c = currentDraggedCard
	if c:
		c.position = get_global_mouse_position()
		
	#### HIGHLIGHT A CARD ON HOVER -> Not when mouse over a stack of cards
	#### CHECK IS INITIATED Only on HOVER ON/OFF. -> turns on HoverCheckNeeded
	if hoverCheckNeeded:
		if not currentDraggedCard and not currentHoveredCards.is_empty(): #### TURN These Checks OFF WHEN DRAGGING
			
			#### TURN OFF HIGHLIGHT For All Cards In Stack EXCEPT TOP CARD (Last Index)
			var lastIndex := currentHoveredCards.size() - 1
			for i in range(currentHoveredCards.size()):
				if i != lastIndex:
					toggleHighlightTwo(false, currentHoveredCards[i])
			
			#### TURN ON HIGHLIGHT For TOP CARD		
			var card = currentHoveredCards[lastIndex]
			toggleHighlightTwo(true, card)
			
			#### SHOW TOP CARD'S INFO, TURN OFF HOVER CHECK
			mainCardInfoShown = true
			main.toggleCardInfo(true, card)
			hoverCheckNeeded = false
	
	#### THIS HIDES CARD INFO WHEN NO CARDS ARE HOVERED -> No need for info panel
	if mainCardInfoShown:
		if currentHoveredCards.is_empty():
			mainCardInfoShown = false
			main.toggleCardInfo(false, null)


func _input(e: InputEvent) -> void:
	#### ONLY PROCESS 'PLAY' STATE HERE
	if States.gameState != States.GameStates.PLAY:
		return
	
	#### CLICK PROCESSING
	if e is InputEventMouseButton: 
		if e.is_pressed():
			
			#### LEFT CLICK PROCESSING
			if e.button_index == MOUSE_BUTTON_LEFT:
				if currentDraggedCard:
					currentDraggedCard = handleFinishDraggingCard()
				else:
					startDraggingCardOrAttack()
					
				print("left clikc")	
				prints("dragged card: ", currentDraggedCard)
			
			#### RIGHT CLICK PROCESSING -> CARD ACTION MENU	
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
		card.z_index = 5
		
	#### SLOTTED CARDS WILL ATTACK INSTEAD
	else:
		currentDraggedCard = null
		battleSystem.togglePlayerAttackMode(true, card)
		
		

func handleFinishDraggingCard() -> Node:
	var success := false
	var c = currentDraggedCard
	
	#################################################
	#### HANDLE RITUAL USE CASE
	var resultCards:Array = main.fetchMouseOverObjects(COLLISION_MASK_CARD)
	var target:Card = null
	
	
	#### GET CARDS UNDER MOUSE WHEN DRAGGING FINISHED
	if not resultCards.is_empty():
		for res in resultCards:
			if not getCollidedObject(res) == currentDraggedCard:
				target = getCollidedObject(res)
	
	#### TRIGGER RITUAL WITH OR WITHOUT TARGET FOUND			
	if c.isRitual:
		success = battleSystem.handlePlayerRitual(c, target)	
		if success:
			return
	
	#############################################################
	#### HANDLE ATTACKING
	#### FIND CARD SLOT
	var results:Array = main.fetchMouseOverObjects(COLLISION_MASK_CARD_SLOT)
	if results.size() > 0:
		var selectedSlot:CardSlot = getCollidedObject(results[0])
		
		#### CARD IS NOT SPELL: SET CARD To Found AVAILABLE SLOT
		if not c.isRitual:
			if selectedSlot.isAvailable and c.manaCost <= battleSystem.playerMana:
				if main.checkSlotPlayer(selectedSlot):
					success = handlePlaceCardInSlot(c, selectedSlot)
		
	if success:
		c.z_index = 1
			
	#### CLEAR SLOT FROM CARD'S END -> Why? What?
	if not success:
		if currentDraggedCard:
			if currentDraggedCard.mySlot:
				currentDraggedCard.mySlot.toggleAvailable(true)
				currentDraggedCard.mySlot = null
				
	updateHandCardsVisuals()
	return null




func handlePlaceCardInSlot(c:Card, slot:CardSlot):
	#### SLOT STUFF
	c.mySlot = slot
	slot.toggleAvailable(false)
	
	var originalPos = c.position	
	
	#### ANIMATE ENEMY CARD PLACEMENT -> Slides into slot	 
	if not main.checkSlotPlayer(slot):
		MyTools.moveCardTweening(c, originalPos, c.position)
		
		c.reparent($EnemyBoard)
		c.isEnemyCard = true
		battleSystem.enemyMana -= c.manaCost
	
	#### PLAYER CARD. REPARENT AND TAKE MANA COST
	else:
		c.position = slot.position
		c.reparent($PlayerBoard)
		battleSystem.playerMana -= c.manaCost
	
	#### VISUAL STUFF
	c.scale = Vector2.ONE
	c.toggleFrontSide(true)
	
	#### SET ACTION STATE AND TRAVEL STATE	
	c.toggleTraveling(true)
	
	#### DEFAULT STATE FOR PLAYER CARDS = PASSIVE
	c.setInitialActionState()
	
	
	#### SETUP AND ACTIVATE ARRIVAL TRIGGERS
	c.handleArrival()

	battleSystem.updateResourceLabels()
	main.addLogMessage("%s played on board" % c.cardName, Color.WHITE)	
	return true



func toggleCardHover(isHovering:bool, card:Card):
	if isHovering:
		prints("hover on card: ", card)
		toggleCardHighlight(card, true)
			
	else:
		prints("hover on card off: ", card)
		toggleHighlightTwo(false, card)
	
	toggleCardHighlight(card, isHovering)	
	card.toggleCardName(isHovering)	
	hoverCheckNeeded = true
	
	
	
	
	

func toggleCardHighlight(card:Card, toHighlight:bool):
	if not MyTools.checkNodeValidity(card):
		return
		#if not card.actionState == card.CardActionStates.DESTROYED:
			
	if toHighlight:
		if not card in currentHoveredCards:
			currentHoveredCards.append(card)	
	else:
		currentHoveredCards.erase(card)
		


func toggleHighlightTwo(enable:bool, card:Card):		
	if enable:
		card.scale = CARD_HIGHLIGHTED_SCALE
		card.z_index = 2
	else:
		card.scale = CARD_NORMAL_SCALE
		card.z_index = 1
		


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
	pass
	#card.connect("hoverOn", onHoverCard)
	#card.connect("hoverOff", onHoverCardOff)

####################################################

func startPlayerTurn():
	main.showPlayerTurnPopup()
	wakeBoardCards($PlayerBoard)
	handleTurnStartReset($PlayerBoard)
	handleTurnStartReset($EnemyBoard)
	
	arriveTravelingBoardCards($EnemyBoard)
	
	drawCard($PlayerDeck, $PlayerHand)
	updateHandCardsVisuals()


func startEnemyTurn():
	wakeBoardCards($EnemyBoard)
	handleTurnStartReset($EnemyBoard)
	handleTurnStartReset($PlayerBoard)
	
	arriveTravelingBoardCards($PlayerBoard)
	
	var newCard = drawCard($EnemyDeck, $EnemyHand)
	


func handleTurnStartReset(board:Node):
	for c:Card in board.get_children():
		c.handleTurnStartReset()



func wakeBoardCards(board:Node):
	#### RESETS AND CLEANUP
	for c:Card in board.get_children():
		#c.handleTurnStartReset()
		c.wake()
	#### STUFF LIKE ON-TURN-START TRIGGERS
	for c:Card in board.get_children():
		c.handleTurnStartActions()
		
	#### UPDATE ALL LABELS, IN CASE THEY WERE AFFECTED
	MyTools.updateBoardCardsVisuals()
	
		
func arriveTravelingBoardCards(board:Node):
	for c:Card in board.get_children():
		c.toggleTraveling(false)

		
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


######################################################
#### DISCARD STUFF

func handleDiscardAtDraw():
	pass
	

func handleDiscardAtTurnEnd():
	pass


#### DESTROY ANIMATION CALLS THE moveToDiscard FUNCTION
func discardCard(c:Card):
	c.destroyAndAnimate(true)
	


#### CALLED FROM DESTROY ANIMATION IN CARD NODE
func moveToDiscard(card:Card):
	
	var discardNode:Node = $Discard/Player/Cards
	if card.isEnemyCard:
		discardNode = $Discard/Enemy/Cards
	
	card.reparent(discardNode)
	card.position = Vector2.ZERO
	
	card.handleEnterGraveyard()
	updateGraveyardVisuals()
	


func updateGraveyardVisuals():
		
	#### PLACE DISCARD CARDS IN SLOTS TO DISPLAY
	var discardCards = $Discard/Player/Cards.get_children()
	var discardSlots = $Discard/Player/Slots.get_children()
	MyTools.placeCardsInSlotArray(discardCards, discardSlots)
	
	discardCards = $Discard/Enemy/Cards.get_children()
	discardSlots = $Discard/Enemy/Slots.get_children()
	MyTools.placeCardsInSlotArray(discardCards, discardSlots)



func buttonPressedToggleGraveyard() -> void:
	var mainCamera:Camera2D = main.cameraMainBoard
	var graveyardCamera := $Discard/CameraGraveyard
	
	#### DISPLAY GRAVEYARD
	if graveyardVisible:
		mainCamera.enabled = true
		graveyardCamera.enabled = false
		graveyardVisible = false
	
	#### DISPLAY MAIN GAME BOARD	
	else:
		mainCamera.enabled = false
		graveyardCamera.enabled = true
		graveyardVisible = true
	
	
	
	
	
	

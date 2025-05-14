extends Node2D


var COLLISION_MASK_CARD := 1
var COLLISION_MASK_CARD_SLOT := 2

var MAX_HAND_SIZE := 7

@onready var CardOgre: PackedScene = preload("res://Cards/Creatures/Cr-Ogre.tscn")
@onready var CardPikeman: PackedScene = preload("res://Cards/Creatures/Cr-Pikeman.tscn")


var main:Node = null
var screenSize:Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

var currentDraggedCard:Card = null
var currentHoveredCards = []


func _ready() -> void:
	main = get_parent()
	screenSize = get_viewport_rect()
	
	dealPlayerHand()
	


func dealPlayerHand():
	
	
	for i in range(MAX_HAND_SIZE):
	
		var cardScene = CardOgre.instantiate()
		if i > 2:
			cardScene = CardPikeman.instantiate()
		$PlayerHand.add_child(cardScene)
	updatePlayerHandOffsets()
		
		

func updatePlayerHandOffsets():
	var x_offset := 0
	for c in $PlayerHand.get_children():
		c.position = $PlayerHandPosition.position + Vector2(x_offset, 0)
		x_offset += 180
	


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
		#if card == checkMouseOverCard():
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2


func _input(e: InputEvent) -> void:
	
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.is_pressed():
			
			if currentDraggedCard:
				currentDraggedCard = finishDraggingCard()
			else:
				currentDraggedCard = fetchCardOnClick()
				
			print("left clikc")	
			prints("dragged card: ", currentDraggedCard)
			
		elif e.is_released():
			print("left relese")



func connectCardSignal(card:Card):
	card.connect("hoverOn", onHoverCard)
	card.connect("hoverOff", onHoverCardOff)
	

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
	


func fetchCardOnClick() -> Card:
	#### GET CARDS AT MOUSE POSITION
	var result = fetchMouseOverObjects(COLLISION_MASK_CARD)
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



func finishDraggingCard() -> Node:
	var success := false
	
	#### FIND CARD SLOT
	var results = fetchMouseOverObjects(COLLISION_MASK_CARD_SLOT)
	if results.size() > 0:
		var selectedSlot:CardSlot = getCollidedObject(results[0])
		
		#### AVAILABLE SLOT WAS FOUND, SET CARD TO IT
		if selectedSlot.isAvailable:
			if main.checkSlotPlayer(selectedSlot):
				currentDraggedCard.position = selectedSlot.position
				currentDraggedCard.mySlot = selectedSlot
				selectedSlot.toggleAvailable(false)
				success = true
				
				currentDraggedCard.reparent($PlayerBoard)
			
			
			
	#### CLEAR SLOT FROM CARD'S END
	if not success:
		if currentDraggedCard:
			if currentDraggedCard.mySlot:
				currentDraggedCard.mySlot.toggleAvailable(true)
				currentDraggedCard.mySlot = null
	
	updatePlayerHandOffsets()
	return null



func getCollidedObject(result):
	return result.collider.get_parent()

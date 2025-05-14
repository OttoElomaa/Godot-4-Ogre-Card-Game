extends Node2D




var main:Node = null
var cardsManager:Node = null

@onready var attackLine := $AttackLine
var COLLISION_MASK_CARD := 1

var attackLineShown: bool = false
var currentAttackingCard: Card = null



func _input(e: InputEvent) -> void:
	
	if e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.is_pressed():
			if States.gameState == States.GameStates.ATTACK:
				handlePlayerAttack()


func _physics_process(delta: float) -> void:
	
	if attackLineShown:
		attackLine.points[1] = get_global_mouse_position()
	


func handlePlayerAttack():
	#### GET CARDS AT MOUSE POSITION
	var results = main.fetchMouseOverObjects(COLLISION_MASK_CARD)
	if results.size() > 0:
		var target:Card = getCollidedObject(results[0])
		if main.checkSlotPlayer(target.mySlot):
			attackLineShown = false
			States.gameState = States.GameStates.PLAY


func togglePlayerAttackMode(enable:bool, card:Card):
	
	if card.checkActive():
		currentAttackingCard = card
		States.gameState = States.GameStates.ATTACK
		
		attackLineShown = enable
		attackLine.points[0] = card.position


func _on_end_turn_button_pressed() -> void:
	enemyPlayTurn()
	cardsManager.startPlayerTurn()
	

func enemyPlayTurn():
	
	var enemyHandCards = cardsManager.getEnemyHandCards()
	for card:Card in enemyHandCards:
		playEnemyCard(card)
		
				

func playEnemyCard(card:Card):
	for slot:CardSlot in main.getEnemySlots():
		if slot.isAvailable:
			cardsManager.placeCardInSlot(card, slot)
			card.reparent(cardsManager.get_node("EnemyBoard"))
			return



func getCollidedObject(result):
	return result.collider.get_parent()

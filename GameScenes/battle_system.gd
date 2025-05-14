extends Node2D




var main:Node = null
var cardsManager:Node = null

@onready var attackLine := $AttackLine
var attackLineShown: bool = false


func _physics_process(delta: float) -> void:
	
	if attackLineShown:
		attackLine.points[1] = get_global_mouse_position()
	

func togglePlayerAttackMode(enable:bool, card:Card):
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

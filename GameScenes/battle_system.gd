extends Node2D




var main:Node = null
var cardsManager:Node = null


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

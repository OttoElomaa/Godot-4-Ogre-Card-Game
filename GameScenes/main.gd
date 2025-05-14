extends Node2D


enum CardSlotTypes {
	PLAYER, ENEMY
}

enum CardStates {
	DECK, HAND, BOARD, GRAVEYARD
}

func _ready() -> void:
	
	$CardsManager.main = self
	$CardsManager.battleSystem = $BattleSystem
	
	$BattleSystem.main = self
	$BattleSystem.cardsManager = $CardsManager
	
	for slot:CardSlot in $PlayerSlots.get_children():
		slot.slotType = CardSlotTypes.PLAYER
	
	for slot:CardSlot in $EnemySlots.get_children():
		slot.slotType = CardSlotTypes.ENEMY


func checkSlotPlayer(slot:CardSlot):
	return slot.slotType == CardSlotTypes.PLAYER

func checkSlotEnemy(slot:CardSlot):
	return slot.slotType == CardSlotTypes.ENEMY


func getEnemySlots():
	return $EnemySlots.get_children()


#### USE EXIT BUTTON TO CLOSE THE GAME
func _on_exit_button_pressed() -> void:
	get_tree().quit()

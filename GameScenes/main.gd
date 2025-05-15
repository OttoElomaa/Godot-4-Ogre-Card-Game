extends Node2D


enum CardSlotTypes {
	PLAYER, ENEMY
}

enum CardStates {
	DECK, HAND, BOARD, GRAVEYARD
}

var boardName := "Old Ruins"


func _ready() -> void:
	
	$CardsManager.main = self
	$CardsManager.battleSystem = $BattleSystem
	
	$BattleSystem.main = self
	$BattleSystem.cardsManager = $CardsManager
	
	updateUi($BattleSystem.turnCount)
	
	for slot:CardSlot in $PlayerSlots.get_children():
		slot.slotType = CardSlotTypes.PLAYER
	
	for slot:CardSlot in $EnemySlots.get_children():
		slot.slotType = CardSlotTypes.ENEMY



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



func checkSlotPlayer(slot:CardSlot):
	return slot.slotType == CardSlotTypes.PLAYER

func checkSlotEnemy(slot:CardSlot):
	return slot.slotType == CardSlotTypes.ENEMY


func getEnemySlots():
	return $EnemySlots.get_children()


func updateUi(turnCount:int):
	$CanvasLayer/LevelInfoPanel/VBox/Panel/HBox/BoardNameLabel.text = boardName
	$CanvasLayer/LevelInfoPanel/VBox/Panel2/HBox/TurnCountLabel.text = "%d" % turnCount


#### USE EXIT BUTTON TO CLOSE THE GAME
func _on_exit_button_pressed() -> void:
	get_tree().quit()

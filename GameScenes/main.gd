extends Node2D
class_name GameBoard


enum CardSlotTypes {
	PLAYER, ENEMY
}

enum CardStates {
	DECK, HAND, BOARD, GRAVEYARD
}

var boardName := "Old Ruins"

var actionMenuCard: Card = null


func _ready() -> void:
	
	$CardsManager.main = self
	$CardsManager.battleSystem = $BattleSystem
	
	$BattleSystem.main = self
	$BattleSystem.cardsManager = $CardsManager
	
	var idk = 0
	var playerDeckCards:Array = $CardLoader.createDesertDeck()
	for card in playerDeckCards:
		$CardsManager/PlayerDeck.add_child(card)
		
	var enemyDeckCards:Array = $CardLoader.createDesertDeck()
	for card in enemyDeckCards:
		print("reparent success")
		$CardsManager/EnemyDeck.add_child(card)
	
	#await(get_tree().create_timer(0.2))
	
	$CardsManager.setup()
	

	#### UI STUFF
	updateUi($BattleSystem.turnCount)
	$BattleSystem.updateResourceLabels()
	toggleCardInfo(false, null)
	
	#### SET SLOTS STATUS
	for slot:CardSlot in $PlayerSlots.get_children():
		slot.slotType = CardSlotTypes.PLAYER
	for slot:CardSlot in $EnemySlots.get_children():
		slot.slotType = CardSlotTypes.ENEMY


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseButton: 
		if e.is_pressed():
			if States.gameState == States.GameStates.CARD_ACT_MENU:
				toggleCardActionMenu(false, null)


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



func toggleCardActionMenu(enable:bool, card:Card):
	
	#### TOGGLE TRUE - IF CARD FOUND,
	if enable:
		if card:
			if card.mySlot:  #### IS IT PLAYER CARD?
				if not checkSlotPlayer(card.mySlot): 
					return
				
			#### TURN ON CARD ACTION MENU
			States.gameState = States.GameStates.CARD_ACT_MENU
			actionMenuCard = card
			$ActionMenuCanvas.offset = get_global_mouse_position() * $Camera2D.zoom.x
			$ActionMenuCanvas.show()
			
			#### CAST BUTTON
			var castButton := $ActionMenuCanvas/CardActionMenu/CastPanel
			if card.castNode.checkActive():
				castButton.show()
			else:
				castButton.hide()
	
	#### TOGGLE FALSE = TOGGLE OFF
	else:
		if States.gameState == States.GameStates.CARD_ACT_MENU:
			States.gameState = States.GameStates.PLAY
		$ActionMenuCanvas.hide()




########################################################################################

func checkSlotPlayer(slot:CardSlot):
	return slot.slotType == CardSlotTypes.PLAYER

func checkSlotEnemy(slot:CardSlot):
	return slot.slotType == CardSlotTypes.ENEMY


func getEnemySlots():
	return $EnemySlots.get_children()

##################################################################

func loadRandomCard(folderPath:String) -> Node:
	
	var dir := DirAccess.open(folderPath)

	var file_names := dir.get_files()
	
	var size = file_names.size()
	var rng = randi_range(0, size - 1)
	var random_file := file_names[rng]
	
	var card:PackedScene = load(folderPath + random_file)
	return card.instantiate()


#################################################################################
#### USE EXIT BUTTON TO CLOSE THE GAME
func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_toggle_defend_button_pressed() -> void:
	actionMenuCard.switchStates()
	toggleCardActionMenu(false, null)
	



##########################################################################################

func updateUi(turnCount:int):
	toggleCardActionMenu(false, null)
	
	$CanvasLayer/LevelInfoPanel/VBox/Panel/HBox/BoardNameLabel.text = boardName
	$CanvasLayer/LevelInfoPanel/VBox/Panel2/HBox/TurnCountLabel.text = "%d" % turnCount


func updateResourceLabels(playerHealth, playerMana, enemyHealth, enemyMana):
	$Portraits/PlayerHealthLabel.text = "%d" % playerHealth
	$Portraits/PlayerManaLabel.text = "%d" % playerMana
	$Portraits/EnemyHealthLabel.text = "%d" % enemyHealth
	$Portraits/EnemyManaLabel.text = "%d" % enemyMana



func showPlayerTurnPopup():
	$Visuals/YourTurnPopup/PopupAnimation.play("ShowPopup")



func toggleCardInfo(enable:bool, card:Card):
	var cardInfo := $CanvasLayer/CardInfoPane
	
	#### HIDE
	if not enable:
		cardInfo.hide()
		return
		
	#### SHOW
	cardInfo.show()
	cardInfo.get_node("Panel/Margin/VBox/NameLabel").text = card.cardName
	cardInfo.get_node("Panel/Margin/VBox/CardArt").texture = card.cardArt
	cardInfo.get_node("Panel/Margin/VBox/EffectText").text = card.effectText
	



func addLogMessage(text:String, color:Color) -> void:
	
	$CanvasLayer/BattleLogPane.addMessage(text, color)

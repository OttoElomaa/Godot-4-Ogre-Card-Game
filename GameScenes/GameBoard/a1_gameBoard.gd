@icon("res://Art/icons/16x16/autotile.png")
extends Node2D
class_name GameBoard



@onready var cardsManager := $CardsManager
@onready var battleSystem := $BattleSystem

@onready var cameraMainBoard := $CameraMainBoard


enum CardSlotTypes {
	PLAYER, ENEMY
}

enum CardStates {
	DECK, HAND, BOARD, GRAVEYARD
}

var boardName := "Old Ruins"

var actionMenuCard: Card = null


func _ready() -> void:
	
	#### SETUP BOARD
	##################################
	States.statesPlay()
	
	$CardsManager.main = self
	$CardsManager.battleSystem = $BattleSystem
	
	$BattleSystem.main = self
	$BattleSystem.cardsManager = $CardsManager
	
	MyTools.gameBoardSetup(self)

	##################################################
	#### SETUP PLAYER CARDS
	
	var playerDeckCards:Array = GameInfo.playerDeckCards
	
	for card:Card in playerDeckCards:
		if card.is_inside_tree():
			card.reparent($CardsManager/PlayerDeck)
		else:
			$CardsManager/PlayerDeck.add_child(card)
		card.setup(self)
		card.show()
	
	#### SETUP ENEMY CARDS
	var enemyDeckCards:Array = GameInfo.enemyDeckCards
	
	for card:Card in enemyDeckCards:
		if card.is_inside_tree():
			card.reparent($CardsManager/EnemyDeck)
		else:
			$CardsManager/EnemyDeck.add_child(card)
		card.setup(self)
		card.show()
	
	$CardsManager.setup(self)
	

	###################################################
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
			$ActionMenuCanvas.offset = get_global_mouse_position() * $CameraMainBoard.zoom.x
			$ActionMenuCanvas.show()
			
			#### CAST BUTTON
			var castButton := $ActionMenuCanvas/CardActionMenu/CastPanel
			if card.actions.getCastAction() != null:
				castButton.show()
			else:
				castButton.hide()
	
	#### TOGGLE FALSE = TOGGLE OFF
	else:
		if States.gameState == States.GameStates.CARD_ACT_MENU:
			States.gameState = States.GameStates.PLAY
		$ActionMenuCanvas.hide()



func changeMana(amount:int, isEnemy:bool):
	
	if isEnemy:
		$BattleSystem.enemyMana += amount
	else:
		$BattleSystem.playerMana += amount


func changeHealth(amount:int, isEnemy:bool):
	
	if isEnemy:
		$BattleSystem.enemyHealth += amount
	else:
		$BattleSystem.playerHealth += amount



########################################################################################

func checkSlotPlayer(slot:CardSlot):
	return slot.slotType == CardSlotTypes.PLAYER

func checkSlotEnemy(slot:CardSlot):
	return slot.slotType == CardSlotTypes.ENEMY


func getEnemySlots():
	return $EnemySlots.get_children()

func getPlayerSlots():
	return $PlayerSlots.get_children()


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
	#toggleCardActionMenu(false, null)


func buttonPressedHideCardActionMenu() -> void:
	toggleCardActionMenu(false, null)

	
##########################################################################################

func updateUi(turnCount:int):
	toggleCardActionMenu(false, null)
	
	$CanvasLayer/LevelInfoPanel/VBox/Panel/HBox/BoardNameLabel.text = boardName
	$CanvasLayer/LevelInfoPanel/VBox/Panel2/HBox/TurnCountLabel.text = "%d" % turnCount


func updateResourceLabelsHelp():
	updateResourceLabels(battleSystem.playerHealth, 
	battleSystem.playerMana, battleSystem.enemyHealth, battleSystem.enemyMana)

func updateResourceLabels(playerHealth, playerMana, enemyHealth, enemyMana):
	$Portraits/PlayerHealthLabel.text = "%d" % playerHealth
	$Portraits/PlayerManaLabel.text = "%d" % playerMana
	$Portraits/EnemyHealthLabel.text = "%d" % enemyHealth
	$Portraits/EnemyManaLabel.text = "%d" % enemyMana



func showPlayerTurnPopup():
	$Visuals/YourTurnPopup/PopupAnimation.play("ShowPopup")



func toggleCardInfo(enable:bool, card:Card):
	var cardInfo := $CanvasLayer/CardInfoPane/CardInfoPanel
	cardInfo.toggleCardInfo(enable, card)
	



func addLogMessage(text:String, color:Color) -> void:
	
	$CanvasLayer/BattleLogPane.addMessage(text, color)

#################################################################
# Cheat Functions

func nuke_cards(obj):
	for child in obj.get_children():
		obj.remove_child(child)

func nuke_all_cards():
	nuke_cards($CardsManager/PlayerBoard)
	nuke_cards($CardsManager/PlayerHand)
	nuke_cards($CardsManager/EnemyHand)
	nuke_cards($CardsManager/EnemyBoard)

func add_card_to_board(to, card:Card):
	if to == 'player':
		$PlayerSlots/TableCardSlot.add_child(card)
	elif to == 'enemy':
		$CardsManager/EnemyHand.add_child(card)
	else:
		print('WTF MAN?')

@icon("res://Art/icons/16x16/autotile.png")
extends Node2D
class_name GameBoard



@onready var cardsManager : CardsManager = $CardsManager
@onready var battleSystem : BattleSystem = $BattleSystem

@onready var cameraMainBoard := $CameraMainBoard

@onready var battleNameLabel := $CanvasLayer/LevelInfoPanel/VBox/Panel/HBox/BoardNameLabel
@onready var champActionButton := preload("res://Champions/Scripts/ChampionActionButton.tscn") 

enum CardSlotTypes {
	PLAYER, ENEMY
}

enum CardStates {
	DECK, HAND, BOARD, GRAVEYARD
}

@export var boardName := "Old Ruins"

var actionMenuCard: Card = null

enum AI_personalities {
	COMMANDER, ##Default. Summon creatures -> Attack -> Use rituals 
	WIZARD, ##Ritual focus. If has a blocker, use rituals first, then summon, cast.
	SPECIALIST ##Cast focus. Summon -> Cast -> Ritual -> Attack
}

## How the enemy AI will behave.
@export_category("AI")
@export var AI_personality = AI_personalities.COMMANDER

func _ready() -> void:
	
	#### SETUP GLOBAL INFO
	##################################
	GameInfo.turnCount = 1
	
#	GameInfo.playerHealth = 20
	GameInfo.playerMana = 1
	GameInfo.playerManaIncome = 1
	
#	GameInfo.enemyHealth = 20
	GameInfo.enemyMana = 0
	GameInfo.enemyManaIncome = 0
	
	
	
	
	#### SETUP BOARD
	##################################
	States.statesPlay()
	
	setup_board()
	#### THIS FUNC SETS UP PLAYER AND ENEMY DECKS BASED ON GameInfo

#	turn_1_init()
	###################################################
	#### UI STUFF
	$CanvasLayer/GameOverPane.hide()
	
	updateUi(GameInfo.turnCount)
	updateResourceLabels()
	toggleCardInfo(false, null)
	
	#### SET SLOTS STATUS
	for slot:CardSlot in $PlayerSlots.get_children():
		slot.slotType = CardSlotTypes.PLAYER
	for slot:CardSlot in $EnemySlots.get_children():
		slot.slotType = CardSlotTypes.ENEMY


func setup_board():
	print(name, ': Game Board set up')
	$CardsManager.setup(self)
	
	$BattleSystem.main = self
	$BattleSystem.cardsManager = $CardsManager
	
	setup_champions(GameInfo.current_champion, GameInfo.enemyChampion)
	
	MyTools.gameBoardSetup(self)

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseButton: 
		if e.is_pressed():
			if States.gameState == States.GameStates.CARD_ACT_MENU:
				toggleCardActionMenu(false, null)

func setup_champions(player_champ:Champion, enemy_champ:Champion):
	%PlayerChampSlot.add_child(player_champ.duplicate())
	%EnemyChampSlot.add_child(enemy_champ.duplicate())
	
	## Set character portrait.
	%PlayerSprite.texture = player_champ.texture
	%EnemySprite.texture = enemy_champ.texture
	
	## Setup player champion.
	playerChampion().isEnemyCard = false
	playerChampion().setup(self)
	create_action_buttons(false)
	
	## Setup enemy champion.
	enemyChampion().isEnemyCard = true
	enemyChampion().setup(self)
	create_action_buttons(true)

func create_action_buttons(isEnemy:bool):
	var bound_node: Node = null
	var champion: Champion = null
	print('create action button called with ', isEnemy)
	
	if isEnemy:
		bound_node = $EnemyActionButtons
		champion = enemyChampion()
	else:
		bound_node = $PlayerActionButtons
		champion = playerChampion()

	var positions: Array = bound_node.get_children()
	var index = 0
	for action in champion.usable_actions:
		var new_button:ChampActionButton = champActionButton.instantiate()
		var marker: Marker2D = positions[index]
		new_button.setup(champion, action)
		bound_node.add_child(new_button)
		new_button.position = marker.position
		index += 1
	

func add_card_to_random_slot(card:Card, isEnemyCard:bool):
	var empty_slots = MyTools.findEmptyCardSlots(isEnemyCard)
	var slot = empty_slots.pick_random()
	cardsManager.handlePlaceCardInSlot(card, slot)

func add_card_to_enemy_deck(card:Card):
	$CardsManager/EnemyDeck.add_child(card)
	card.setup(self)

func turn_1_init():
	cardsManager.dealEnemyHand()
	cardsManager.dealPlayerHand()

func toggleCardActionMenu(enable:bool, card:Card):
	
	#### TOGGLE TRUE - IF CARD FOUND,
	if enable:
		if card:
			if card.mySlot:  #### IS IT PLAYER CARD?
				if not checkSlotPlayer(card.mySlot): 
					return
				if card.isTraveling:
					return
				if card.isResting:
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
		if GameInfo.enemyMana + amount >= 0:
			GameInfo.enemyMana += amount
		else:
			return false
	else:
		if GameInfo.playerMana + amount >= 0:
			GameInfo.playerMana += amount
		else:
			return false
	return true


func changeHealth(amount:int, isEnemy:bool):
	
	if isEnemy:
		GameInfo.enemyHealth = max(GameInfo.enemyHealth + amount, 0)
		if GameInfo.enemyHealth <= 0:
			endGame(true)
	else:
		GameInfo.playerHealth = max(GameInfo.playerHealth + amount, 0)
		if GameInfo.playerHealth <= 0:
			endGame(false)
		

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
	
	battleNameLabel.text = boardName
	if GameInfo.currentBattleInfo:
		battleNameLabel.text = GameInfo.currentBattleInfo.board_name
		
	
	$CanvasLayer/LevelInfoPanel/VBox/Panel2/HBox/TurnCountLabel.text = "%d" % GameInfo.turnCount





func updateResourceLabels():
	$Portraits/PlayerHealthLabel.text = "%d" % GameInfo.playerHealth
	$Portraits/PlayerManaLabel.text = "%d" % GameInfo.playerMana
	$Portraits/EnemyHealthLabel.text = "%d" % GameInfo.enemyHealth
	$Portraits/EnemyManaLabel.text = "%d" % GameInfo.enemyMana
	
	$Visuals/PlayerManaDisplay.updateVisual(GameInfo.playerMana, GameInfo.playerManaIncome)
	$Visuals/EnemyManaDisplay.updateVisual(GameInfo.enemyMana, GameInfo.enemyManaIncome)
	
	
			
func playerChampion() -> Champion:
	if $CardsManager/PlayerChampSlot.get_children().size() > 0:
		return $CardsManager/PlayerChampSlot.get_child(0)
	else:
		return null

func enemyChampion() -> Champion:
	if $CardsManager/EnemyChampSlot.get_children().size() > 0:
		return $CardsManager/EnemyChampSlot.get_child(0)
	else:
		return null

func playAttackPortraitAnimation(attackingCard: Card):
	var c = attackingCard
	var isEnemy = c.isEnemyCard
	var targetPos = Vector2(0,0)
	
	if isEnemy:
		targetPos = $Portraits/PlayerSprite.position
	else:
		targetPos = $Portraits/EnemySprite.position
	
	var tween = create_tween()
	tween.tween_property(c, "position", targetPos, 0.2)
	await tween.finished



func showPlayerTurnPopup():
	$Visuals/YourTurnPopup/PopupAnimation.play("ShowPopup")

func shake_screen(intensity:float, time:float):
	cameraMainBoard.screen_shake(intensity, time)

func toggleCardInfo(enable:bool, card:Card):
	var cardInfo := $CanvasLayer/CardInfoPane/CardInfoPanel
	cardInfo.toggleCardInfo(enable, card)
	

func addLogMessage(text:String, color:Color) -> void:
	
	$CanvasLayer/BattleLogPane.addMessage(text, color)

#################################################################
# Cheat Functions

func nuke_cards(isEnemy: bool):
	var obj: Node = null
	if isEnemy:
		for child in %EnemyDeck.get_children():
			obj.remove_child(child)
		for child in %EnemyHand.get_children():
			obj.remove_child(child)
	else:
		for child in %PlayerDeck.get_children():
			obj.remove_child(child)
		for child in %PlayerHand.get_children():
			obj.remove_child(child)


func nuke_all_cards():
	nuke_cards(true)
	nuke_cards(false)



func endGame(isWin:bool):
	$CanvasLayer/GameOverPane.show()
	if isWin:
		$CanvasLayer/GameOverPane/Margin/VBox/WonHeader.show()
		$CanvasLayer/GameOverPane/Margin/VBox/LostHeader.hide()
		GameInfo.playerWonBattleNames.append(battleNameLabel.text)
	else:
		$CanvasLayer/GameOverPane/Margin/VBox/WonHeader.hide()
		$CanvasLayer/GameOverPane/Margin/VBox/LostHeader.show()
		GameInfo.playerLives -= 1
		

func buttonPressedEndMatch() -> void:
	if GameInfo.currentZone:
		GameInfo.currentZone.visualsUpdateNeeded = true
		SceneSwitcher.switchToNewScene(GameInfo.currentZone)
	else:
		SceneSwitcher.returnToMainMenu()

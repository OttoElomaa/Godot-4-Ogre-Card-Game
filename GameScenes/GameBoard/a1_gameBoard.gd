@icon("res://Art/icons/16x16/autotile.png")
extends Node2D
class_name GameBoard



@onready var cardsManager : CardsManager = $CardsManager
@onready var battleSystem : BattleSystem = $BattleSystem

@onready var cameraMainBoard := $CameraMainBoard

@onready var battleNameLabel := $CanvasLayer/LevelInfoPanel/VBox/Panel/HBox/BoardNameLabel

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
	
	#### SETUP SIGNALS
	##################################

	
	#### SETUP BOARD
	##################################
	States.statesPlay()
	
	#### THIS FUNC SETS UP PLAYER AND ENEMY DECKS BASED ON GameInfo
	$CardsManager.setup(self)
	
	$BattleSystem.main = self
	$BattleSystem.cardsManager = $CardsManager
	
	MyTools.gameBoardSetup(self)
	turn_1_init()
	
	###################################################
	#### UI STUFF
	$CanvasLayer/GameOverPane.hide()
	
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



func add_card_to_random_slot(card:Card, isEnemyCard:bool):
	var empty_slots = MyTools.findEmptyCardSlots(isEnemyCard)
	var slot = empty_slots.pick_random()
	cardsManager.handlePlaceCardInSlot(card, slot)

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
		if not amount > $BattleSystem.enemyMana:
			$BattleSystem.enemyMana += amount
		else:
			return false
	else:
		if not amount > $BattleSystem.playerMana:
			$BattleSystem.playerMana += amount
		else:
			return false
	return true


func changeHealth(amount:int, isEnemy:bool):
	
	if isEnemy:
		$BattleSystem.enemyHealth = max($BattleSystem.enemyHealth + amount, 0)
		if $BattleSystem.enemyHealth <= 0:
			endGame(true)
	else:
		$BattleSystem.playerHealth = max($BattleSystem.playerHealth + amount, 0)
		if $BattleSystem.playerHealth <= 0:
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
		
	
	$CanvasLayer/LevelInfoPanel/VBox/Panel2/HBox/TurnCountLabel.text = "%d" % turnCount


func updateResourceLabelsHelp():
	updateResourceLabels(battleSystem.playerHealth, 
	battleSystem.playerMana, battleSystem.enemyHealth, battleSystem.enemyMana)


func updateResourceLabels(playerHealth, playerMana, enemyHealth, enemyMana):
	$Portraits/PlayerHealthLabel.text = "%d" % playerHealth
	$Portraits/PlayerManaLabel.text = "%d" % playerMana
	$Portraits/EnemyHealthLabel.text = "%d" % enemyHealth
	$Portraits/EnemyManaLabel.text = "%d" % enemyMana
	
	#### PLAYER MANA VISUALS
	for icon in $Portraits/ManaHBox.get_children():
		icon.queue_free()   #### CLEAR OLD ONES
	
	#### COPY FULL OR DEPLETED GEM TEXTURE	
	var iconToCopy:TextureRect = null
	for i in range(15):
		
		#### PLAYER HAS THIS MUCH MANA
		if (i+1) <= playerMana:
			if (i+1) <= battleSystem.turnCount:  #### BASIC MANA
				iconToCopy = $Portraits/ManaCopyingHBox/BlueGem
			else:  #### ABOVE MAX MANA, SHOW EXTRA MANA - GREEN
				iconToCopy = $Portraits/ManaCopyingHBox/GreenGem
				
		#### PLAYER HAS NO MORE MANA TO SHOW
		else:
			if (i+1) <= battleSystem.turnCount:  #### SHOW DEPLETED MANA MANA
				iconToCopy = $Portraits/ManaCopyingHBox/DepletedGem
			else:   #### ABOVE MAX MANA, SHOW NOTHING
				iconToCopy = null
		
		if iconToCopy:
			var newIcon = iconToCopy.duplicate()
			$Portraits/ManaHBox.add_child(newIcon)
			newIcon.show()
			


func playerChampion() -> Card:
	if $CardsManager/PlayerChampSlot.get_children().size() > 0:
		return $CardsManager/PlayerChampSlot.get_child(0)
	else:
		return null

func enemyChampion() -> Card:
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

func nuke_cards(obj):
	for child in obj.get_children():
		obj.remove_child(child)

func nuke_all_cards():
	nuke_cards($CardsManager/PlayerBoard)
	nuke_cards($CardsManager/PlayerHand)
	nuke_cards($CardsManager/EnemyHand)
	nuke_cards($CardsManager/EnemyBoard)



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

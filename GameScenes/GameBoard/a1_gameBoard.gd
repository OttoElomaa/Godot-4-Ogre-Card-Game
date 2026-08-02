@icon("res://Art/icons/16x16/autotile.png")
extends Node2D
class_name GameBoard


@onready var cardsManager : CardsManager = $CardsManager
@onready var battleSystem : BattleSystem = $BattleSystem

@onready var cameraMainBoard := $CameraMainBoard

@onready var battleNameLabel := $CanvasLayer/LevelInfoPanel/VBox/Panel/HBox/BoardNameLabel
@onready var turnCountLabel := $CanvasLayer/LevelInfoPanel/VBox/Panel2/HBox/TurnCountLabel
@onready var endTurnLabel := $CanvasLayer/EndTurnPane/VBox/EndTurn/Label

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
	turn_1_init()

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
	
	print("GameBoard: First turn!")
	


#### CALLED IN ZONE ICON SCENE  ...????
func setup_board():
	print(name, ': Game Board set up')
	$CardsManager.setup(self)
	
	$BattleSystem.main = self
	$BattleSystem.cardsManager = $CardsManager
	
	setup_champions(GameInfo.current_champion, GameInfo.enemyChampion)
	
	MyTools.gameBoardSetup(self)


#### CALLED IN ZONE ICON SCENE  ...????
func turn_1_init():
	#cardsManager.dealEnemyHand()
	#cardsManager.dealPlayerHand()
	pass



func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseButton: 
		if e.is_pressed():
			if States.gameState == States.GameStates.CARD_ACT_MENU:
				toggleCardActionMenu(false, null)

func setup_champions(player_champ:Champion, enemy_champ:Champion):
	%PlayerChampSlot.add_child(player_champ.duplicate())
	%EnemyChampSlot.add_child(enemy_champ.duplicate())
	
	## Set character portrait.
	%PlayerSprite.insert_champion(player_champ)
	%EnemySprite.insert_champion(enemy_champ)
	
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
	actionMenuCard.switchBlockingState()
	#toggleCardActionMenu(false, null)


func buttonPressedHideCardActionMenu() -> void:
	toggleCardActionMenu(false, null)

	
##########################################################################################

func updateUi(turnCount:int):
	toggleCardActionMenu(false, null)
	
	battleNameLabel.text = boardName
	if GameInfo.currentBattleInfo:
		battleNameLabel.text = GameInfo.currentBattleInfo.board_name
		
	
	turnCountLabel.text = "%d" % GameInfo.turnCount
	
	if GameInfo.enemy_turn:
		endTurnLabel.text = "Enemy Turn"
	else:
		endTurnLabel.text = "End Turn"
		
		





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



func showPlayerTurnPopup():
	$Visuals/YourTurnPopup/PopupAnimation.play("ShowPopup")

func shake_screen(intensity:float, time:float):
	cameraMainBoard.screen_shake(intensity, time)

func darken_screen(time:float):
	States.ignoreMouseInput = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'modulate', Color(0.256, 0.256, 0.256, 1.0), time)
	await tween.finished

func brighten_screen(time:float):
	States.ignoreMouseInput = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'modulate', Color(1.0, 1.0, 1.0, 1.0), time)
	await tween.finished

func unfold_ritual_container(card:Card):
	var smoke = DataLoader.animations_by_filename['smoke.tscn'].instantiate()
	var typewriter_textbox = DataLoader.animations_by_filename["temporary_textbox_fixed.tscn"].instantiate()
	var typewriter_textbox2 = DataLoader.animations_by_filename["temporary_textbox_fixed.tscn"].instantiate()
	var screen_flash = DataLoader.animations_by_filename["screen_flash.tscn"].instantiate()
	
	smoke.position += Vector2(%RitualContainer.size.x/2, %RitualContainer.size.y/2)
	
	%RitualContainer.insert_card(card.duplicate())
	%RitualContainer.material.set_shader_parameter('percentage', 1.0)
	%RitualContainer.show_name = false
	
	## Typewriter textboxes with the ritual's flavor text are set up.
	typewriter_textbox.hide()
	$AnimationLayer.add_child(typewriter_textbox)
	typewriter_textbox.text = card.flavorText
	typewriter_textbox.position.x = 200.0
	typewriter_textbox.position.y = randi_range(600, 150)
	var box_scale = randf_range(1.0, 2.0)
	typewriter_textbox.scale = Vector2(box_scale, box_scale)
	typewriter_textbox.rotation_degrees = randf_range(25, -25) 
	
	typewriter_textbox2.hide()
	$AnimationLayer.add_child(typewriter_textbox2)
	box_scale = randf_range(1.0, 3.0)
	typewriter_textbox2.text = card.flavorText
	typewriter_textbox2.position.x = 1000.0
	typewriter_textbox2.position.y = randi_range(600, 150)
	typewriter_textbox2.scale = Vector2(box_scale, box_scale)
	typewriter_textbox2.rotation_degrees = randf_range(25, -25) 
	
	## The ritual container appears offscreen, either on top or at the bottom depending on whose card it is.
	if card.isEnemyCard:
		%RitualContainer.position.y = -465.0
		%RitualContainer.face_down()
	else:
		%RitualContainer.position.y = 1650.0
	%RitualContainer.show()
	
	## The ritual container moves to the middle of the screen and the card is turned face up.
	var tween = get_tree().create_tween()
	tween.tween_property(%RitualContainer, 'position', Vector2(%RitualContainer.position.x, 400), 2).set_ease(Tween.EASE_OUT)
	await tween.finished
	$AnimationLayer.add_child(screen_flash)
	await screen_flash.tree_exited
	%RitualContainer.face_up()
	%RitualContainer.show_name = true
	typewriter_textbox.show()
	typewriter_textbox2.show()
	
	## How long the card stays face up on-screen, letting the player read its effects.
	await get_tree().create_timer(3).timeout
	%RitualContainer.add_child(smoke)
	tween = get_tree().create_tween()
	smoke.emitting = true
	tween.tween_property(%RitualContainer.material, 'shader_parameter/percentage', 0.1, 2.0)
	await tween.finished
	%RitualContainer.hide()
	smoke.queue_free()
	typewriter_textbox.queue_free()
	typewriter_textbox2.queue_free()
	

func toggleCardInfo(enable:bool, card:Card):
	var cardInfo := %CardInfoPanel
	cardInfo.toggleCardInfo(enable, card)
	
	if enable:
		var global_center:Vector2 = %CameraMainBoard.get_screen_center_position()
		var screen_pos = card.get_global_transform_with_canvas().get_origin()
		print(screen_pos)
		cardInfo.show_at(screen_pos)
	

func addLogMessage(text:String, color:Color) -> void:
	
	$CanvasLayer/BattleLogPane.addMessage(text, color)

#################################################################
# Cheat Functions

func nuke_cards(isEnemy: bool):
	var board: Node = $CardsManager/PlayerBoard
	var hand: Node = %PlayerHand
	if isEnemy:
		board = $CardsManager/EnemyBoard
		hand = %EnemyHand
		
	for child in board.get_children():
		board.remove_child(child)
	for child in hand.get_children():
		hand.remove_child(child)
	


func nuke_all_cards():
	nuke_cards(true)
	nuke_cards(false)


func endGame(isWin:bool):
	$CanvasLayer/GameOverPane.show()
	if isWin:
		$CanvasLayer/GameOverPane/Margin/VBox/WonHeader.show()
		$CanvasLayer/GameOverPane/Margin/VBox/LostHeader.hide()
	else:
		$CanvasLayer/GameOverPane/Margin/VBox/WonHeader.hide()
		$CanvasLayer/GameOverPane/Margin/VBox/LostHeader.show()
		lose_champion()

func lose_champion():
	GameInfo.playerOwnedChampions.erase(GameInfo.current_champion)
	if not GameInfo.playerOwnedChampions.is_empty():
		GameInfo.current_champion = GameInfo.playerOwnedChampions[0]

func buttonPressedEndMatch() -> void:
	if GameInfo.currentZone:
		GameInfo.currentZone.visualsUpdateNeeded = true
		SceneSwitcher.switchToNewScene(GameInfo.currentZone)
	else:
		SceneSwitcher.returnToMainMenu()

func getPortraitPosition(isEnemy:bool) -> Vector2:
	if isEnemy:
		return $Portraits/PlayerSprite.position
	else:
		return $Portraits/EnemySprite.position

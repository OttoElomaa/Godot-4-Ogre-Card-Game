extends Node2D


@onready var GameBoardScene: PackedScene = preload("res://GameScenes/GameBoard/GameBoard.tscn")

@onready var ZoneScene: PackedScene = preload("res://GameScenes/Zone/Zone.tscn")


var bestiaryVisible := false

var bestiaryCards := []


func _ready() -> void:
	
	setupBestiary()
	
	bestiaryVisible = true
	buttonPressedToggleBestiary()



func setupBestiary():
	
	var allCards := []
	
	allCards.append_array(loadCardsInFolder("res://Cards/City/"))
	allCards.append_array( loadCardsInFolder("res://Cards/Desert/") )
	allCards.append_array( loadCardsInFolder("res://Cards/GreenDefiance/") )
	allCards.append_array(loadCardsInFolder("res://Cards/Outcasts/"))
	
	bestiaryCards.append_array(allCards)
	
	#### PLACE CARDS IN BESTIARY SLOTS
	var bestiarySlots: Array = $Bestiary/Slots.get_children()
	var placedCards = MyTools.placeCardsInSlotArray(bestiaryCards, bestiarySlots)
		
	for card:Card in placedCards:
		$Bestiary/Cards.add_child(card)
		card.turnOnBestiaryVisuals(self)



func _input(event: InputEvent) -> void:
	if bestiaryVisible:
		if event.is_action_pressed("ui_down"):
			$MenuCamera.position += Vector2.DOWN * 50
		elif event.is_action("scrollDown"):
			$MenuCamera.position += Vector2.DOWN * 50

		elif event.is_action_pressed("ui_up"):
			$MenuCamera.position += Vector2.UP * 50
		elif event.is_action("scrollUp"):
			$MenuCamera.position += Vector2.UP * 50

func loadCardsInFolder(folderPath:String) -> Array:

	var dir := DirAccess.open(folderPath)
	var file_names := dir.get_files()
	var cardScenes := []

	for name in file_names:
		var card:PackedScene = load(folderPath + name)
		cardScenes.append(card.instantiate() ) 
	return cardScenes
	



func buttonPressedStartMatch() -> void:
	
	#var gameBoard: GameBoard = GameBoardScene.instantiate()
	bestiaryVisible = false
	GameInfo.playerOwnedCards = MyTools.createGenericPlayerDeck()
	GameInfo.enemyDeckCards = MyTools.createGenericPlayerDeck()
#	var newBoard:Node = GameBoardScene.instantiate()
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/DeckEditScreen/DeckEdit.tscn")
	


func buttonPressedGoToWorld() -> void:
	bestiaryVisible = false
	var newZone:Node = ZoneScene.instantiate()
	SceneSwitcher.switchToNewScene(newZone, self)
	#get_tree().change_scene_to_packed(ZoneScene)



func buttonPressedToggleBestiary() -> void:
	
	if not bestiaryVisible:
		bestiaryVisible = true
		States.gameState = States.GameStates.BESTIARY
		
		$Bestiary.show()
		$CanvasLayer/CardInfoPane.show()
		$Intro.toggleIntro(false)
		
	
	else:
		bestiaryVisible = false
		States.statesNone()
		
		$Bestiary.hide()
		$CanvasLayer/CardInfoPane.hide()
		$Intro.toggleIntro(true)

func buttonPressedExitGame() -> void:
	get_tree().quit()

func toggleCardInfo(enable:bool, card:Card):
	var cardInfo := $CanvasLayer/CardInfoPane/CardInfoPanel
	cardInfo.toggleCardInfo(enable, card)

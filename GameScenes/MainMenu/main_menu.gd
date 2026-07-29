extends Node2D


@onready var GameBoardScene: PackedScene = preload("res://GameScenes/GameBoard/GameBoard.tscn")

@onready var ZoneScene: PackedScene = preload("res://Resources/Scenarios/City/Vanished_Astromancer.tscn")
@onready var ArenaScene: PackedScene = preload("res://Resources/Scenarios/City/Arena.tscn")

var bestiaryVisible := false

var bestiaryCards := []


func _ready() -> void:
	DataLoader.createAllGameCards()
	DataLoader.load_text_data('res://Resources/Data/Terms.json', DataLoader.terms)
	DataLoader.get_effect_descriptions()
	GameInfo.playerOwnedCards = DataLoader.createDesertDeck()
	GameInfo.enemyDeckCards = DataLoader.createDesertDeck()
	GameInfo.current_champion = DataLoader.champions_by_name['Nameless Warrior']
#	setupBestiary()
	
#	bestiaryVisible = true
#	buttonPressedToggleBestiary()
	
	for child in $Decor/DancingCards.get_children():
		child.initialize(self)
		await get_tree().create_timer(0.15).timeout
	

func put_on_top(node:Node2D):
	var parent = node.get_parent()
	parent.move_child(node, -1)

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
	bestiaryVisible = false
	
	GameInfo.isPreBattle = true
	MyTools.setupAndOpenDeckEdit(GameBoardScene.instantiate())
	

func buttonPressedToggleBestiary() -> void:
	
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/Compendium/Compendium.tscn")

func buttonPressedExitGame() -> void:
	get_tree().quit()

func toggleCardInfo(enable:bool, card:Card):
	var cardInfo := $CanvasLayer/CardInfoPane/CardInfoPanel
	cardInfo.toggleCardInfo(enable, card)

func _on_options_button_pressed():
	pass # Replace with function body.


func _on_endless_button_pressed():
	bestiaryVisible = false
	var newZone:Node = ArenaScene.instantiate()
	SceneSwitcher.switchToNewScene(newZone)

func _on_start_game_button_pressed():
	bestiaryVisible = false
	var newZone:Node = ZoneScene.instantiate()
	SceneSwitcher.switchToNewScene(newZone)
	#get_tree().change_scene_to_packed(ZoneScene)

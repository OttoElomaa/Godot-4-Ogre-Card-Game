extends Node2D
class_name Scenario


@export var zoneName := "The Lands"

var travelScreenStr := "res://GameScenes/TravelMap/travel_screen.tscn"
var deck_edit_str := "res://GameScenes/DeckEditScreen/DeckEdit.tscn"

@onready var GameBoardScene: PackedScene = preload("res://GameScenes/GameBoard/GameBoard.tscn")

@onready var PreBattleScreen: PackedScene = preload("res://GameScenes/Zone/PreBattleWindow.tscn")
var preBattleWindow:Node = null

##################################

@onready var zoneNameLabel:Label = $UI/ZoneInfoPanel/Panel/HBox/ZoneNameLabel

@onready var heroNameLabel:Label = $UI/PlayerInfoPanel/VBox/Panel/HBox/HeroNameLabel
@onready var heroPortrait:TextureRect = $UI/PlayerInfoPanel/VBox/PanelContainer/HeroPortrait 

@onready var gloryAmountLabel:Label = $UI/PlayerInfoPanel/VBox/Panel2/HBox/GloryAmountLabel
@onready var livesAmountLabel:Label = $UI/PlayerInfoPanel/VBox/LivesPanel/HBox/LivesLabel

@onready var actionButtonsHbox:HBoxContainer = $UI/BottomActions/VBox/ButtonsHBox

var gameBoards: Array:
	get:
		return $Zones/GameBoards.get_children()

#var hoverCheckNeeded := false
var visualsUpdateNeeded := false
var actionName := ""
var actionDesc := ""

@onready var labelsHbox:HBoxContainer = $UI/BottomActions/VBox/Description/MarginContainer/HBox
var actionNameLabel:Label:
	get:
		return labelsHbox.get_node("ActionNameLabel")
var actionDescLabel:Label:
	get:
		return labelsHbox.get_node("ActionDescLabel")


func _ready() -> void:
	for actionButton in actionButtonsHbox.get_children():
		actionButton.setup(self)
	
	for gameBoard:ZoneNode in gameBoards:
		await gameBoard.setup(self)
	
	SignalBus.connect('unlock_node', unlockNode)
	SignalBus.connect('resolve_node', resolveNode)
	
	updateZoneVisuals()


func _physics_process(delta: float) -> void:
	if visualsUpdateNeeded:
		updateZoneVisuals()
		visualsUpdateNeeded = false


func updateZoneVisuals():
	zoneNameLabel.text = zoneName
	
	heroNameLabel.text = GameInfo.heroName
	heroPortrait.texture = GameInfo.playerIcon
	
	gloryAmountLabel.text = "%d" % GameInfo.playerGlory
	livesAmountLabel.text = "%d" % GameInfo.playerLives
	
	for gameBoard:ZoneNode in gameBoards:
		gameBoard.toggleHoverInfo(false)
		gameBoard.update_state()
		gameBoard.showCompletionState()
	
	

func _input(e: InputEvent) -> void:
	
	if e.is_action_pressed("LMB"):
		#if e.button_index == MOUSE_BUTTON_LEFT:
		inputFetchIcons()


func inputFetchIcons():	
	var result = MyTools.fetchMouseOverObjects(1)
	
	for r in result:
		var icon = r.collider.get_parent()
		if icon is Node:
			if icon.has_method("getDeckCards"):
				startBoardMatch(icon)
			
			

func startBoardMatch(icon:Node):
	var deckCards:Array = icon.getDeckCards()
	GameInfo.enemyDeckCards = deckCards
	GameInfo.playerDeckCards = MyTools.createGenericPlayerDeck()
	
	var newBoard:Node = GameBoardScene.instantiate()
	SceneSwitcher.switchToNewScene(newBoard)

func updateActionDescription(name:String, desc:String):

	actionNameLabel.text = name
	actionDescLabel.text = desc
	
	actionName = ""
	actionDesc = ""


func showBattleInfo(gameBoard:Node):
	
	
	$CanvasLayer/BottomActions/VBox/ButtonsHBox/Battle.updateDescriptionPanel()



func buttonPressedExitGame() -> void:
	get_tree().quit()


func startGameBoardBattle(enemyCards:Array):
	
	GameInfo.enemyDeckCards = enemyCards
	GameInfo.playerDeckCards = []

func buttonPressedTravel():
	
	SceneSwitcher.switchToNewSceneFromFile(travelScreenStr)


func buttonPressedDeckEdit() -> void:
	GameInfo.isPreBattle = false
	MyTools.openDeckEdit()



func openPrebattle(b_node:Node2D):
	preBattleWindow = PreBattleScreen.instantiate()
	$PreBattleCanvas.add_child(preBattleWindow)
	preBattleWindow.setup(b_node)
	
		
func closePrebattle():
	if preBattleWindow:
		preBattleWindow.queue_free()

func toggleUI():
	var UI = [%Zones, %UI]
	for i:CanvasLayer in UI:
		i.visible = !i.visible

func unlockNode(zoneNodeID:String):
	for child:ZoneNode in %GameBoards.get_children():
		if child.name == zoneNodeID: 
			child.unlock()
		elif child.node_name == zoneNodeID:
			child.unlock()
			
			

func resolveNode(zoneNodeID:String):
	for child:ZoneNode in %GameBoards.get_children():
		if child.name == zoneNodeID: 
			child.resolve()

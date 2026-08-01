extends Node2D
class_name Scenario

const GainStrings: Array[String] = []

@export var zoneName := "The Lands"
@export var graphic:Texture2D = null
@export_multiline var description: String
@export var groups_you_may_meet = []
@export_flags('New Allies', 'Glory and Treasure', 'A Place of Power', 'An Untimely Death',
'A Stoneseeker Caravan', 'New Recruits') var things_you_may_gain

var travelScreenStr := "res://GameScenes/TravelMap/travel_screen.tscn"
var deck_edit_str := "res://GameScenes/DeckEditScreen/DeckEdit.tscn"

@onready var GameBoardScene: PackedScene = preload("res://GameScenes/GameBoard/GameBoard.tscn")

@onready var PreBattleScreen: PackedScene = preload("res://GameScenes/Zone/PreBattleWindow.tscn")
var preBattleWindow:Node = null

##################################

@onready var zoneNameLabel:Label = %ZoneNameLabel

@onready var heroNameLabel:Label = %HeroNameLabel
@onready var heroPortrait:TextureRect = %HeroPortrait

@onready var gloryAmountLabel:Label = %GloryAmountLabel
@onready var livesAmountLabel:Label = %LivesLabel

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
	if Engine.is_editor_hint():
		return
		
	for actionButton in actionButtonsHbox.get_children():
		actionButton.setup(self)
	
	for gameBoard:ZoneNode in gameBoards:
		await gameBoard.setup(self)
	
	SignalBus.connect('unlock_node', unlockNode)
	SignalBus.connect('resolve_node', resolveNode)
	
	updateZoneVisuals()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
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
	
func create_scenario_description():
	var desc_string: String = ''
	desc_string += str(description, '[br][br]')
	desc_string += str('Groups you may meet: ', groups_you_may_meet, '[br]')
	desc_string += str('Things you may gain: ', things_you_may_gain, '[br]')

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

func updateActionDescription(a_name:String, desc:String):

	actionNameLabel.text = a_name
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

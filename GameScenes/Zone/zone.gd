extends Node2D


@export var zoneName := "The Lands"

@onready var GameBoardScene: PackedScene = preload("res://GameScenes/GameBoard/GameBoard.tscn")

##################################

@onready var zoneNameLabel:Label = $CanvasLayer/ZoneInfoPanel/Panel/HBox/ZoneNameLabel

@onready var heroNameLabel:Label = $CanvasLayer/PlayerInfoPanel/VBox/Panel/HBox/HeroNameLabel
@onready var gloryAmountLabel:Label = $CanvasLayer/PlayerInfoPanel/VBox/Panel2/HBox/GloryAmountLabel
@onready var heroPortrait:TextureRect = $CanvasLayer/PlayerInfoPanel/VBox/PanelContainer/HeroPortrait 

@onready var actionButtonsHbox:HBoxContainer = $CanvasLayer/BottomActions/VBox/ButtonsHBox


var hoverCheckNeeded := false
var actionName := ""
var actionDesc := ""

@onready var labelsHbox:HBoxContainer = $CanvasLayer/BottomActions/VBox/Description/MarginContainer/HBox
var actionNameLabel:Label:
	get:
		return labelsHbox.get_node("ActionNameLabel")
var actionDescLabel:Label:
	get:
		return labelsHbox.get_node("ActionDescLabel")


func _ready() -> void:
	
	zoneNameLabel.text = zoneName
	
	heroNameLabel.text = GameInfo.heroName
	gloryAmountLabel.text = "%d" % GameInfo.playerGlory
	heroPortrait.texture = GameInfo.playerIcon
	
	for actionButton in actionButtonsHbox.get_children():
		actionButton.setup(self)
	
	for gameBoard in $Zones/GameBoards.get_children():
		gameBoard.setup(self)
	
	closePrebattle()
	


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
	
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/TravelMap/travel_screen.tscn")



func openPrebattle(b_node:Node2D):
	$PreBattleCanvas/PreBattleWindow.toggleWindow(true, b_node)
		
func closePrebattle():
	$PreBattleCanvas/PreBattleWindow.toggleWindow(false, null)

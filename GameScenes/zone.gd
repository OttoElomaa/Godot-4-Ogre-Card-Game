extends Node2D


@export var zoneName := "The Lands"

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
	
	for gameBoard in $GameBoards.get_children():
		gameBoard.setup(self)
	


func updateActionDescription(name:String, desc:String):

	actionNameLabel.text = name
	actionDescLabel.text = desc
	
	actionName = ""
	actionDesc = ""


func showBattleInfo(gameBoard:Node):
	$CanvasLayer/BottomActions/VBox/ButtonsHBox/Battle.updateDescriptionPanel()



func buttonPressedExitGame() -> void:
	get_tree().quit()

extends Node2D


@export var zoneName := "The Lands"

@onready var zoneNameLabel:Label = $CanvasLayer/ZoneInfoPanel/Panel/HBox/ZoneNameLabel

@onready var heroNameLabel:Label = $CanvasLayer/PlayerInfoPanel/VBox/Panel/HBox/HeroNameLabel
@onready var gloryAmountLabel:Label = $CanvasLayer/PlayerInfoPanel/VBox/Panel2/HBox/GloryAmountLabel

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
	$CanvasLayer/PlayerInfoPanel/VBox/HeroPortrait.texture = GameInfo.playerIcon
	
	for actionButton in $CanvasLayer/BottomActions/VBox/ButtonsHBox.get_children():
		actionButton.setup(self)
	
	


func updateActionDescription(name:String, desc:String):

	actionNameLabel.text = name
	actionDescLabel.text = desc
	
	actionName = ""
	actionDesc = ""



func buttonPressedExitGame() -> void:
	get_tree().quit()

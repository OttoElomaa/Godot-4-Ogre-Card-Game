extends Node2D


@export var zoneName := "The Lands"

@onready var zoneNameLabel:Label = $CanvasLayer/ZoneInfoPanel/VBox/Panel/HBox/ZoneNameLabel



func _ready() -> void:
	
	zoneNameLabel.text = zoneName
	
	for actionButton in $CanvasLayer/BottomActions/VBox/ButtonsHBox.get_children():
		actionButton.setup(self)



func updateActionDescription(name:String, desc:String):
	var labelsHbox:HBoxContainer = $CanvasLayer/BottomActions/VBox/Description/MarginContainer/HBox
	var nameLabel:Label = labelsHbox.get_node("ActionNameLabel")
	var descLabel:Label = labelsHbox.get_node("ActionDescLabel")
	
	nameLabel.text = name
	descLabel.text = desc



func buttonPressedExitGame() -> void:
	get_tree().quit()

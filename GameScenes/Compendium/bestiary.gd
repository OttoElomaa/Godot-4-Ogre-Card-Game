extends Node2D
@onready var BestiaryCardsContainer := $CanvasLayer2/Panel/MarginContainer/Scroll/BestiaryCardsContainer
@onready var cardInfoPanel := $CardInfoPanel
@onready var flavorLabel := $Margin/FlavorLabel

var BestiaryContainer = preload("res://GameScenes/Compendium/BestiaryContainer.tscn")

func _ready():
	create_containers()
	cardInfoPanel.bestiarySetup(self)  #### FOR SHOWING FLAVOR TEXT LABEL HERE


func create_containers():
	#### EMPTY THE CARD LISTS BEFORE FILLING THEM
	for child in BestiaryCardsContainer.get_children():
		child.queue_free()
		
	print('Creating containers')
	for i:Card in GameInfo.all_cards:
		var new_cont = BestiaryContainer.instantiate()
		BestiaryCardsContainer.add_child(new_cont)
		new_cont.insert_card(i)
		new_cont.infoPanel = cardInfoPanel


func setFlavorLabelText(flavor:String):
	flavorLabel.text = flavor

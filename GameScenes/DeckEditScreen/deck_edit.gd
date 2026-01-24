extends Node2D
@onready var CardContainer = preload("res://GameScenes/DeckEditScreen/card_container.tscn")
@onready var CardPanel = preload("res://GameScenes/DeckEditScreen/card_panel.tscn")
@onready var ownedCardsContainer = $CanvasLayer2/Panel/Scroll/MarginContainer/OwnedCardsContainer
@onready var activeCardsContainer = $CanvasLayer/NinePatchRect/VBoxContainer/ActiveCardsContainer
@onready var cardInfoPanel = $CardInfoPanel


func _ready():
	create_containers()
	activeCardsContainer.connect("updated", create_containers)
	ownedCardsContainer.connect("updated", create_containers)
	
	#### DO WE SHOW "Proceed" BUTTON
	if GameInfo.isPreBattle:
		$Buttons/VBox/Proceed.show()	
	else:
		$Buttons/VBox/Proceed.hide()
		
	
	

func create_containers():
	#### EMPTY THE CARD LISTS BEFORE FILLING THEM
	for child in activeCardsContainer.get_children():
		child.queue_free()
	for child in ownedCardsContainer.get_children():
		child.queue_free()
		
	print('Creating containers')
	for i:Card in GameInfo.playerOwnedCards:
		var new_cont = CardContainer.instantiate()
		ownedCardsContainer.add_child(new_cont)
		new_cont.insert_card(i)
		new_cont.infoPanel = cardInfoPanel
	for i in GameInfo.playerDeckCards:
		var new_cont = CardPanel.instantiate()
		new_cont.card = i
		activeCardsContainer.add_child(new_cont)
		
	$"CanvasLayer/NinePatchRect/VBoxContainer/PanelContainer/#CardsInDeck".text = str(GameInfo.playerDeckCards.size(), " / 10")
	#$ProceedButton.disabled = GameInfo.playerDeckCards.size() < 10


func _on_proceed_button_button_up():
	GameInfo.isPreBattle = false
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/GameBoard/GameBoard.tscn")


func _button_up_back_to_world() -> void:
	GameInfo.isPreBattle = false
	SceneSwitcher.switchToStoredScene()

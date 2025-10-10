extends Node2D
@onready var CardContainer = preload("res://GameScenes/DeckEditScreen/card_container.tscn")
@onready var CardPanel = preload("res://GameScenes/DeckEditScreen/card_panel.tscn")
@onready var ownedCardsContainer = $CanvasLayer2/Panel/Scroll/OwnedCardsContainer
@onready var activeCardsContainer = $CanvasLayer/NinePatchRect/VBoxContainer/ActiveCardsContainer
@onready var cardInfoPanel = $CardInfoPanel

func _ready():
	create_containers()
	activeCardsContainer.connect("updated", create_containers)
	activeCardsContainer.connect("card_mouse_entered", show_info)
	activeCardsContainer.connect("card_mouse_exited", hide_info)
	ownedCardsContainer.connect("updated", create_containers)
	ownedCardsContainer.connect("card_mouse_entered", show_info)
	ownedCardsContainer.connect("card_mouse_exited", hide_info)
	
func create_containers():
	#### EMPTY THE CARD LISTS BEFORE FILLING THEM
	for child in activeCardsContainer.get_children():
		child.queue_free()
	for child in ownedCardsContainer.get_children():
		child.queue_free()
		
	print('Creating containers')
	for i in GameInfo.playerOwnedCards:
		var new_cont = CardContainer.instantiate()
		new_cont.card = i
		ownedCardsContainer.add_child(new_cont)
	for i in GameInfo.playerDeckCards:
		var new_cont = CardPanel.instantiate()
		new_cont.card = i
		activeCardsContainer.add_child(new_cont)
		
	$"CanvasLayer/NinePatchRect/VBoxContainer/PanelContainer/#CardsInDeck".text = str(GameInfo.playerDeckCards.size(), " / 10")
	#$ProceedButton.disabled = GameInfo.playerDeckCards.size() < 10

func show_info(card):
	cardInfoPanel.toggleCardInfo(true, card)

func hide_info():
	cardInfoPanel.toggleCardInfo(false, null)

func _on_proceed_button_button_up():
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/GameBoard/GameBoard.tscn")

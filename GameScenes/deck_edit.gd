extends Node2D
@onready var cardContainer = preload("res://GameScenes/card_container.tscn")
@onready var cardPanel = preload("res://GameScenes/card_panel.tscn")
@onready var OwnedCardsContainer = $CanvasLayer2/NinePatchRect/OwnedCardsContainer
@onready var ActiveCardsContainer = $CanvasLayer/NinePatchRect/VBoxContainer/ActiveCardsContainer
@onready var CardInfoPanel = $CardInfoPanel

func _ready():
	create_containers()
	ActiveCardsContainer.connect("updated", create_containers)
	ActiveCardsContainer.connect("card_mouse_entered", show_info)
	ActiveCardsContainer.connect("card_mouse_exited", hide_info)
	OwnedCardsContainer.connect("updated", create_containers)
	OwnedCardsContainer.connect("card_mouse_entered", show_info)
	OwnedCardsContainer.connect("card_mouse_exited", hide_info)
	
func create_containers():
	for child in ActiveCardsContainer.get_children():
		child.queue_free()
	for child in OwnedCardsContainer.get_children():
		child.queue_free()
	print('Creating containers')
	for i in GameInfo.playerOwnedCards:
		var new_cont = cardContainer.instantiate()
		new_cont.card = i
		$CanvasLayer2/NinePatchRect/OwnedCardsContainer.add_child(new_cont)
	for i in GameInfo.playerDeckCards:
		var new_cont = cardPanel.instantiate()
		new_cont.card = i
		$CanvasLayer/NinePatchRect/VBoxContainer/ActiveCardsContainer.add_child(new_cont)
	$"CanvasLayer/NinePatchRect/VBoxContainer/PanelContainer/#CardsInDeck".text = str(GameInfo.playerDeckCards.size(), "/10")
	#$ProceedButton.disabled = GameInfo.playerDeckCards.size() < 10

func show_info(card):
	CardInfoPanel.toggleCardInfo(true, card)

func hide_info():
	CardInfoPanel.toggleCardInfo(false, null)

func _on_proceed_button_button_up():
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/GameBoard/GameBoard.tscn")

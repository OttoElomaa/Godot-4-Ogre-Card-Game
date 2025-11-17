extends Node2D
@onready var BestiaryCardsContainer = $CanvasLayer2/Panel/MarginContainer/Scroll/BestiaryCardsContainer
@onready var cardInfoPanel = $CardInfoPanel
var BestiaryContainer = preload("res://GameScenes/Compendium/BestiaryContainer.tscn")

func _ready():
	create_containers()
	BestiaryCardsContainer.connect("card_mouse_entered", show_info)
	BestiaryCardsContainer.connect("card_mouse_exited", hide_info)

func create_containers():
	#### EMPTY THE CARD LISTS BEFORE FILLING THEM
	for child in BestiaryCardsContainer.get_children():
		child.queue_free()
		
	print('Creating containers')
	for i:Card in GameInfo.all_cards:
		var new_cont = BestiaryContainer.instantiate()
		BestiaryCardsContainer.add_child(new_cont)
		new_cont.insert_card(i)

func show_info(card):
	cardInfoPanel.toggleCardInfo(true, card)

func hide_info():
	cardInfoPanel.toggleCardInfo(false, null)

extends MarginContainer

@onready var card_box = $PanelContainer/HBoxContainer
var BestiaryContainer = preload("res://GameScenes/CardDisplayContainers/BestiaryContainer.tscn")

func _ready():
	SignalBus.connect('disp_card', display_cutscene_card)
	SignalBus.connect('hide_card', hide_cutscene_card)
	SignalBus.connect('hide_all', hide_all_cutscene_cards)
	
func display_cutscene_card(card:String):
	for c:Card in GameInfo.all_cards:
		if c.cardName == card:
			var cont = BestiaryContainer.instantiate()
			card_box.add_child(cont)
			cont.size = Vector2(200, 330)
			cont.insert_card(c)

func hide_cutscene_card(card:String):
	for c:CardContainer in card_box.get_children():
		if c.card.cardName == card:
			c.queue_free()
			return
	
func hide_all_cutscene_cards():
	for c:CardContainer in card_box.get_children():
		c.queue_free()
	return

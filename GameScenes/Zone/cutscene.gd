extends MarginContainer

@onready var card_box = %CardBox
var bestiaryContainer = preload("res://GameScenes/Zone/cutscene_container.tscn")

func _ready():
	SignalBus.connect('disp_card', display_cutscene_card)
	SignalBus.connect('hide_card', hide_cutscene_card)
	SignalBus.connect('hide_all', hide_all_cutscene_cards)
	
func display_cutscene_card(card:String):
	print('Dialog bubble: displaying card ', card)
	if card in DataLoader.cards_by_name:
		var cont = bestiaryContainer.instantiate() as CardContainer
		card_box.add_child(cont)
		cont.size = Vector2(200, 330)
		cont.insert_card(DataLoader.cards_by_name[card])
	else:
		print('Dialog bubble: no card by name ', card)

func hide_cutscene_card(card:String):
	for c:CardContainer in card_box.get_children():
		if c.card.cardName == card:
			c.queue_free()
			return
	
func hide_all_cutscene_cards():
	for c:CardContainer in card_box.get_children():
		c.queue_free()
	return

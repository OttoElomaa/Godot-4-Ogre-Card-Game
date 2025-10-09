extends PanelContainer
@export var card: Card = null
@onready var CardContainer = preload("res://GameScenes/DeckEditScreen/card_container.tscn")

@onready var nameLabel := $Margin/HBox/CardNameLabel
@onready var statsLabel := $Margin/HBox/StatsLabel
@onready var manaCostLabel := $Margin/HBox/ManaCostLabel


func _ready():
	
	nameLabel.text = card.cardName
	if card.cardType != Card.CardTypes.RITUAL:
		statsLabel.text = str(card.startingDamage, "/", card.startingHealth)
	else:
		statsLabel.hide()
	manaCostLabel.text = str(card.manaCost)

func _get_drag_data(at_position):
	var data = [card, true]
	var prev = CardContainer.instantiate()
	prev.card = card
	set_drag_preview(prev)
	
	return data

func _on_mouse_entered():
	get_parent().card_mouse_entered.emit(card)

func _on_mouse_exited():
	get_parent().card_mouse_exited.emit()

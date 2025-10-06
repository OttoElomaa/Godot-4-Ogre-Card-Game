extends PanelContainer
@export var card: Card = null
@onready var cardContainer = preload("res://GameScenes/card_container.tscn")

func _ready():
	
	$HBoxContainer/CardNameLabel.text = card.cardName
	if card.cardType != Card.CardTypes.RITUAL:
		$HBoxContainer/StatsLabel.text = str(card.startingDamage, "/", card.startingHealth)
	else:
		$HBoxContainer/StatsLabel.hide()
	$HBoxContainer/ManaCostLabel.text = str(card.manaCost)

func _get_drag_data(at_position):
	var data = [card, true]
	var prev = cardContainer.instantiate()
	prev.card = card
	set_drag_preview(prev)
	
	return data

func _on_mouse_entered():
	get_parent().card_mouse_entered.emit(card)

func _on_mouse_exited():
	get_parent().card_mouse_exited.emit()

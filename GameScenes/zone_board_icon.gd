extends Node2D


var zone:Node = null

@export var card1: PackedScene = null
@export var card2: PackedScene = null
@export var card3: PackedScene = null
@export var card4: PackedScene = null

var deckCards := []



func _ready() -> void:
	createDeck()


func setup(zone:Node):
	self.zone = zone



func createDeck():
	createDeckTwo(card1)
	createDeckTwo(card2)
	createDeckTwo(card3)
	createDeckTwo(card4)
	
	deckCards.shuffle()
	
	
	
func createDeckTwo(cardPacked: PackedScene):
	if not cardPacked:
		return
		
	var card:Card = cardPacked.instantiate()
	for i in range(4):
		var newCard = card.duplicate()
		deckCards.append(newCard)
	

func getDeckCards() -> Array:
	return deckCards


func mouseEnteredShowBattleInfo() -> void:
	zone.showBattleInfo(self)

extends Node



var counter := 0

func createCard(path:String):
	var cardPacked = load(path)
	return cardPacked.instantiate()
	


func createDesertDeck():
	
	counter = 0
	var card:Card = null
	var cards := []
	
	for i in range(20):
		cards.append(createCard("res://Cards/Creatures/Cr-Pikeman.tscn"))
	for i in range(20):
		cards.append(createCard("res://Cards/Creatures/Cr-Ogre.tscn"))
	for i in range(10):
		cards.append(createCard("res://Cards/Creatures/Cr-RukRaider.tscn"))
	for i in range(20):
		cards.append(createCard("res://Cards/Creatures/Cr-MardokHound.tscn"))
	
	for i in range(10):
		cards.append(createCard("res://Cards/Creatures/Cr-SlaghRider.tscn"))
	for i in range(10):
		cards.append(createCard("res://Cards/Rituals/Sp-Blast.tscn"))
	
	for i in range(20):
		cards.append(createCard("res://Cards/Creatures/Cr-BlinkBeast.tscn"))
	
	
	prints("created cards: ", cards)
	for c:Card in cards:
		c.basicSetup()
		#c.turnStartReset()
		
	cards.shuffle()
	return cards
	
	
	

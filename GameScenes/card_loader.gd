extends Node



var counter := 0

func createCard(path:String):
	var cardPacked = load(path)
	return cardPacked.instantiate()
	


func createDesertDeck():
	
	counter = 0
	var card:Card = null
	var cards := []
	
	for i in range(10):
		cards.append(createCard("res://Cards/Wilds/Cr-Pikeman.tscn"))
	for i in range(10):
		cards.append(createCard("res://Cards/Wilds/Cr-Ogre.tscn"))
	for i in range(10):
		cards.append(createCard("res://Cards/Wilds/Cr-RukRaider.tscn"))
	for i in range(20):
		cards.append(createCard("res://Cards/Wilds/Cr-MardokHound.tscn"))
	
	for i in range(10):
		cards.append(createCard("res://Cards/Wilds/Cr-SlaghRider.tscn"))
	for i in range(10):
		cards.append(createCard("res://Cards/Wilds/Ri-Blast.tscn"))
	
	for i in range(10):
		cards.append(createCard("res://Cards/Wilds/Cr-BlinkBeast.tscn"))
	for i in range(20):
		cards.append(createCard("res://Cards/GreenDefiance/Cr-DeathKnight.tscn"))
	for i in range(10):
		cards.append(createCard("res://Cards/Wilds/Cr-Alhaja-Pious.tscn"))
	
	for i in range(20):
		cards.append(createCard("res://Cards/Wilds/Cr-Stran-Herder.tscn"))
	for i in range(10):
		cards.append(createCard("res://Cards/Wilds/Cr-Tugar.tscn"))
	
	for i in range(20):
		cards.append(createCard("res://Cards/Depths/Cr-Kull-Assassin.tscn"))
	for i in range(20):
		cards.append(createCard("res://Cards/Wilds/Ri-Ashem1-medVohu.tscn"))
	
	for i in range(50):
		cards.append(createCard("res://Cards/Wilds/Cr-Janin-bargainer.tscn"))
	
	
	
	prints("created cards: ", cards)
	for c:Card in cards:
		c.basicSetup()
		#c.turnStartReset()
		
	cards.shuffle()
	return cards
	
	
	

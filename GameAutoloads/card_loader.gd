extends Node

var counter := 0

func createCard(path:String):
	var cardPacked = load(path)
	return cardPacked.instantiate()

func createDesertDeck():
	
	counter = 0
	var card:Card = null
	var cards := []
	
	
	#### THE CITY
	for i in range(5):
		cards.append(createCard("res://Cards/City/Cr-guardmaster.tscn"))
	for i in range(5):
		cards.append(createCard("res://Cards/City/Cr-Kalasirios.tscn"))
	
	##### GREEN DEFIANCE
	for i in range(5):
		cards.append(createCard("res://Cards/GreenDefiance/Cr-BriarFolk.tscn"))
	for i in range(5):
		cards.append(createCard("res://Cards/GreenDefiance/Ch-Vineman-Elder.tscn"))
		
	for i in range(5):
		cards.append(createCard("res://Cards/GreenDefiance/Cr-Woodwose.tscn"))
		
	for i in range(5):
		cards.append(createCard("res://Cards/GreenDefiance/Cr-DeathKnight.tscn"))
	for i in range(20):
		cards.append(createCard("res://Cards/GreenDefiance/Cr-Brud-Doomsayer.tscn"))
	#
	##### THE WILDS
	for i in range(5):
		cards.append(createCard("res://Cards/Desert/Cr-Ogre.tscn"))
	for i in range(5):
		cards.append(createCard("res://Cards/Outcasts/Cr-RukRaider.tscn"))
	for i in range(5):
		cards.append(createCard("res://Cards/Desert/Cr-MardokHound.tscn"))
	#
	for i in range(5):
		cards.append(createCard("res://Cards/Desert/Cr-SlaghRider.tscn"))
	for i in range(5):
		cards.append(createCard("res://Cards/Desert/Ri-Blast.tscn"))
	#
	for i in range(5):
		cards.append(createCard("res://Cards/Desert/Cr-BlinkBeast.tscn"))
	#
	for i in range(10):
		cards.append(createCard("res://Cards/Desert/Cr-Alhaja-Pious.tscn"))
	for i in range(5):
		cards.append(createCard("res://Cards/Desert/Cr-Alhaja-Bheith-Nochti.tscn"))
	#
	for i in range(10):
		cards.append(createCard("res://Cards/Desert/Cr-Outrider.tscn"))
	for i in range(5):
		cards.append(createCard("res://Cards/Desert/Cr-Tugar.tscn"))
	for i in range(10):
		cards.append(createCard("res://Cards/Desert/Ri-Blast.tscn"))
	#
	for i in range(5):
		cards.append(createCard("res://Cards/Outcasts/Cr-Kull-Assassin.tscn"))
	for i in range(10):
		cards.append(createCard("res://Cards/Desert/Ri-Ashem1-medVohu.tscn"))
	#
	for i in range(10):
		cards.append(createCard("res://Cards/Desert/Cr-Janin-bargainer.tscn"))
	
	
	
	prints("created cards: ", cards)
	for c:Card in cards:
		c.basicSetup()
		#c.turnStartReset()
		
	cards.shuffle()
	return cards
	
	
	

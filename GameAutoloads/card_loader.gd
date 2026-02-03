extends Node

var counter := 0

func createCard(path:String):
	var cardPacked = load(path)
	return cardPacked.instantiate()



func createAllCardsByAmount(amount:int) -> Array:
	var allCards := []
	var cardFolderPaths := ['res://Cards/City/', 'res://Cards/Desert/', 
	'res://Cards/Outcasts/', 'res://Cards/GreenDefiance/']

	for path in cardFolderPaths:    #### READ EACH FOLDER  
		var files := DirAccess.get_files_at(path)
		for file:String in files:   ####-> Then each CARD in those folders
			
			#### CREATE COPIES of each card based on the AMOUNT specified in input
			for i in range(amount):
				var cardPacked:PackedScene = load(str(path, file))
				var card = cardPacked.instantiate()
				allCards.append(card)
	
	return allCards




func get_all_game_cards():
	var path = 'res://Cards/City/'
	for file in DirAccess.get_files_at(path):
		var new_card = load(str(path, file))
		GameInfo.all_cards.append(new_card.instantiate())
	path = 'res://Cards/Desert/'
	for file in DirAccess.get_files_at(path):
		var new_card = load(str(path, file))
		GameInfo.all_cards.append(new_card.instantiate())
	path = 'res://Cards/Outcasts/'
	for file in DirAccess.get_files_at('res://Cards/Outcasts/'):
		var new_card = load(str(path, file))
		GameInfo.all_cards.append(new_card.instantiate())
	path = 'res://Cards/GreenDefiance/'
	for file in DirAccess.get_files_at('res://Cards/GreenDefiance/'):
		var new_card = load(str(path, file))
		GameInfo.all_cards.append(new_card.instantiate())



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
	
	
	

extends Node

var counter := 0
var cards_by_name:Dictionary[String, Card] = {}

var scenes_by_name:Dictionary[String, Node] = {
	
}

var boards_by_name:Dictionary[String, PackedScene] = {
	'Default': preload('uid://be8n1sbdblr6g')
}

func createCard(path:String):
	var cardPacked = load(path)
	return cardPacked.instantiate()

func createAllCardsByAmount(amount:int) -> Array:
	var allCards := []
	
	for card:Card in GameInfo.all_cards:
		for i in range(amount):
			allCards.append(card.duplicate())
	
	return allCards


func get_all_game_cards():
	var cardFolderPaths := ['res://Cards/City/', 'res://Cards/Desert/', 
	'res://Cards/Outcasts/', 'res://Cards/GreenDefiance/']

	for path in cardFolderPaths:    #### READ EACH FOLDER  
		var files := DirAccess.get_files_at(path)
		for file:String in files:   ####-> Then each CARD in those folders
			
			##### CREATE COPIES of each card based on the AMOUNT specified in input
				var cardPacked:PackedScene = load(str(path, file))
				var card = cardPacked.instantiate()
				GameInfo.all_cards.append(card)
	
	for card:Card in GameInfo.all_cards:
		cards_by_name[card.cardName] = card



func createDesertDeck():
	
#	counter = 0
#	var card:Card = null
	var cards := []
	
	cards = createAllCardsByAmount(5)
	
	##### THE CITY
	#for i in range(5):
		#cards.append(createCard("res://Cards/City/Cr-guardmaster.tscn"))
	#for i in range(5):
		#cards.append(createCard("res://Cards/City/Cr-Kalasirios.tscn"))
	#
	###### GREEN DEFIANCE
	#for i in range(5):
		#cards.append(createCard("res://Cards/GreenDefiance/Cr-BriarFolk.tscn"))
	#for i in range(5):
		#cards.append(createCard("res://Cards/GreenDefiance/Ch-Vineman-Elder.tscn"))
		#
	#for i in range(5):
		#cards.append(createCard("res://Cards/GreenDefiance/Cr-Woodwose.tscn"))
		#
	#for i in range(5):
		#cards.append(createCard("res://Cards/GreenDefiance/Cr-DeathKnight.tscn"))
	#for i in range(20):
		#cards.append(createCard("res://Cards/GreenDefiance/Cr-Brud-Doomsayer.tscn"))
	##
	###### THE WILDS
	#for i in range(5):
		#cards.append(createCard("res://Cards/Desert/Cr-Ogre.tscn"))
	#for i in range(5):
		#cards.append(createCard("res://Cards/Outcasts/Cr-RukRaider.tscn"))
	#for i in range(5):
		#cards.append(createCard("res://Cards/Desert/Cr-MardokHound.tscn"))
	##
	#for i in range(5):
		#cards.append(createCard("res://Cards/Desert/Cr-SlaghRider.tscn"))
	#for i in range(5):
		#cards.append(createCard("res://Cards/Desert/Ri-Blast.tscn"))
	##
	#for i in range(5):
		#cards.append(createCard("res://Cards/Desert/Cr-BlinkBeast.tscn"))
	##
	#for i in range(10):
		#cards.append(createCard("res://Cards/Desert/Cr-Alhaja-Pious.tscn"))
	#for i in range(5):
		#cards.append(createCard("res://Cards/Desert/Cr-Alhaja-Bheith-Nochti.tscn"))
	##
	#for i in range(10):
		#cards.append(createCard("res://Cards/Desert/Cr-Outrider.tscn"))
	#for i in range(5):
		#cards.append(createCard("res://Cards/Desert/Cr-Tugar.tscn"))
	#for i in range(10):
		#cards.append(createCard("res://Cards/Desert/Ri-Blast.tscn"))
	##
	#for i in range(5):
		#cards.append(createCard("res://Cards/Outcasts/Cr-Kull-Assassin.tscn"))
	#for i in range(10):
		#cards.append(createCard("res://Cards/Desert/Ri-Ashem1-medVohu.tscn"))
	##
	#for i in range(10):
		#cards.append(createCard("res://Cards/Desert/Cr-Janin-bargainer.tscn"))
	
	
	prints("created cards: ", cards)
	for c:Card in cards:
		c.basicSetup()
		#c.turnStartReset()
		
	cards.shuffle()
	return cards
	
	
	

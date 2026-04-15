extends Node

const generic_groups:Array[Card.Group] = [Card.Group.GENERIC, Card.Group.GREEN_GENERIC,
Card.Group.CITY_GENERIC, Card.Group.DESERT_GENERIC, Card.Group.OUTCAST_GENERIC]

const equipment_group:Card.Group = Card.Group.EQUIPMENT

var counter := 0
## Arranges all_cards to be referenced by their CardName. Used to instantiate
## cards during runtime.
var cards_by_name:Dictionary[String, Card] = {}
## Arranges all_cards into arrays based on their group. Used to generate loot tables.
var cards_by_group:Dictionary[Card.Group, Array] = {}
	
var champions_by_name:Dictionary[String, Champion] = {}
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
	
	## Filling out cards_by_name and cards_by_group.
	for card:Card in GameInfo.all_cards:
		cards_by_name[card.cardName] = card
		if not cards_by_group.has(card.group):
			cards_by_group[card.group] = [card]
		else:
			cards_by_group[card.group].append(card)
	
	## Putting generic cards into the recruitment pool.
	for idx:Card.Group in generic_groups:
		if cards_by_group.has(idx):
			GameInfo.playerRecruitmentPool.append_array(cards_by_group[idx])
	
	## Filling out champions_by_name.
	var path := 'res://Champions/'
	var files := DirAccess.get_files_at(path)
	for file:String in files:
		var new_champ:PackedScene = load(str(path, file))
		var champ:Champion = new_champ.instantiate()
		champions_by_name[champ.cardName] = champ

func createDesertDeck():
	
	var cards := []
	
	cards = createAllCardsByAmount(3)

	prints("created cards: ", cards)
	for c:Card in cards:
		c.basicSetup()
		#c.turnStartReset()
		
	cards.shuffle()
	return cards
	
	
	

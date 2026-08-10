extends Node

#region CONSTANTS
const generic_groups:Array[Card.Group] = [Card.Group.GENERIC, Card.Group.GREEN_GENERIC,
Card.Group.CITY_GENERIC, Card.Group.DESERT_GENERIC, Card.Group.OUTCAST_GENERIC]

const equipment_group:Card.Group = Card.Group.EQUIPMENT

const scenes_by_name:Dictionary[String, PackedScene] = {
	'TermTooltip': preload('uid://cn15aob5lrp56')
}

#endregion

#region Databases
## Arranges all_cards to be referenced by their CardName. Used to instantiate
## cards during runtime.
var cards_by_name:Dictionary[String, Card] = {}
## Arranges all_cards into arrays based on their group. Used to generate loot tables.
var cards_by_group:Dictionary[Card.Group, Array] = {}
## Loads and arranges all champions by their CardName. Used to instantiate champions.
var champions_by_name:Dictionary[String, Champion] = {}

var animations_by_filename:Dictionary[String, PackedScene] = {}

var scenarios_by_location:Dictionary[PackedScene, String] = {}

const boards_by_name:Dictionary[String, PackedScene] = {
	'Default': preload('uid://be8n1sbdblr6g')
}

## Preloads all ShaderMaterials to be dynamically assigned when a certain shader is needed.
const materials_by_name:Dictionary[String, Material] = {
	'destroy_card': preload("res://Resources/Shaders/destroy_card_material.tres")
}


## Contains important terms such as 'inflict' or 'battle art' and their explanations,
## found in the terms.json file.
var terms:Dictionary[String, String] = {}
## Contains all of the game's effect counters and their descriptions.
var effect_counters_desc:Dictionary[String,String] = {}
## Contains all of the game's keywords and their descriptions.
var keywords_desc:Dictionary[String, String] = {}
## Contains verses, used in the Akashic Records as reward for unlocking achievements.
var verses:Dictionary[String, String] = {}

#endregion

#region Initial Loading

var all_cards_created:
	get:
		cards_by_name.is_empty()
var has_initial_deck = false:
	get:
		GameInfo.playerDeckCards.is_empty()

#endregion

func createCard(path:String):
	var cardPacked = load(path)
	return cardPacked.instantiate()

func createAllCardsByAmount(amount:int) -> Array[Card]:
	var allCards: Array[Card] = []
	
	for card:Card in GameInfo.all_cards:
		for i in range(amount):
			allCards.append(card.duplicate())
	
	return allCards


func createAllGameCards():
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
			cards_by_group[card.group] = []
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
		
	## Filling out animations_by_filename.
	load_scenes_from_directory('res://GameScenes/ParticlesAnimations/', animations_by_filename)
	load_scenarios()

func load_scenarios():
	var path := 'res://Resources/Scenarios/City/'
	var files := DirAccess.get_files_at(path)
	for file:String in files:
		scenarios_by_location[load(str(path, file)) as PackedScene] = 'City'
		
## Fills out a dictionary with loaded files from a chosen folder, in a style of filename: resource.
func load_scenes_from_directory(path:String, dict:Dictionary):
	var files := DirAccess.get_files_at(path)
	for file:String in files:
		dict[file] = load(str(path, file))

func load_text_data(path:String, dict:Dictionary):
		var file_path = path
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json_object = JSON.new()
		var parse_err = json_object.parse(file.get_as_text())
		if parse_err == OK:
			var data_received = json_object.data
			if typeof(data_received) == TYPE_DICTIONARY:
#				print(data_received)
				dict.assign(data_received)

func get_effect_descriptions():
	var path = 'res://CardScriptsAndComponents/EffectCounters/'
	for i:String in DirAccess.get_files_at(path):
		var scene:PackedScene = load(str(path, i))
		var effect:CardEffect = scene.instantiate()
		effect_counters_desc[effect.id] = effect.description
	path = 'res://CardScriptsAndComponents/Keywords/'
	for i:String in DirAccess.get_files_at(path):
		var scene:PackedScene = load(str(path, i))
		var effect:CardEffect = scene.instantiate()
		keywords_desc[effect.id] = effect.description

func createDesertDeck() -> Array[Card]:
	
	var cards :Array[Card] = []
	
	cards = createAllCardsByAmount(3)

	for c:Card in cards:
		c.basicSetup()
		#c.turnStartReset()
		
	cards.shuffle()
	return cards
	
	
	

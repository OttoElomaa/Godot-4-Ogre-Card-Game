extends Node

func _ready():
	Options.load_options()
	DataLoader.createAllGameCards()
	DataLoader.load_text_data('res://Resources/Data/Terms.json', DataLoader.terms)
	DataLoader.get_effect_descriptions()
	GameInfo.playerOwnedCards = DataLoader.createDesertDeck()
	GameInfo.enemyDeckCards = DataLoader.createDesertDeck()
	GameInfo.current_champion = DataLoader.champions_by_name['General']
	
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/MainMenu/MainMenu.tscn")

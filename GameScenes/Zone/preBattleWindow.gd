extends CanvasLayer

@onready var BestiaryContainerScene:PackedScene = preload("res://GameScenes/CardDisplayContainers/BestiaryContainer.tscn")

@onready var cardInfoPanel := %CardInfoPanel
@onready var boardCommentsLabel := %GB_Comments

var battleInfoIcon:ZoneBattleIcon = null
var enemyDeck := []


func setup(icon:ZoneBattleIcon) -> void:
	battleInfoIcon = icon
	cardInfoPanel.bestiarySetup(self)  #### FOR SHOWING FLAVOR TEXT LABEL HERE
	toggleWindow(true)



func toggleWindow(enable:bool):	
	if enable:
		show()
		clearOldIcons()
		var icon:ZoneBattleIcon = battleInfoIcon
		if not icon.has_method('generate_fight'):
			generatePreview(icon, true)
		else:
			generatePreview(icon, false)
			
		boardCommentsLabel.text = icon.board_comments
	else:
		hide()
		clearOldIcons()
		


func generatePreview(icon:ZoneBattleIcon, isGenerated:bool):
	var enemyCardsHolder = %EnemyCards
	var playerCardsHolder = %PlayerCards
	
	if isGenerated:
		await battleInfoIcon.createDeck()
		#### GENERATE PREVIEW ICONS OF ENEMY DECK
		for key:String in icon.deck_cards:
			var newCard:Card = DataLoader.cards_by_name[key].duplicate()
			var container:BestiaryContainer = BestiaryContainerScene.instantiate()
			enemyCardsHolder.add_child(container)
			container.display_card(newCard)
			container.infoPanel = cardInfoPanel
	else:
		#### GENERATE PREVIEW ICONS OF ENEMY DECK
		var cards_for_preview = await icon.generate_fight()
		for cardScene:Card in cards_for_preview:
			var container:BestiaryContainer = BestiaryContainerScene.instantiate()
			enemyCardsHolder.add_child(container)
			container.insert_card(cardScene)
			container.infoPanel = cardInfoPanel
	
	%PlayerCards.insert_army(GameInfo.playerDeckCards, %CardInfoPanel)
	
	%PChampionContainer.insert_champion(GameInfo.current_champion)
	%EChampContainer.insert_champion(GameInfo.enemyChampion)


func putCopiesOfCardIntoEnemyDeck(card:PackedScene, amount:int):
	for i in range(amount):
		var newCard:Card = card.instantiate()
		enemyDeck.append(newCard)


func clearOldIcons():
	#### CLEAR OLD ICONS
	var enemyCardsHolder = %EnemyCards
	for card:Card in enemyCardsHolder.get_children():
		card.queue_free()

func cancelButtonPressed() -> void:
	queue_free()

func fightButtonPressed() -> void:
	
#	MyTools.setupAndOpenDeckEdit(battleInfoIcon.board)
	SceneSwitcher.switchToNewScene(battleInfoIcon.board)
	battleInfoIcon.resolve()
	
	queue_free()


func _on_adjust_deck_pressed():
	MyTools.openDeckEdit()

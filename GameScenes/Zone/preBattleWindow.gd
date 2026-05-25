extends MarginContainer

@onready var BestiaryContainerScene:PackedScene = preload("res://GameScenes/CardDisplayContainers/BestiaryContainer.tscn")

@onready var cardInfoPanel := $MainPanel/Margin/MainHBox/Filler/VBox/CardInfoPanel
@onready var flavorLabel := $MainPanel/Margin/MainHBox/Filler/VBox/FlavorLabel
@onready var boardCommentsLabel := $MainPanel/Margin/MainHBox/Left/VBox/GB_Comments

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
	var enemyCardsHolder = $MainPanel/Margin/MainHBox/Left/VBox/Margin/EnemyCards
	
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
		


func putCopiesOfCardIntoEnemyDeck(card:PackedScene, amount:int):
	for i in range(amount):
		var newCard:Card = card.instantiate()
		enemyDeck.append(newCard)


func clearOldIcons():
	#### CLEAR OLD ICONS
	var enemyCardsHolder = $MainPanel/Margin/MainHBox/Left/VBox/Margin/EnemyCards
	for card:Card in enemyCardsHolder.get_children():
		card.queue_free()


#### CALLED FROM CardInfoPanel
func setFlavorLabelText(flavor:String):
	flavorLabel.text = flavor

func cancelButtonPressed() -> void:
	queue_free()

func fightButtonPressed() -> void:
	
	MyTools.setupAndOpenDeckEdit(battleInfoIcon.board)
	
	queue_free()

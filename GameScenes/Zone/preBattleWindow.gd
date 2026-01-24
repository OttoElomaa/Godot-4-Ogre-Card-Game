extends MarginContainer

@onready var CardContainerScene:PackedScene = preload("res://GameScenes/Compendium/BestiaryContainer.tscn")

@onready var cardInfoPanel := $MainPanel/Margin/MainHBox/Filler/VBox/CardInfoPanel
@onready var flavorLabel := $MainPanel/Margin/MainHBox/Filler/VBox/FlavorLabel
@onready var boardCommentsLabel := $MainPanel/Margin/MainHBox/Left/VBox/GB_Comments

var battleInfoIcon:Node = null
var enemyDeck := []


func setup(icon:Node) -> void:
	battleInfoIcon = icon
	cardInfoPanel.bestiarySetup(self)  #### FOR SHOWING FLAVOR TEXT LABEL HERE
	toggleWindow(true)



func toggleWindow(enable:bool):
	var enemyCardsHolder = $MainPanel/Margin/MainHBox/Left/VBox/Margin/EnemyCards
	
	if enable:
		show()
		clearOldIcons()
		
		#### GENERATE PREVIEW ICONS OF ENEMY DECK	
		for cardScene:PackedScene in battleInfoIcon.deck_cards:
			
			var container = CardContainerScene.instantiate()
			enemyCardsHolder.add_child(container)
			container.display_card(cardScene)
			container.infoPanel = cardInfoPanel
			
			#### POPULATE ENEMY DECK FOR PLAYING
			putCopiesOfCardIntoEnemyDeck(cardScene, 4)
			
		boardCommentsLabel.text = battleInfoIcon.board_comments
	
	else:
		hide()
		clearOldIcons()
		


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
	GameInfo.enemyDeckCards = enemyDeck
	GameInfo.isPreBattle = true
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/DeckEditScreen/DeckEdit.tscn")

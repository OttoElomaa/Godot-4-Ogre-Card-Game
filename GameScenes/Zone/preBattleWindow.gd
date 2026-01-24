extends MarginContainer

@onready var CardContainerScene:PackedScene = preload("res://GameScenes/Compendium/BestiaryContainer.tscn")

@onready var cardInfoPanel := $MainPanel/Margin/MainHBox/Filler/VBox/CardInfoPanel
@onready var flavorLabel := $MainPanel/Margin/MainHBox/Filler/VBox/FlavorLabel
@onready var boardCommentsLabel := $MainPanel/Margin/MainHBox/Left/VBox/GB_Comments



func _ready() -> void:
	cardInfoPanel.bestiarySetup(self)  #### FOR SHOWING FLAVOR TEXT LABEL HERE


func toggleWindow(enable:bool, battleNode:Node):
	var enemyCardsHolder = $MainPanel/Margin/MainHBox/Left/VBox/Margin/EnemyCards
	
	if enable:
		show()
		clearOldIcons()
		
		#### GENERATE PREVIEW ICONS OF ENEMY DECK	
		for card in battleNode.deck_cards:
			var container = CardContainerScene.instantiate()
			enemyCardsHolder.add_child(container)
			container.display_card(card)
			container.infoPanel = cardInfoPanel
			
		boardCommentsLabel.text = battleNode.board_comments
	
	else:
		hide()
		clearOldIcons()
		


func clearOldIcons():
	#### CLEAR OLD ICONS
	var enemyCardsHolder = $MainPanel/Margin/MainHBox/Left/VBox/Margin/EnemyCards
	for card:Card in enemyCardsHolder.get_children():
		card.queue_free()


#### CALLED FROM CardInfoPanel
func setFlavorLabelText(flavor:String):
	flavorLabel.text = flavor

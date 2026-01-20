extends MarginContainer

@onready var CardContainerScene:PackedScene = preload("res://GameScenes/Compendium/BestiaryContainer.tscn")




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
			container.infoPanel = $MainPanel/Margin/MainHBox/Filler/CardInfoPanel
			
		$MainPanel/Margin/MainHBox/Left/VBox/GB_Comments.text = battleNode.board_comments
	
	else:
		hide()
		clearOldIcons()
		


func clearOldIcons():
	#### CLEAR OLD ICONS
	var enemyCardsHolder = $MainPanel/Margin/MainHBox/Left/VBox/Margin/EnemyCards
	for card:Card in enemyCardsHolder.get_children():
		card.queue_free()

@tool
extends Card
class_name Champion

var custom_window:CustomWindow

var level = 1

var usable_actions:Array = []
var all_actions:Array = []

func _ready() -> void:
	for child in get_children():
		if child is ActionsNodeChamp:
			for i in child.get_children():
				var preview = child.duplicate()
				preview.level = 1
				all_actions.append(preview)
				if i is OnCastTrigger and child.level > 0:
					usable_actions.append(child)
					break
		if child is CustomWindow:
			custom_window = child
			custom_window.hide()
	

static func make_generic_champion(c_name:String, art:Texture2D, c_health:int) -> Champion:
	var new = Champion.new()
	new.cardName = c_name
	new.startingHealth = c_health
	new.texture = art
	new.isEnemyCard = true
	new.cardType = CardTypes.CHAMPION
	return new

func hasCustomWindow():
	if custom_window:
		return true
	else:
		return false
		
func create_custom_window() -> Control:
	return custom_window

func setup(board:GameBoard):
	gameBoard = board
	if gameBoard:
#		print(cardName, ' has gameboard')
		cardsManager = gameBoard.cardsManager
		battleSystem = gameBoard.battleSystem
		cardsManager.connectCardSignal(self)
	statesBoard()
	
	if isEnemyCard:
		GameInfo.enemyHealth = startingHealth
	else:
		GameInfo.playerHealth = startingHealth
	
	for child in get_children():
		if child is ActionsNodeChamp:
			child.awakenTriggers()
		child.setup(self)
		
	if hasCustomWindow():
		var window = create_custom_window()

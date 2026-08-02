@tool
extends Card
class_name Champion

var level = 1

var usable_actions:Array = []

func _ready() -> void:
	for child:ActionsNode in get_children():
		usable_actions.append(child)

static func make_generic_champion(c_name:String, art:Texture2D, c_health:int) -> Champion:
	var new = Champion.new()
	new.cardName = c_name
	new.startingHealth = c_health
	new.texture = art
	new.isEnemyCard = true
	new.cardType = CardTypes.CHAMPION
	return new

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
	
	for child:ActionsNode in get_children():
		child.awakenTriggers()
		child.setup(self)

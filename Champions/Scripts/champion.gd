extends Card
class_name Champion

@export var texture:Texture

var level = 1

var usable_actions:Array = []

var gameBoard:GameBoard = null

func _ready() -> void:
	for child:ActionsNode in get_children():
		usable_actions.append(child)

func setup(board:GameBoard):
	gameBoard = board
	if gameBoard:
		print(cardName, ' has gameboard')
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
		usable_actions.append(child)

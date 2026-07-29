@tool
extends ZoneNode

class_name ZoneBattleIcon

var board : GameBoard = DataLoader.boards_by_name['Default'].instantiate() as GameBoard

@export_category('Game Board')
@export var board_name = '' ##MANDATORY. Shows up during battle.
@export var game_board:PackedScene = null ##MANDATORY. Determines visuals of the game board.
@export var ai_personality = GameBoard.AI_personalities.COMMANDER
@export_multiline var board_comments = '' ##NON-MANDATORY. Describes presummons/other things for the player.
@export var use_as_is = false ##If set to true, will not generate a deck for the enemy, instead using only what is within the GameBoard file. Good for unique encounters.

@export_category('Random Deck')

@export var deck_cards : Dictionary[String, int] = {} ## If this is filled, adds [value] of cards in [key] to the deck. 
@export var presummoned_cards : Array[String] = [] ## Will summon these cards at the start of battle.
@export var enemy_presummon = false ## Creates presummonned cards on enemy side.
@export var ally_presummon = false ## Creates presummoned cards on allied side.
@export var presummon_sparcity = presummon_sparsities.FEW ## How many objects will be presummoned.

@export_category('Champion')

@export var generic_champion:bool = true:
	set(value):
		generic_champion = value
		notify_property_list_changed()

@export var art:Texture = null
@export var champ_name:String = ''
@export var health:int = 5

@export var champion:String = '' ## The name of the champion fighting for the enemy.

enum presummon_sparsities {FEW, ## 0-1 object.
	SCARCE, ## 0-2
	MANY, ## 2-3
	TONS, ## 3-4
}

func _validate_property(property):
	if property.name in ['art', 'champ_name', 'health']:
		if not generic_champion:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == 'champion':
		if generic_champion:
			property.usage = PROPERTY_USAGE_NO_EDITOR

func setup(zone:Node):
	self.scenario = zone
	node_name = board_name
#	node_comments = board_comments
	toggleHoverInfo(false)


func createDeck():
	if game_board:
		board = game_board.instantiate().duplicate()
	board.boardName = board_name
	board.AI_personality = ai_personality
	
	if use_as_is:
		print('Set to use as is')
		return
	
	GameInfo.enemyDeckCards.clear()
	print('Clearing enemyDeckCards')
	
	for key:String in deck_cards:
		for i in range(deck_cards[key]):
			var newCard:Card = DataLoader.cards_by_name[key].duplicate()
			print('appending enemy card: ', newCard.cardName)
			GameInfo.enemyDeckCards.append(newCard)
	
	if generic_champion:
		var generic = Champion.make_generic_champion(champ_name, art, health)
		GameInfo.enemyChampion = generic
	else:
		var new = DataLoader.champions_by_name[champion]
		GameInfo.enemyChampion = new
	
		
#	if enemy_presummon:
#		presummon(true)
#	if ally_presummon:
#		presummon(false)
#	board.setup_board()
#	board.turn_1_init()
	
	
#	remove_child(board)
	


func presummon(isEnemyCard):
	var amount : int = 0
	
	#### SPECIFY AMOUNT OF PRE-SUMMONS
	match presummon_sparcity:
		presummon_sparsities.FEW:
			amount = randi_range(0, 1)
		presummon_sparsities.SCARCE:
			amount = randi_range(0, 2)
		presummon_sparsities.MANY:
			amount = randi_range(1, 3)
		presummon_sparsities.TONS:
			amount = randi_range(2, 4)
	
	#### SUMMON THEM
	for i in range(amount):
		var card:Card = presummoned_cards.pick_random().instantiate().duplicate()
		board.add_card_to_random_slot(card, isEnemyCard)



#### START THE PRE-BATTLE PROCESS IN ORDER TO FIGHT A BATTLE
func handleClick():
	GameInfo.currentZone = scenario
	
	scenario.openPrebattle(self)

func getBoardName():
	return board_name
	
func update_state():
	if board_name in GameInfo.playerWonBattleNames:
		resolve()

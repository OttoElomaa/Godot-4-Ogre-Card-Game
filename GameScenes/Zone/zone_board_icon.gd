extends ZoneNode
class_name ZoneBattleIcon

var zone:Node = null

var board : GameBoard = null

@export_category('Game Board')
@export var board_name = '' ##MANDATORY. Shows up during battle.
@export var game_board:PackedScene = null ##MANDATORY. Determines visuals of the game board.
@export var ai_personality = GameBoard.AI_personalities.COMMANDER
@export_multiline var board_comments = '' ##NON-MANDATORY. Describes presummons/other things for the player.
@export var use_as_is = false ##If set to true, will not generate a deck for the enemy, instead using only what is within the GameBoard file. Good for unique encounters.

@export_category('Random Deck')

@export var deck_cards : Dictionary[PackedScene, int] = {} ## If this is filled, adds [value] of cards in [key] to the deck. 
@export var presummoned_cards : Array[PackedScene] = [] ## Will summon these cards at the start of battle.
@export var enemy_presummon = false ## Creates presummonned cards on enemy side.
@export var ally_presummon = false ## Creates presummoned cards on allied side.

enum presummon_sparsities {FEW, ## 0-1 object.
	SCARCE, ## 0-2
	MANY, ## 2-3
	TONS, ## 3-4
}
@export var presummon_sparcity = presummon_sparsities.FEW ## How many objects will be presummoned.


func setup(zone:Node):
	self.zone = zone
	node_name = board_name
	node_comments = board_comments
	toggleHoverInfo(false)


func createDeck():
	board = game_board.instantiate().duplicate()
	MyTools.add_child(board)
	board.boardName = board_name
	board.AI_personality = ai_personality
	
	if use_as_is:
		print('Set to use as is')
		return
	
	for key:PackedScene in deck_cards:
		for i in range(deck_cards[key]):
			var newCard:Card = key.instantiate().duplicate()
			board.add_card_to_enemy_deck(newCard)
	
	if enemy_presummon:
		presummon(true)
	if ally_presummon:
		presummon(false)

	board.turn_1_init()


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


#func enterBattle():
	#SceneSwitcher.switchToNewScene(board)

#### START THE PRE-BATTLE PROCESS IN ORDER TO FIGHT A BATTLE
func _on_area_2d_input_event(viewport, event:InputEvent, shape_idx):
	if event.is_action_pressed("LMB"):
		insta_resolve()
		GameInfo.currentBattleInfo = self
		GameInfo.currentZone = zone
		zone.openPrebattle(self)

func update_state():
	if board_name in GameInfo.playerWonBattleNames:
		resolve()

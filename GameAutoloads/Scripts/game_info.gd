extends Node2D

var all_cards = []


#####################################################
#### PLAYER PROFILE
@onready var current_champion:Champion = preload("res://Champions/Scripts/Champion.tscn").instantiate()
var playerName := "The Player"
var heroName: String = '':
	get:
		return current_champion.cardName
var character_position: Map_Node

var playerGlory := 0
var playerLives := 3

var playerWonBattleNames := []
var currentZone: Scenario = null
var currentBattleInfo: ZoneBattleIcon = null

var playerIcon:Texture:
	get:
		return current_champion.texture

## All cards owned by the player. The active deck is made of these.
var playerOwnedCards := []

## All champions owned by the player. Only one can be active at a time.

var playerOwnedChampions: Array[Champion] = []
## Used to generate playerRecruitmentPool. The game checks for cards whose subtype contains
## members of this array.
var playerAlliances: Array[Card.Group] = []

## Cards available for purchase based on player alliances.
var playerRecruitmentPool := []


######################################################
#### ZONE STATE

var isPreBattle := false



#######################################
#### BATTLE STATE
## Cards used during battle. A valid deck has 10 or more cards.
var enemyDeckCards := []
var playerDeckCards := []

var playerHealth := 0
var playerMana := 0
var playerManaIncome := 0

@onready var enemyChampion: Champion = preload("res://Champions/Scripts/Champion.tscn").instantiate()
var enemyHealth := 0
var enemyMana := 0
var enemyManaIncome := 0

var turnCount := 0
var enemy_turn: bool  ## true is enemy (AI) turn, false if player turn

func _ready():
	SignalBus.add_alliance.connect(add_alliance)
	SignalBus.remove_alliance.connect(remove_alliance)

func add_alliance(alliance:Card.Group):
	playerAlliances.append(alliance)
	playerRecruitmentPool.append_array(DataLoader.cards_by_group[alliance])

func remove_alliance(alliance:Card.Group):
	playerAlliances.erase(alliance)
	var group_array = DataLoader.cards_by_group[alliance]
	for card:Card in group_array:
		playerRecruitmentPool.erase(card)

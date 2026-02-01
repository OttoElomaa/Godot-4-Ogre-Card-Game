extends Node2D

var all_cards = []


#####################################################
#### PLAYER PROFILE
var playerName := "The Player"
var heroName := "The Amir"
var character_position: Map_Node

var playerGlory := 0
var playerLives := 3

var playerWonBattleNames := []
var currentZone: Scenario = null
var currentBattleInfo: ZoneBattleIcon = null

var playerIcon:Texture:
	get:
		return $PlayerSprite.texture

## All cards owned by the player. The active deck is made of these.
var playerOwnedCards := []


######################################################
#### ZONE STATE

var isPreBattle := false



#######################################
#### BATTLE STATE
## Cards used during battle. A valid deck has 10 or more cards.
var enemyDeckCards := []
var playerDeckCards := []



## Used to generate playerRecruitmentPool. The game checks for cards whose subtype contains
## members of this array.
var playerAlliances: PackedStringArray = []

## Cards available for purchase based on player alliances.
var playerRecruitmentPool := []

## true is enemy (AI) turn, false if player turn
var enemy_turn: bool

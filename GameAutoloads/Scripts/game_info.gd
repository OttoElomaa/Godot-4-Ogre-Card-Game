extends Node2D

var all_cards = []

var playerName := "The Player"
var heroName := "The Amir"
var character_position: Map_Node

var playerGlory := 0

var playerIcon:Texture:
	get:
		return $PlayerSprite.texture


var enemyDeckCards := []

## Cards used during battle. A valid deck has 10 or more cards.
var playerDeckCards := []

## All cards owned by the player. The active deck is made of these.
var playerOwnedCards := []

## Used to generate playerRecruitmentPool. The game checks for cards whose subtype contains
## members of this array.
var playerAlliances: PackedStringArray = []

## Cards available for purchase based on player alliances.
var playerRecruitmentPool := []

## true is enemy (AI) turn, false if player turn
var enemy_turn: bool

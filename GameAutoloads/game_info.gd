extends Node2D



var playerName := "The Player"
var heroName := "The Amir"
var character_position: Map_Node

var playerGlory := 0

var playerIcon:Texture:
	get:
		return $PlayerSprite.texture

var enemyDeckCards := []
var playerDeckCards := []

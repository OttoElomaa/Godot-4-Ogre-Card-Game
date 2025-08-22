extends Node2D



var playerName := "The Player"
var heroName := "The Amir"

var playerGlory := 0

var playerIcon:Texture:
	get:
		return $PlayerSprite.texture

extends Node2D


enum GameStates {
	PLAY, ATTACK, CARD_ACT_MENU, CAST, NONE, BESTIARY
}

var gameState: GameStates = GameStates.PLAY



func statesNone():
	gameState = GameStates.NONE
	

func statesPlay():
	gameState = GameStates.PLAY


func isStatePlay():
	return gameState == GameStates.PLAY

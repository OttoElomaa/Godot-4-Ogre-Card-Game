extends Node2D


enum GameStates {
	PLAY, ATTACK, CARD_ACT_MENU, CAST, NONE, BESTIARY
}

var gameState: GameStates = GameStates.PLAY

var ignoreMouseInput := false



func statesNone():
	gameState = GameStates.NONE
	

func statesPlay():
	gameState = GameStates.PLAY


func isStatePlay():
	return gameState == GameStates.PLAY



func toggleIgnoreMouseInput(enable:bool):
	var previousState = ignoreMouseInput
	ignoreMouseInput = enable
	
	return previousState
	
	
	

	
	
	
	
	

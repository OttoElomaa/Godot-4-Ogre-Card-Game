extends Node2D


enum GameStates {
	PLAY, ATTACK, CARD_ACT_MENU, CAST,
}

var gameState: GameStates = GameStates.PLAY

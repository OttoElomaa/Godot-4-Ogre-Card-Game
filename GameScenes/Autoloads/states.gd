extends Node2D


enum GameStates {
	PLAY, ATTACK, CARD_ACT_MENU
}

var gameState: GameStates = GameStates.PLAY

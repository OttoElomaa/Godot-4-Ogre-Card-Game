extends Control
class_name CustomWindow

var main: Champion

func setup(champ:Champion):
	main = champ
	main.gameBoard.attach_champ_custom_window(main.isEnemyCard, self)

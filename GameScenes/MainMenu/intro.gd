extends Node2D



func toggleIntro(toShow:bool):
	if toShow:
		$CanvasLayer/TypewriterTextbox.show()
	else:
		$CanvasLayer/TypewriterTextbox.hide()

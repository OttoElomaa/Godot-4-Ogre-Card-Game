extends Node2D



func _process(delta):
	pass
	#if Input.is_anything_pressed():
		#get_tree().change_scene_to_file("res://GameScenes/MainMenu.tscn")
		


func toggleIntro(toShow:bool):
	if toShow:
		$CanvasLayer/TypewriterTextbox.show()
	else:
		$CanvasLayer/TypewriterTextbox.hide()

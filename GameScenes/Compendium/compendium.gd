extends Node2D

var active_scene = null
@onready var bestiary = preload("res://GameScenes/Compendium/bestiary.tscn").instantiate()

func open_book(scene:Object):
	hide_buttons()
	$ActiveScene.add_child(scene)
	active_scene = scene

func close_book():
	$ActiveScene.remove_child(active_scene)
	active_scene = null
	show_buttons()
	
func hide_buttons():
	$SectionButtons.hide()

func show_buttons():
	$SectionButtons.show()

func _on_return_button_pressed():
	print('return button pressed')
	if active_scene:
		close_book()
	else:
		SceneSwitcher.switchToStoredScene()

func _on_bestiary_button_pressed():
	open_book(bestiary)
	

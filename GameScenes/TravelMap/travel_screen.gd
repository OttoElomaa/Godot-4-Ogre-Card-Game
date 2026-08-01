extends Node2D
class_name TravelScreen

func _ready():
	$AnimationPlayer.play("zoom_out")

func add_node_scenario():
	

func _on_node_entered(node:Map_Node):
	print('node entered')
	$AnimationPlayer.play('zoom_in')
	await $AnimationPlayer.animation_finished
	SceneSwitcher.switchToNewSceneFromFile("res://GameScenes/Zone/Zone.tscn")

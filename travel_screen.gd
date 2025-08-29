extends Node2D
class_name TravelScreen

@onready var levelSelect: Level_Select = $MarginContainer/SubViewportContainer/SubViewport/LevelSelect

func _ready():
	$AnimationPlayer.play("zoom_out")
	levelSelect.connect("node_entered", _on_node_entered)

func _on_node_entered(node:Map_Node):
	print('node entered')
	$AnimationPlayer.play('zoom_in')
	await $AnimationPlayer.animation_finished
	SceneSwitcher.switchToNewSceneFromFile('Zone/Zone', self)

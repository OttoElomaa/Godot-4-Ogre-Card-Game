extends Node2D
class_name Level_Select

signal node_clicked(node:Map_Node)
signal node_entered(node:Map_Node)
signal node_captured()
signal level_select_initialized()

@onready var Nodes = $Nodes

var map_node = preload("res://GameScenes/TravelMap/map_node.tscn")

@export var movement_speed = 200.0
var controllable := true
var character_position: Map_Node
@export var zoom := Vector2(1.0, 1.0)

func _ready():
	if not GameInfo.character_position:
		character_position = $Nodes.get_children()[0]
	else:
		print('loaded_character_position')
		character_position = GameInfo.character_position
	set_camera_limit()
	place_character()
	self.node_clicked.connect(_on_node_clicked)
	self.node_entered.connect(_on_node_entered)
	$Character.movement_speed = movement_speed
	level_select_initialized.emit()
	
func _on_node_clicked(node:Map_Node):
	print(node.index)
	move_character(node.index)

func _on_node_entered(node:Map_Node):
#Runs whenever any node is entered. Contains procedures to run depending on node type.
	pass

func _on_level_won():
	node_captured.emit()

func move_character(dir: String):
	if check_for_node_in_index(dir):
		$Character/NavigationAgent2D.target_position = get_node_in_index(dir).global_position
		controllable = false
		await $Character/NavigationAgent2D.navigation_finished
		character_position = get_node_in_index(dir)
		node_entered.emit(character_position)
		place_character()
		controllable = true
	else:
		print('no such node')

func place_character():
	$Character.global_position = character_position.global_position
	GameInfo.character_position = character_position

func get_node_in_index(index:String):
	for child in $Nodes.get_children():
		if child.index == index:
			return child

func check_for_node_in_index(index:String):
	for child in $Nodes.get_children():
		if child.index == index and child is Map_Node:
			return true
	return false

func check_if_can_move_to(node:Map_Node):
	var connections = node.connections
	for i in connections:
		if check_for_node_in_index(i):
			return true
	return false

func set_camera_limit():
	$Character/Camera2D.limit_bottom = $BackGround/Sprite2D.get_rect().end.y
	$Character/Camera2D.limit_right = $BackGround/Sprite2D.get_rect().end.x
	$Character/Camera2D.limit_left = $BackGround/Sprite2D.get_rect().position.x
	$Character/Camera2D.limit_top = $BackGround/Sprite2D.get_rect().position.y
